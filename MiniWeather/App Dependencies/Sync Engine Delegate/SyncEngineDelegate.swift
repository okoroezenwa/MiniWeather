//
//  SyncEngineDelegate.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 06/05/2024.
//

import CloudKit
import OSLog

protocol SyncEngineDelegate: CKSyncEngineDelegate {
    func add(pendingRecordZoneChanges changes: [CKSyncEngine.PendingRecordZoneChange])
    func start()
}

final class MainSyncEngineDelegate: SyncEngineDelegate, Loggable {
    private var syncEngine: CKSyncEngine {
        if _syncEngine == nil {
            self.makeSyncEngine()
        }
        return _syncEngine!
    }
    private var _syncEngine: CKSyncEngine?
    let database: CKDatabase
    let recordProvider: CloudKitRecordsProvider
    let savedLocationsProvider: SavedLocationsProvider
        let serialisationProvider: SyncEngineStateSerialisationProvider
    
    init(database: CKDatabase, recordProvider: CloudKitRecordsProvider, savedLocationsProvider: SavedLocationsProvider, serialisationProvider: SyncEngineStateSerialisationProvider) {
        self.database = database
        self.recordProvider = recordProvider
        self.savedLocationsProvider = savedLocationsProvider
        self.serialisationProvider = serialisationProvider
        logger.info("Sync Delegate started")
    }
    
    private func makeSyncEngine() {
        let configuration = CKSyncEngine.Configuration(
            database: database,
            stateSerialization: try? serialisationProvider.getLastKnowSyncEngineStateSerialisation(),
            delegate: self
        )
        let syncEngine = CKSyncEngine(configuration)
        _syncEngine = syncEngine
         logger.log("Initialized sync engine: \(syncEngine)")
    }
    
    #warning("Rewrite all functions to prevent unnecessary writes to disk due to for loops")
    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        //        Logger.database.debug("Handling event \(event)")
        
        switch event {
            case .stateUpdate(let event):
                do {
                    try serialisationProvider.store(event.stateSerialization)
                    logger.notice("State update handled. Event: \(event)")
                } catch {
                    logger.error("State update failed with error: \(error). Event: \(event)")
                }
                
            case .accountChange(let event):
                self.handleAccountChange(event)
                
            case .fetchedDatabaseChanges(let event):
                self.handleFetchedDatabaseChanges(event)
                
            case .fetchedRecordZoneChanges(let event):
                self.handleFetchedRecordZoneChanges(event)
                
            case .sentRecordZoneChanges(let event):
                self.handleSentRecordZoneChanges(event)
                
            case .sentDatabaseChanges:
                // The sample app doesn't track sent database changes in any meaningful way, but this might be useful depending on your data model.
                break
                
            case .willFetchChanges, .willFetchRecordZoneChanges, .didFetchRecordZoneChanges, .didFetchChanges, .willSendChanges, .didSendChanges:
                // We don't do anything here in the sample app, but these events might be helpful if you need to do any setup/cleanup when sync starts/ends.
                break
                
            @unknown default:
                break
                //                Logger.database.info("Received unknown event: \(event)")
        }
    }
    
    func nextRecordZoneChangeBatch(_ context: CKSyncEngine.SendChangesContext, syncEngine: CKSyncEngine) async -> CKSyncEngine.RecordZoneChangeBatch? {
        do {
            let scope = context.options.scope
            let changes = syncEngine.state.pendingRecordZoneChanges.filter { scope.contains($0) }
            let records = try await recordProvider.getRecords()
            let locations = try await savedLocationsProvider.getSavedLocations()
            
            let batch = await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: changes) { recordID in
                if let record = records.first(where: { $0.recordID.recordName == recordID.recordName }), let location = locations.first(where: { $0.id == recordID.recordName }) {
                    recordProvider.setFields(of: record, from: location)
                    return record
                } else {
                    // We might have pending changes that no longer exist in our database. We can remove those from the state.
                    syncEngine.state.remove(pendingRecordZoneChanges: [.saveRecord(recordID)])
                    return nil
                }
            }
            logger.info("Returning next record change batch for context: \(context)")
            return batch
        } catch {
            logger.error("Failed to return next record change batch for context: \(context). Error: \(error)")
            return nil
        }
    }
    
    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) {
        // Handling account changes can be tricky.
        //
        // If the user signed out of their account, we want to delete all local data.
        // However, what if there's some data that hasn't been uploaded yet?
        // Should we keep that data? Prompt the user to keep the data? Or just delete it?
        //
        // Also, what if the user signs in to a new account, and there's already some data locally?
        // Should we upload it to their account? Or should we delete it?
        //
        // Finally, what if the user signed in, but they were signed into a previous account before?
        //
        // Since we're in a sample app, we're going to take a relatively simple approach.
        let shouldDeleteLocalData: Bool
        let shouldReUploadLocalData: Bool
        
        switch event.changeType {
                
            case .signIn:
                shouldDeleteLocalData = false
                shouldReUploadLocalData = true
                
            case .switchAccounts:
                shouldDeleteLocalData = true
                shouldReUploadLocalData = false
                
            case .signOut:
                shouldDeleteLocalData = true
                shouldReUploadLocalData = false
                
            @unknown default:
                logger.log("Unknown account change type: \(event)")
                shouldDeleteLocalData = false
                shouldReUploadLocalData = false
        }
        
        if shouldDeleteLocalData {
            Task {
                do {
                    try await savedLocationsProvider.setLocations(to: [])
                    NotificationCenter.default.post(name: .cloudKitRecordsUpdated, object: nil)
                    logger.notice("Deleted local data")
                } catch {
                    // Dunno how to handle this in time...
                    logger.error("Failed to delete local data. \(error)")
                }
            }
        }
        
        if shouldReUploadLocalData {
            Task {
                do {
                    let locations = try await self.savedLocationsProvider.getSavedLocations()
                    var recordZoneChanges = [CKSyncEngine.PendingRecordZoneChange]()
                    for location in locations {
                        if let record = try? await self.recordProvider.getRecord(withRecordName: location.id) {
                            recordZoneChanges.append(.saveRecord(record.recordID))
                        }
                    }
                    self.syncEngine.state.add(pendingDatabaseChanges: [.saveZone(CKRecordZone(zoneName: Location.zoneName))])
                    self.syncEngine.state.add(pendingRecordZoneChanges: recordZoneChanges)
                    logger.notice("Reuploaded local data")
                } catch {
                    logger.error("Failed to reupload local data. \(error)")
                }
            }
        }
    }
    
    func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) {
        // If a zone was deleted, we should delete everything for that zone locally.
        for deletion in event.deletions {
            switch deletion.zoneID.zoneName {
                case Location.zoneName:
                    Task {
                        try? await savedLocationsProvider.setLocations(to: [])
                        logger.notice("Deleted zone named \(Location.zoneName)")
                        NotificationCenter.default.post(name: .cloudKitRecordsUpdated, object: nil)
                    }
                default:
                    logger.info("Received deletion for unknown zone: \(deletion.zoneID)")
            }
        }
    }
    
    func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) {
        Task { [self] in
            var recordsToUpdate = [CKRecord]()
            var recordsToDelete = [String]()
            var itemToUpdate = [Location]()
            var itemsToDelete = [Location]()
            
            for modification in event.modifications {
                // The sync engine fetched a record, and we want to merge it into our local persistence.
                // If we already have this object locally, let's merge the data from the server.
                // Otherwise, let's create a new local object.
                let record = modification.record
                let id = record.recordID.recordName
                do {
                    let records = try await recordProvider.getRecords()
                    guard let itemRecord = records.first(where: { $0.recordID.recordName == id }) else {
                        continue
                    }
                    let items = try await savedLocationsProvider.getSavedLocations()
                    guard var item = items.first(where: { $0.id == itemRecord.recordID.recordName }) else {
                        continue
                    }
                    recordProvider.mergeFields(of: &item, with: itemRecord)
                    itemToUpdate.append(item)
                    recordsToUpdate.append(itemRecord)
                    logger.log("Received contact modification: \(record.recordID)")
                } catch {
                    logger.error("Failed to update recordsToUpdate: \(error)")
                    continue
                }
            }
            
            for deletion in event.deletions {
                
                // A record was deleted on the server, so let's remove it from our local persistence.
                let id = deletion.recordID.recordName
                recordsToDelete.append(id)
                do {
                    let locations = try await savedLocationsProvider.getSavedLocations()
                    if let location = locations.first(where: { $0.id == id }) {
                        itemsToDelete.append(location)
                    }
                    logger.log("Received contact deletion: \(deletion.recordID)")
                } catch {
                    logger.error("Failed to update recordsToUpdate: \(error)")
                    continue
                }
            }
            
            do {
                var records = try await recordProvider.getRecords()
                var items = try await savedLocationsProvider.getSavedLocations()
                
                for record in recordsToDelete {
                    if let index = records.firstIndex(where: { $0.recordID.recordName == record }) {
                        records.remove(at: index)
                    }
                }
                
                for item in itemsToDelete {
                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                        items.remove(at: index)
                    }
                }
                
                for record in recordsToUpdate {
                    if let index = records.firstIndex(where: { $0.recordID.recordName == record.recordID.recordName }) {
                        records[index] = record
                    }
                }
                
                for item in itemToUpdate {
                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                        items[index] = item
                    }
                }
                
                try await savedLocationsProvider.setLocations(to: items)
                try await recordProvider.setRecords(to: records)
                NotificationCenter.default.post(name: .cloudKitRecordsUpdated, object: nil)
                logger.log("Set locations and records to \(items.map(\.city).joined(separator: ", "))")
            } catch {
                logger.error("Failed to set locations and records: \(error)")
            }
        }
    }
    
    func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) {
        // If we failed to save a record, we might want to retry depending on the error code.
        var newPendingRecordZoneChanges = [CKSyncEngine.PendingRecordZoneChange]()
        var newPendingDatabaseChanges = [CKSyncEngine.PendingDatabaseChange]()
        
        // Update the last known server record for each of the saved records.
        for savedRecord in event.savedRecords {
            Task {
                do {
                    let id = savedRecord.recordID.recordName
                    _ = try await recordProvider.updateRecord(withRecordName: id, to: savedRecord)
                    logger.log("Updated record with ID: \(savedRecord.recordID.recordName)")
                } catch {
                    logger.error("Failed to update record with ID: \(savedRecord.recordID.recordName). \(error)")
                }
            }
        }
        
        // Handle any failed record saves.
        for failedRecordSave in event.failedRecordSaves {
            let failedRecord = failedRecordSave.record
            let id = failedRecord.recordID.recordName
            var shouldClearServerRecord = false
            
            switch failedRecordSave.error.code {
                case .serverRecordChanged:
                    // Let's merge the record from the server into our own local copy.
                    // The `mergeFromServerRecord` function takes care of the conflict resolution.
                    guard let serverRecord = failedRecordSave.error.serverRecord else {
                        logger.error("No server record for conflict \(failedRecordSave.error)")
                        continue
                    }
                    
                    Task {
                        let locations = try await self.savedLocationsProvider.getSavedLocations()
                        if var location = locations.first(where: { failedRecord.recordID.recordName == $0.id }) {
                            recordProvider.mergeFields(of: &location, with: failedRecord)
                        }
                        _ = try await recordProvider.updateRecord(withRecordName: failedRecord.recordID.recordName, to: failedRecord)
                    }
                    newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                    
                case .zoneNotFound:
                    // Looks like we tried to save a record in a zone that doesn't exist.
                    // Let's save that zone and retry saving the record.
                    // Also clear the last known server record if we have one, it's no longer valid.
                    let zone = CKRecordZone(zoneID: failedRecord.recordID.zoneID)
                    newPendingDatabaseChanges.append(.saveZone(zone))
                    newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                    shouldClearServerRecord = true
                    
                case .unknownItem:
                    // We tried to save a record with a locally-cached server record, but that record no longer exists on the server.
                    // This might mean that another device deleted the record, but we still have the data for that record locally.
                    // We have the choice of either deleting the local data or re-uploading the local data.
                    // For this sample app, let's re-upload the local data.
                    newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                    shouldClearServerRecord = true
                    
                case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable, .notAuthenticated, .operationCancelled:
                    // There are several errors that the sync engine will automatically retry, let's just log and move on.
                    logger.debug("Retryable error saving \(failedRecord.recordID): \(failedRecordSave.error)")
                    
                default:
                    // We got an error, but we don't know what it is or how to handle it.
                    // If you have any sort of telemetry system, you should consider tracking this scenario so you can understand which errors you see in the wild.
                    logger.fault("Unknown error saving record \(failedRecord.recordID): \(failedRecordSave.error)")
            }
            
            if shouldClearServerRecord {
                Task {
                    do {
                        try await recordProvider.deleteRecord(withRecordName: id)
                        logger.log("Cleared records with ids: \(id)")
                    } catch {
                        logger.error("Failed to clear records with ids: \(id). \(error)")
                    }
                }
            }
        }
        
        self.syncEngine.state.add(pendingDatabaseChanges: newPendingDatabaseChanges)
        self.syncEngine.state.add(pendingRecordZoneChanges: newPendingRecordZoneChanges)
        logger.log("Added pending DB and record zone changes")
    }
    
    func add(pendingRecordZoneChanges changes: [CKSyncEngine.PendingRecordZoneChange]) {
        syncEngine.state.add(pendingRecordZoneChanges: changes)
    }
    
    func start() {
        let _ = syncEngine.description
    }
}
