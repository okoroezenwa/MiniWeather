//
//  MainCloudKitUserAccountStatusProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import CloudKit

final class MainCloudKitUserAccountStatusProvider: CloudKitUserAccountStatusProvider {
    let container: CKContainer
    
    init(container: CKContainer) {
        self.container = container
    }
    
    func getAccountStatus() async throws -> CKAccountStatus {
        try await container.accountStatus()
    }
}
