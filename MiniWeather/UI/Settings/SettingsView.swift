//
//  SettingsView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 08/12/2023.
//

import SwiftUI

struct Settings {
    static let appTheme = "appTheme"
    static let unitsOfMeasure = "unitsOfMeasure"
    static let geocoderService = "geocoderService"
    static let weatherProvider = "weatherProvider"
    static let apiNinjasKey = "apiNinjasKey"
    static let openWeatherMapKey = "openWeatherMapKey"
    
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

enum UnitOfMeasure: String, CaseIterable, Identifiable, DefaultPresenting {
    case metric = "Metric"
    case imperial = "Imperial"
    case hybrid = "Hybrid"
    
    var id: Self {
        self
    }
    
    static let `default`: UnitOfMeasure = .metric
}

struct SettingsView: View {
    @AppStorage(Settings.appTheme) private var theme = Theme.default
    @AppStorage(Settings.geocoderService) private var geocoderService = Service.default
    @AppStorage(Settings.weatherProvider) private var weatherProvider = Service.default
    @AppStorage(Settings.unitsOfMeasure) private var unitsOfMeasure = UnitOfMeasure.default
    @AppStorage(Settings.apiNinjasKey) private var apiNinjasKey = ""
    @AppStorage(Settings.openWeatherMapKey) private var openWeatherMapKey = ""
    private var dismiss: () -> ()
    
    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    SettingsPicker(title: "Theme", selection: $theme.animation())
                }
                
                Section {
                    SettingsPicker(title: "Units", selection: $unitsOfMeasure)
                } header: {
                    Text("General")
                } footer: {
                    Text("Changing units may require a refresh of existing weather info.")
                }
                .disabled(weatherProvider == .apiNinjas)

                Section {
                    SettingsPicker(title: "Geocoder", selection: $geocoderService)
                    
                    SettingsPicker(title: "Weather Provider", selection: $weatherProvider)
                } header: {
                    Text("Services")
                } footer: {
                    Text("Weather provided by API-Ninjas is always returned in Metric units.")
                }
                
                Section("API Keys") {
                    LabeledTextField(title: "API-Ninjas", description: "API-Ninjas API key entry", prompt: "Enter API Key", text: $apiNinjasKey)
                    
                    LabeledTextField(title: "OpenWeatherMap", description: "OpenWeatherMap API key entry", prompt: "Enter API Key", text: $openWeatherMapKey)
                }
                
                Section("Providers") {
                    SettingsLink(name: "Apple", urlString: "https://www.apple.com")
                    
                    SettingsLink(name: "API-Ninjas", urlString: "https://api-ninjas.com")
                    
                    SettingsLink(name: "OpenWeatherMap", urlString: "https://openweathermap.org")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
        .tint(.secondary)
    }
}

struct SettingsLink: View {
    private let name: String
    private let imageName: String
    private let urlString: String
    
    init(name: String, imageName: String = "arrow.up.right", urlString: String) {
        self.name = name
        self.imageName = imageName
        self.urlString = urlString
    }
    
    var body: some View {
        Link(destination: .init(string: urlString)!) {
            HStack() {
                Text(name)
                
                Spacer()
                
                Image(systemName: imageName)
            }
        }
    }
}

struct LabeledTextField: View {
    private let title: String
    private let description: String
    private let prompt: String
    private var text: Binding<String>
    
    init(title: String, description: String, prompt: String, text: Binding<String>) {
        self.title = title
        self.description = description
        self.prompt = prompt
        self.text = text
    }
    
    var body: some View {
        LabeledContent(title) {
            TextField(description, text: text, prompt: Text(prompt))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView() {
        
    }
}
