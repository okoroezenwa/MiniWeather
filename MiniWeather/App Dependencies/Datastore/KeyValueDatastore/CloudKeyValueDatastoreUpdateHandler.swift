//
//  CloudKeyValueDatastoreUpdateHandler.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 29/11/2023.
//

import Foundation
import Combine
import OSLog

/// Handles updating the local store once an update is received from another device.
final class CloudKeyValueDatastoreUpdateHandler {
    private var kvsCancellable: Cancellable?
    private let cloudStore: KeyValueStore
    private let localStore: KeyValueStore
    private let logger: Logger
    
    init(cloudStore: KeyValueStore, localStore: KeyValueStore, logger: Logger) {
        self.cloudStore = cloudStore
        self.localStore = localStore
        self.logger = logger
        
        self.kvsCancellable = NotificationCenter.default
            .publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
            .sink { notification in
                guard
                    let userInfo = notification.userInfo,
                    let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
                    let key = keys.first(where: { $0 == DatastoreKey.savedItems.rawValue }),
                    let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
                    reason == NSUbiquitousKeyValueStoreServerChange,
                    let data = cloudStore.data(forKey: key)
                else {
                    return
                }
                
                // updates local store with new data and notifies any observers
                localStore.set(data, forKey: key)
                NotificationCenter.default.post(name: .cloudStoreUpdated, object: NSUbiquitousKeyValueStore.default)
                print("updated items")
            }
    }
}
