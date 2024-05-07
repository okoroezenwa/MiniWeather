//
//  CloudKitRecordsProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit

protocol CloudKitRecordsProvider {
    func getRecords() async throws -> [CKRecord]
    func setRecords(to newRecords: [CKRecord]) async throws
    func createRecord(withZoneName zoneName: String, recordName id: String, recordType: CKRecord.RecordType) async throws -> CKRecord
    func getRecord(withRecordName id: String) async throws -> CKRecord
    func updateRecord(withRecordName id: String, to newRecord: CKRecord) async throws -> CKRecord
    func deleteRecord(withRecordName id: String) async throws
    func setFields<T: CloudKitModel>(of record: CKRecord, from item: T)
    func mergeFields<T: CloudKitModel>(of item: inout T, with record: CKRecord)
}
