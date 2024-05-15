//
//  SyncEngineStateSerialisationProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit

protocol SyncEngineStateSerialisationProvider {
    func getLastKnowSyncEngineStateSerialisation() throws -> CKSyncEngine.State.Serialization
    func store(_ state: CKSyncEngine.State.Serialization) throws
}
