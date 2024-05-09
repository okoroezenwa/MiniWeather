//
//  SyncEngineOperationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/05/2024.
//

import Foundation

protocol SyncEngineOperationsRepository {
    func saveRecord<T: CloudKitModel>(of item: T) async throws
    func deleteRecord<T: CloudKitModel>(of item: T) async throws
    func saveRecords<T: CloudKitModel>(of items: [T]) async throws
    func deleteRecords<T: CloudKitModel>(of items: [T]) async throws
}
