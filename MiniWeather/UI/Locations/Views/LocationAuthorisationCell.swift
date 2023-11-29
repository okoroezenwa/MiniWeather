//
//  LocationAuthorisationCell.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 16/11/2023.
//

import SwiftUI
import CoreLocation

struct LocationAuthorisationCell: View {
    @Environment(\.colorScheme) var colorScheme
    let status: CLAuthorizationStatus
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cellTitle())
                        .font(.system(size: 17))
                    
                    Text(cellSubtitle())
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .frame(square: 32)
                        .foregroundStyle(
                            Color.primary
                                .opacity(0.05)
                        )
                    
                    Image(systemName: imageName())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(square: 16)
                    
                }
            }
        }
        .padding(16)
        .background(
            .cellBackgroundColour(for: colorScheme)
        )
        .clipShape(.rect(cornerRadius: 16))
    }
    
    func cellTitle() -> String {
        switch status {
            case .notDetermined: 
                return "Location Access Required"
            case .denied, .restricted:
                return "Location Access Denied"
            default:
                return ""
        }
    }
    
    func cellSubtitle() -> String {
        switch status {
            case .notDetermined:
                return "Tap to grant location access"
            case .denied, .restricted:
                #if os(iOS)
                return "Tap to open Settings"
                #else
                return "Allow MiniWeather to use location in Settings"
                #endif
            default:
                return ""
        }
    }
    
    func imageName() -> String {
        switch status {
            case .notDetermined:
                return "hand.tap"
            case .denied, .restricted:
                return "gearshape"
            default:
                return ""
        }
    }
}

#Preview {
    LocationAuthorisationCell(status: .notDetermined)
}
