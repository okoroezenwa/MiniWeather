//
//  SyncEngineOperationsProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/04/2024.
//

import CloudKit
import OSLog

protocol SyncEngineOperationsProvider {
    func saveRecord<T: CloudKitModel>(of item: T) async throws
    func deleteRecord<T: CloudKitModel>(of item: T) async throws
    func saveRecords<T: CloudKitModel>(of items: [T]) async throws
    func deleteRecords<T: CloudKitModel>(of items: [T]) async throws
}

#warning("Organise later")
enum SyncError: Error {
    case recordNotFound
    case accountUnavailable
}
