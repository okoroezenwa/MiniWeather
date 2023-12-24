//
//  AlertCard.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/12/2023.
//

import SwiftUI
import WeatherKit

struct AlertCard: View {
    let alerts: [WeatherAlert]
    @State private var selectedAlert: WeatherAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(alerts, id: \.self) { alert in
                        WeatherCard(title: "Alert", imageName: "", value: "", unit: "", showHeader: false) {
                            VStack(spacing: 12) {
                                WeatherCardTitleSubtitleView(title: alert.region ?? "", subtitle: alert.summary)
                                
                                HStack {
                                    Link(destination: alert.detailsURL) {
                                        Label("Details", systemImage: "arrow.up.right")
                                            .font(.system(size: 14))
                                    }
                                    
                                    Spacer()
                                    
                                    Text(alert.source)
                                        .font(.system(size: 14))
                                }
                            }
                        } trailingHeaderView: {
                            HStack {
                                Circle()
                                    .fill(style(for: alert.severity))
                                    .frame(width: 12)
                                
                                WeatherCardTrailingHeaderTextView(text: alert.severity.description)
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    style(for: alert.severity),
                                    lineWidth: 3
                                )
                        }
                        .containerRelativeFrame(.horizontal)
                    }
                }
            }
            .padding(.horizontal, -16)
            .contentMargins(.horizontal, 16)
            .scrollTargetLayout(isEnabled: true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.never)
            .scrollPosition(id: $selectedAlert)
            .scrollClipDisabled()
            
            if alerts.count > 1 {
                Spacer()
                
                PageIndicatorView(items: alerts, currentSelection: $selectedAlert)
            }
        }
        .onAppear {
            selectedAlert = alerts.first
        }
    }
    
    private func style(for alertSeverity: WeatherSeverity) -> Color {
        switch alertSeverity {
            case .minor:
                return .green
            case .moderate:
                return .yellow
            case .severe:
                return .orange
            case .extreme:
                return .red
            case .unknown:
                return .secondary
            @unknown default:
                return .primary
        }
    }
}

extension WeatherAlert: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(region)
        hasher.combine(source)
        hasher.combine(detailsURL)
        hasher.combine(summary)
    }
}

struct PageIndicatorView<Value: Hashable>: View {
    let items: [Value]
    @Binding var currentSelection: Value?
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Circle()
                    .fill(currentSelection == item ? .primary : .tertiary)
                    .frame(width: 6)
            }
        }
    }
}

//#Preview {
//    AlertCard()
//}
