//
//  CloudKitModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit

protocol CloudKitModel: Codable {
    var id: String { get }
    var lastModified: Date { get set }
    var recordFields: [(kind: CKRecord.FieldKey.Kind, value: CKRecordValueProtocol?)] { get }
    
    init?(record: CKRecord)
    
    static var zoneName: String { get }
    static var recordType: String { get }
}
