//
//  MainSyncEngineOperationsRepository.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/05/2024.
//

import Foundation

final class MainSyncEngineOperationsRepository: SyncEngineOperationsRepository {
    let provider: SyncEngineOperationsProvider
    
    init(provider: SyncEngineOperationsProvider) {
        self.provider = provider
    }
    
    func saveRecord<T>(of item: T) async throws where T : CloudKitModel {
        try await provider.saveRecord(of: item)
    }
    
    func deleteRecord<T>(of item: T) async throws where T : CloudKitModel {
        try await provider.deleteRecord(of: item)
    }
    
    func saveRecords<T>(of items: [T]) async throws where T : CloudKitModel {
        try await provider.saveRecords(of: items)
    }
    
    func deleteRecords<T>(of items: [T]) async throws where T : CloudKitModel {
        try await provider.deleteRecords(of: items)
    }
}
