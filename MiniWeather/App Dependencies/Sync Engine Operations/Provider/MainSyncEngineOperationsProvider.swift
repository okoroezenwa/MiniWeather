//
//  MainSyncEngineOperationsProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit
import OSLog

final class MainSyncEngineOperationsProvider: SyncEngineOperationsProvider {
    let syncEngineDelegate: SyncEngineDelegate
    let recordProvider: CloudKitRecordsProvider
    let userAccountStatusProvider: CloudKitUserAccountStatusProvider
    
    init(syncEngineDelegate: SyncEngineDelegate, recordProvider: CloudKitRecordsProvider, userAccountStatusProvider: CloudKitUserAccountStatusProvider) {
        self.syncEngineDelegate = syncEngineDelegate
        self.recordProvider = recordProvider
        self.userAccountStatusProvider = userAccountStatusProvider
    }
    
    func saveRecord<T: CloudKitModel>(of item: T) async throws {
        let status = try await userAccountStatusProvider.getAccountStatus()
        guard status == .available else {
            throw SyncError.accountUnavailable
        }
        let records = try await recordProvider.getRecords()
        var record: CKRecord
        if let existingRecord = records.first(where: { $0.recordID.recordName == item.id }) {
            record = try await recordProvider.updateRecord(withRecordName: item.id, to: existingRecord)
        } else {
            record = try await recordProvider.createRecord(withZoneName: T.zoneName, recordName: item.id, recordType: T.recordType)
        }
        let pendingSaves: [CKSyncEngine.PendingRecordZoneChange] = [.saveRecord(record.recordID)]
        syncEngineDelegate.add(pendingRecordZoneChanges: pendingSaves)
    }
    
    func deleteRecord<T: CloudKitModel>(of item: T) async throws {
        let status = try await userAccountStatusProvider.getAccountStatus()
        guard status == .available else {
            throw SyncError.accountUnavailable
        }
        let record = try await recordProvider.getRecord(withRecordName: item.id)
        try await recordProvider.deleteRecord(withRecordName: item.id)
        let pendingDeletions: [CKSyncEngine.PendingRecordZoneChange] = [.deleteRecord(record.recordID)]
        syncEngineDelegate.add(pendingRecordZoneChanges: pendingDeletions)
    }
    
    func saveRecords<T: CloudKitModel>(of items: [T]) async throws {
        let status = try await userAccountStatusProvider.getAccountStatus()
        guard status == .available else {
            throw SyncError.accountUnavailable
        }
        let records = try await recordProvider.getRecords()
        var recordsToSave = [CKRecord]()
        for item in items {
            var record: CKRecord
            if let existingRecord = records.first(where: { $0.recordID.recordName == item.id }) {
                record = try await recordProvider.updateRecord(withRecordName: item.id, to: existingRecord)
            } else {
                record = try await recordProvider.createRecord(withZoneName: T.zoneName, recordName: item.id, recordType: T.recordType)
            }
            recordsToSave.append(record)
        }
        let pendingSaves: [CKSyncEngine.PendingRecordZoneChange] = recordsToSave.map { .saveRecord($0.recordID) }
        syncEngineDelegate.add(pendingRecordZoneChanges: pendingSaves)
    }
    
    func deleteRecords<T: CloudKitModel>(of items: [T]) async throws {
        let status = try await userAccountStatusProvider.getAccountStatus()
        guard status == .available else {
            throw SyncError.accountUnavailable
        }
        let records = try await recordProvider.getRecords()
        var recordsToDelete = [CKRecord]()
        for item in items {
            let record = try await recordProvider.getRecord(withRecordName: item.id)
            try await recordProvider.deleteRecord(withRecordName: item.id)
            recordsToDelete.append(record)
        }
        let pendingDeletions: [CKSyncEngine.PendingRecordZoneChange] = recordsToDelete.map { .deleteRecord($0.recordID) }
        syncEngineDelegate.add(pendingRecordZoneChanges: pendingDeletions)
    }
}
