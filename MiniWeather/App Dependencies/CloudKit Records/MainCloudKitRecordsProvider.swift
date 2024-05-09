//
//  MainCloudKitRecordsProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit
import OSLog

final class MainCloudKitRecordsProvider: CloudKitRecordsProvider {
    let datastore: Datastore
    let encoder: DataEncoder
    let decoder: DataDecoder
    
    init(datastore: Datastore, encoder: DataEncoder, decoder: DataDecoder) {
        self.datastore = datastore
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func getRecords() async throws -> [CKRecord] {
        do {
            let records: [String: Data] = try datastore.fetch(forKey: .records)
            return records.values.compactMap { data in
                guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data), let record = CKRecord(coder: unarchiver) else {
                    return nil
                }
                return record
            }
        } catch DatastoreError.notFound {
            return []
        } catch {
            throw error
        }
    }
    
    func setRecords(to newRecords: [CKRecord]) async throws {
        var records = [CKRecord]()
        for record in newRecords {
            _ = try await updateRecord(withRecordName: record.recordID.recordName, to: record)
        }
    }
    
    func createRecord(withZoneName zoneName: String, recordName id: String, recordType: CKRecord.RecordType) async throws -> CKRecord {
        let zoneID = CKRecordZone.ID(zoneName: zoneName)
        let recordID = CKRecord.ID(recordName: id, zoneID: zoneID)
        let record = CKRecord.init(recordType: recordType, recordID: recordID)
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        let recordData = archiver.encodedData
        var records: [String: Data] = try {
            do {
                let records: [String: Data] = try datastore.fetch(forKey: .records)
                return records
            } catch DatastoreError.notFound {
                return [:]
            } catch {
                throw error
            }
        }()
        records[id] = recordData
        try datastore.store(records, withKey: .records)
        return record
    }
    
    func getRecord(withRecordName id: String) async throws -> CKRecord {
        let records: [String: Data] = try datastore.fetch(forKey: .records)
        guard let data = records[id], let unarchiver: NSKeyedUnarchiver = {
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
            return unarchiver
        }(), let record = CKRecord(coder: unarchiver) else {
            throw SyncError.recordNotFound
        }
        return record
    }
    
    func updateRecord(withRecordName id: String, to newRecord: CKRecord) async throws -> CKRecord {
        var records: [String: Data] = try {
            do {
                let records: [String: Data] = try datastore.fetch(forKey: .records)
                return records
            } catch DatastoreError.notFound {
                return [:]
            } catch {
                throw error
            }
        }()
        var record: CKRecord {
            if let oldRecordData = records[id], let unarchiver: NSKeyedUnarchiver = {
                let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: oldRecordData)
                return unarchiver
            }(), let oldRecord = CKRecord(coder: unarchiver) {
                return self.newerRecord(between: oldRecord, and: newRecord)
            } else {
                return newRecord
            }
        }
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        let recordData = archiver.encodedData
        records[id] = recordData
        try datastore.store(records, withKey: .records)
        return record
    }
    
    func deleteRecord(withRecordName id: String) async throws {
        var records: [String: Data] = try {
            do {
                let records: [String: Data] = try datastore.fetch(forKey: .records)
                return records
            } catch DatastoreError.notFound {
                return [:]
            } catch {
                throw error
            }
        }()
        records[id] = nil
        try datastore.store(records, withKey: .records)
    }
    
    func setFields<T: CloudKitModel>(of record: CKRecord, from item: T) {
        for field in item.recordFields {
            switch field.kind {
                case .encrypted(let key):
                    record.encryptedValues[key] = field.value
                case .unencrypted(let key):
                    record[key] = field.value
            }
        }
    }
    
    func mergeFields<T: CloudKitModel>(of item: inout T, with record: CKRecord) {
        // Conflict resolution can be a bit tricky.
        // For example, imagine this scenario with two devices:
        //
        // 1. DeviceA has no network connection.
        // 2. DeviceA modifies data.
        // 3. Hours later, DeviceB modifies data.
        // 4. DeviceB sends its changes to the server.
        // 5. DeviceA finally connects to the network and sends its changes.
        //
        // If we go strictly by last-uploader-wins, then we'll end up choosing the data from DeviceA, which is out of date.
        // The user actually wanted the data from DeviceB.
        // In order to find the value the user truly wanted, we keep track of the actual user's modification date.
        // Let's make sure we only merge in the data from the server if the user modification date is newer.
        let userModificationDate: Date
        if let dateFromRecord = record[.lastModified] as? Date {
            userModificationDate = dateFromRecord
        } else {
            //            Logger.dataModel.info("No user modification date in contact record")
            userModificationDate = Date.distantPast
        }
        
        if userModificationDate > item.lastModified {
            item.lastModified = userModificationDate
            self.setFields(of: record, from: item)
            
            //            if let name = record.encryptedValues[.contact_name] as? String {
            //                self.name = name
            //            } else {
            ////                Logger.dataModel.info("No name in contact record")
            //            }
        } else {
            //            Logger.dataModel.info("Not overwriting data from older contact record")
        }
    }
    
    /// Determines the most-recently edited record and returns it. This prevents overriding the last know record even though it's
    private func newerRecord(between oldRecord: CKRecord, and newRecord: CKRecord) -> CKRecord {
        if let oldRecordDate = oldRecord.modificationDate {
            if let newRecordDate = newRecord.modificationDate, oldRecordDate < newRecordDate {
                return newRecord
            } else {
                return oldRecord
            }
        } else {
            return newRecord
        }
    }
}
