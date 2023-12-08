//
//  SettingsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 08/12/2023.
//

import SwiftUI

struct Settings {
    static let appTheme = "appTheme"
    static let geocoderService = "geocoderService"
    static let weatherProvider = "weatherProvider"
    
    static func currentValue<Value: DefaultPresenting & RawRepresentable<String>>(for key: String) -> Value? {
        guard let rawValue = UserDefaults.standard.string(forKey: key), let value = Value(rawValue: rawValue) else {
            return nil
        }
        return value
    }
}

protocol DefaultPresenting<Value> {
    associatedtype Value
    static var `default`: Value { get }
}

enum Theme: String, CaseIterable, Identifiable, DefaultPresenting {
    case light = "Light"
    case dark = "Dark"
    case system = "Use System"
    
    var id: Self {
        self
    }
    
    static let `default`: Theme = .system
}

enum Service: String, CaseIterable, Identifiable, DefaultPresenting {
    case apple = "Apple"
    case apiNinjas = "API-Ninjas"
    case openWeatherMap = "OpenWeatherMap"
    
    var id: Self {
        self
    }
    
    static let `default`: Service = .apple
}

struct SettingsView: View {
    @AppStorage(Settings.appTheme) private var theme = Theme.default
    @AppStorage(Settings.geocoderService) private var geocoderService = Service.default
    @AppStorage(Settings.weatherProvider) private var weatherProvider = Service.default
    private var dismiss: () -> ()
    
    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    SettingsPicker(title: "Theme", selection: $theme)
                }
                
                Section("Services") {
                    SettingsPicker(title: "Geocoder", selection: $geocoderService)
                    
                    SettingsPicker(title: "Weather Provider", selection: $weatherProvider)
                }
                
                Section("API Keys") {
                    LabeledContent("API-Ninjas") {
                        Text("Key Here")
                    }
                    
                    LabeledContent("OpenWeatherMap") {
                        Text("Key Here")
                    }
                }
            }
            .navigationTitle("Settings")
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

typealias SelectionEnum = Hashable & CaseIterable & Identifiable & RawRepresentable<String>

struct SettingsPicker<Selection: SelectionEnum>: View where Selection.AllCases == Array<Selection> {
    let title: String
    @Binding var selection: Selection
    
    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Selection.allCases, id: \.self) { selection in
                Text(selection.rawValue)
            }
        }
    }
}

#Preview {
    SettingsView() {
        
    }
}
