//
//  CloudKitUserAccountStatusProvider.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 05/05/2024.
//

import Foundation
import CloudKit

protocol CloudKitUserAccountStatusProvider {
    func getAccountStatus() async throws -> CKAccountStatus
}
