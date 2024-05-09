//
//  MainSyncEngineStateSerialisationProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit
import OSLog

final class MainSyncEngineStateSerialisationProvider: SyncEngineStateSerialisationProvider {
    let datastore: Datastore
    
    init(datastore: Datastore) {
        self.datastore = datastore
    }
    
    func getLastKnowSyncEngineStateSerialisation() throws -> CKSyncEngine.State.Serialization {
        let state: CKSyncEngine.State.Serialization = try datastore.fetch(forKey: .syncEngineState)
        return state
    }
    
    func store(_ state: CKSyncEngine.State.Serialization) throws {
        try datastore.store(state, withKey: .syncEngineState)
    }
}
