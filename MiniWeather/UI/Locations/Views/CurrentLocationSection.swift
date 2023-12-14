//
//  CurrentLocationSection.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 07/12/2023.
//

import SwiftUI
import CoreLocation

struct CurrentLocationSectionViewModel {
    var currentLocation: Location?
    var weather: WeatherProtocol?
    var authorisationStatus: CLAuthorizationStatus
    var shouldDisplayAsLoading: Bool
    var notDetermined: () -> Void
}

struct CurrentLocationSection: View {
    @Environment(\.openURL) private var openURL
    private var viewModel: CurrentLocationSectionViewModel
    
    init(viewModel: CurrentLocationSectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if viewModel.authorisationStatus.isAuthorised() {
            NavigationLink(value: viewModel.currentLocation) {
                MaterialView(bottomPadding: 12) {
                    LocationCell(
                        location: viewModel.currentLocation,
                        weather: viewModel.weather,
                        isCurrentLocation: true,
                        shouldDisplayAsLoading: viewModel.shouldDisplayAsLoading
                    )
                }
                .padding(.horizontal, 16)
            }
        } else {
            MaterialView(bottomPadding: 16) {
                LocationAuthorisationCell(status: viewModel.authorisationStatus)
                    .onTapGesture {
                        let status = viewModel.authorisationStatus
                        let string: String = {
                            #if os(iOS)
                            return UIApplication.openSettingsURLString
                            #else
                            return ""
                            #endif
                        }()
                        
                        if status.isDisallowed(),
                           let url = URL(string: string) {
                            openURL(url)
                        } else if status == .notDetermined {
                            viewModel.notDetermined()
                        }
                    }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    CurrentLocationSection(
        viewModel: .init(
            authorisationStatus: .authorizedAlways,
            shouldDisplayAsLoading: false
        ) { 
            
        }
    )
}
