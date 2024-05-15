//
//  SyncEngineDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/05/2024.
//

import CloudKit

protocol SyncEngineDelegate: CKSyncEngineDelegate {
    func add(pendingRecordZoneChanges changes: [CKSyncEngine.PendingRecordZoneChange])
    func start()
}
