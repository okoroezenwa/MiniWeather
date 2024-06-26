//
//  LocationsViewModel.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 08/11/2023.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI
import OSLog

@Observable @MainActor 
final class LocationsViewModel {
    private let userLocationAuthorisationRepositoryFactory: () -> UserLocationAuthorisationRepository
    private let userLocationCoordinatesRepositoryFactory: () -> UserLocationCoordinatesRepository
    private let locationsRepositoryFactory: () -> LocationsSearchRepository
    private let weatherRepositoryFactory: () -> WeatherRepository
    private let timeZoneRepositoryFactory: () -> TimeZoneRepository
    private let currentLocationRepositoryFactory: () -> CurrentLocationRepository
    private let savedLocationsRepositoryFactory: () -> SavedLocationsRepository
    private let syncEngineOperationsRepositoryFactory: () -> SyncEngineOperationsRepository
    private let logger: Logger
    var status: CLAuthorizationStatus
    var currentLocation: Location?
    var locations = [Location]()
    // TODO: - replace with Actor object
    private var weatherCache = [String: WeatherProtocol]()
    var searchResults = [Location]()
    private var searchCancellable: AnyCancellable?
    var searchText = ""
    private var searchSubject = PassthroughSubject<String, Never>()
    var kvsCancellable: Cancellable?
    private var currentLocationNeedsRefresh = false
    var toastShouldPerformOnDismissAction = true
    var displayedToast: Toast? {
        didSet {
            guard toastShouldPerformOnDismissAction else { return }
            oldValue?.onDismiss?()
        }
    }
    
    init(
        userLocationAuthorisationRepositoryFactory: @escaping () -> UserLocationAuthorisationRepository,
        userLocationCoordinatesRepositoryFactory: @escaping () -> UserLocationCoordinatesRepository,
        locationsRepositoryFactory: @escaping () -> LocationsSearchRepository,
        weatherRepositoryFactory: @escaping () -> WeatherRepository,
        timeZoneRepositoryFactory: @escaping () -> TimeZoneRepository,
        currentLocationRepositoryFactory: @escaping () -> CurrentLocationRepository,
        savedLocationsRepositoryFactory: @escaping () -> SavedLocationsRepository,
        syncEngineOperationsRepositoryFactory: @escaping () -> SyncEngineOperationsRepository,
        logger: Logger = Logger()
    ) {
        self.userLocationAuthorisationRepositoryFactory = userLocationAuthorisationRepositoryFactory
        self.userLocationCoordinatesRepositoryFactory = userLocationCoordinatesRepositoryFactory
        self.locationsRepositoryFactory = locationsRepositoryFactory
        self.weatherRepositoryFactory = weatherRepositoryFactory
        self.timeZoneRepositoryFactory = timeZoneRepositoryFactory
        self.currentLocationRepositoryFactory = currentLocationRepositoryFactory
        self.savedLocationsRepositoryFactory = savedLocationsRepositoryFactory
        self.syncEngineOperationsRepositoryFactory = syncEngineOperationsRepositoryFactory
        
        self.status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
        self.logger = logger
        
        kvsCancellable = NotificationCenter.default
            .publisher(for: .cloudKitRecordsUpdated, object: nil)
            .sink { [weak self] _ in
                Task(priority: .background) {
                    do {
                        try await self?.getSavedLocations(true)
                        try await self?.getWeatherForSavedLocations()
                    } catch {
                        // TODO: - Replace with proper error-handling
                        print(error.localizedDescription)
                    }
                }
            }
        
        do {
            let location = try currentLocationRepositoryFactory().getCurrentLocation()
            self.currentLocation = location
            // only retrieve weather info if the location isn't outdated since it will be retrieved otherwise
            if !location.isOutdated() {
                getWeather(for: location)
            } else {
                throw CurrentLocationError.outdated
            }
        } catch {
            logger.error("\(error)")
            refreshCurrentLocation(requestingAuthorisation: false)
        }
    }
    
    func getSavedLocations(_ animated: Bool = false) async throws {
        let savedLocationsRepository = savedLocationsRepositoryFactory()
        let locations = try await savedLocationsRepository.getSavedLocations()
        
        await MainActor.run {
            if animated {
                withAnimation {
                    self.locations = locations
                }
            } else {
                self.locations = locations
            }
        }
    }
    
    func refreshStatus() {
        status = userLocationAuthorisationRepositoryFactory().getAuthorisationStatus()
    }
    
    func refreshCurrentLocation(requestingAuthorisation requestAuthorisation: Bool) {
        currentLocationNeedsRefresh = true
        let userLocationAuthorisationRepository = userLocationAuthorisationRepositoryFactory()
        let userLocationCoordinatesRepository = userLocationCoordinatesRepositoryFactory()
        let locationsRepository = locationsRepositoryFactory()
        let timeZoneRepository = timeZoneRepositoryFactory()
        let weatherRepository = weatherRepositoryFactory()
        
        Task(priority: .userInitiated) {
            do {
                let status = await {
                    if requestAuthorisation {
                        let status = await userLocationAuthorisationRepository.requestLocationAuthorisation()
                        await MainActor.run {
                            self.status = status
                        }
                        return status
                    } else {
                        return userLocationAuthorisationRepository.getAuthorisationStatus()
                    }
                }()
                
                if status.isAuthorised() {
                    let coordinates = try await userLocationCoordinatesRepository.getUserLocationCoordinates()
                    let locations = try await locationsRepository.getLocations(at: coordinates)
                    
                    guard var location = locations.first else {
                        throw LocationError.notFound
                    }
                    
                    let weather = try await weatherRepository.getWeather(for: location)
                    
                    if location.timeZoneIdentifier == nil {
                        let timeZoneIdentifier = try await timeZoneRepository.getTimeZone(for: location)
                        location.timeZoneIdentifier = timeZoneIdentifier
                    }
                    
                    try self.currentLocationRepositoryFactory().saveCurrentLocation(location)
                    
                    await MainActor.run {
                        // TODO: - replace once actor implementation is done
                        var constantWeatherCache = self.weatherCache
                        self.currentLocation = location
                        constantWeatherCache[location.fullName] = weather
                        self.weatherCache = constantWeatherCache
                        self.currentLocationNeedsRefresh = false
                    }
                }
            } catch {
                print(error.localizedDescription)
                currentLocationNeedsRefresh = false
            }
        }
    }
    
    func isCurrentLocationOutdated() -> Bool {
        currentLocation?.isOutdated() ?? true
    }
    
    func shouldDisplayProgressIndicator() -> Bool {
        (currentLocation == nil || currentLocation?.isOutdated() == true) && status.isAuthorised() && currentLocationNeedsRefresh
    }
    
    func hasSearchResults() -> Bool {
        !searchResults.isEmpty || !searchText.isEmpty
    }
    
    func update(_ location: Location, completion: @escaping (TimeZoneIdentifier) -> Void) {
        let weatherRepository = weatherRepositoryFactory()
        let timeZoneRepository = timeZoneRepositoryFactory()
        
        Task(priority: .background) {
            let weather = try await weatherRepository.getWeather(for: location)
            let timeZone: TimeZoneIdentifier? = try await {
                if location.timeZoneIdentifier != nil {
                    return nil
                }
                return try await timeZoneRepository.getTimeZone(for: location)
            }()
            
            await MainActor.run {
                // TODO: - replace once actor implementation is done
                var tempWeather = weatherCache
                tempWeather[location.fullName] = weather
                self.weatherCache = tempWeather
                if let timeZone {
                    completion(timeZone)
                }
            }
        }
    }
    
    func performSearch(for query: String) {
        guard query.count > 2 else {
            searchResults = []
            return
        }
        
        Task(priority: .background) {
            let locationsRepository = locationsRepositoryFactory()
            let locations = try await locationsRepository.getLocations(named: query)
            
            await MainActor.run {
                self.searchResults = locations
            }
        }
    }
    
    func search(for query: String) {
        searchCancellable?.cancel()
        searchCancellable = searchSubject
            .debounce(
                for: .milliseconds(600),
                scheduler: DispatchQueue.main
            )
            .sink { searchQuery in
                self.performSearch(for: searchQuery)
            }
        searchSubject.send(query)
    }
    
    func getWeather(for location: Location) {
        Task(priority: .background) {
            let weatherRepository = weatherRepositoryFactory()
            let weather = try await weatherRepository.getWeather(for: location)
            weatherCache[location.fullName] = weather
        }
    }
    
    func getWeatherForSavedLocations() async throws {
        let weatherRepository = weatherRepositoryFactory()
        var weatherInfo = [String: WeatherProtocol]()
        
        for location in locations {
            guard weatherCache[location.fullName] == nil else {
                continue
            }
            
            do {
                let weather = try await weatherRepository.getWeather(for: location)
                weatherInfo[location.fullName] = weather
            } catch {
                continue
            }
        }
        
        let constantWeatherInfo = weatherInfo
        
        await MainActor.run {
            constantWeatherInfo.forEach { fullName, location in
                weatherCache[fullName] = location
            }
        }
    }
    
    func weather(for location: Location) -> Binding<WeatherProtocol?> {
        Binding(
            get: { [weak self] in
                self?.weatherCache[location.fullName]
            },
            set: { [weak self] weather in
                self?.weatherCache[location.fullName] = weather
            }
        )
    }
    
    /**
     Handles the addition of a new location to the locations array.
     
     The returned array is used to revert things if the repository's add operation fails.
     
     - Returns: The locations array before the modification was performed.
     - Parameter location: The new location to be added to the user's saved locations,
     */
    private func performLocalAdd(of location: Location) -> [Location] {
        withAnimation {
            let setting: MaxLocations = Settings.currentValue(for: Settings.maxLocations)
            let maxLocations = setting.amount
            var tempLocations = locations
            let oldLocations = locations
            
            if locations.count == maxLocations {
                tempLocations.removeLast()
            }
            
            tempLocations.insert(location, at: 0)
            locations = tempLocations
            
            return oldLocations
        }
    }
    
    func add(_ location: Location, oldLocations: [Location]) {
        let savedLocationsRepository = savedLocationsRepositoryFactory()
        let weatherRepository = weatherRepositoryFactory()
        let timeZoneRepository = timeZoneRepositoryFactory()
        let syncEngineOperationsRepository = syncEngineOperationsRepositoryFactory()
        var variableLocation = location
        var locations = locations
        
        Task(priority: .utility) { [ weak self] in
            do {
                let weather = try await weatherRepository.getWeather(for: variableLocation)
                let timeZoneIdentifier: TimeZoneIdentifier? = try await {
                    if variableLocation.timeZoneIdentifier != nil {
                        return nil
                    }
                    return try await timeZoneRepository.getTimeZone(for: variableLocation)
                }()
                
                if let timeZoneIdentifier {
                    variableLocation.timeZoneIdentifier = timeZoneIdentifier
                }
                
//                variableLocation.lastModified = .now
                if let index = locations.firstIndex(where: { $0.id == variableLocation.id }) {
                    locations[index] = variableLocation
                }
                locations = self?.adjustedPositions(of: locations) ?? []
                for var location in locations {
                    location.lastModified = .now
                }
                try await savedLocationsRepository.setLocations(to: locations)
                try await syncEngineOperationsRepository.saveRecords(of: locations)
                
                await MainActor.run {
                    // TODO: - replace once actor implementation is done
                    if let index = locations.firstIndex(of: location) {
                        var tempLocations = locations
                        tempLocations[index] = variableLocation
                        locations = tempLocations
                    }
                    
                    var tempWeather = weatherCache
                    tempWeather[variableLocation.fullName] = weather
                    self?.weatherCache = tempWeather
                }
            } catch {
                logger.log("Adding saved location failed: \(error)")
                self?.locations = oldLocations
            }
        }
    }
    
    func displayToastForAdditionOf(_ location: Location) {
        toastShouldPerformOnDismissAction = true
        var old = [Location]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            let toast = Toast(
                style: .success,
                title: "Location Added",
                message: "Added \(location.nickname) to Locations".grantAttributes(to: location.nickname, values: Location.toastMessageAttributeValues),
                trailingButton: .init(
                    style: .text("Undo")
                ) {
                    self?.undoLocationsChange(from: old)
                }
            ) {
                self?.add(location, oldLocations: old)
            }
            self?.setToast(to: toast)
            old = self?.performLocalAdd(of: location) ?? []
        }
    }
    
    /**
     Handles the deletion of a location from the locations array.
     
     The returned array is used to revert things if the repository's delete operation fails.
     
     - Returns: The locations array before the modification was performed.
     - Parameter location: The location to be removed from the user's saved locations,
     */
    func performLocalDelete(of location: Location) -> [Location] {
        withAnimation {
            var tempLocations = locations
            let oldLocations = locations
            
            if let index = tempLocations.firstIndex(of: location) {
                tempLocations.remove(at: index)
            }
            
            locations = tempLocations
            return oldLocations
        }
    }
    
    func delete(_ location: Location, oldLocations: [Location]) {
        let savedLocationsRepository = savedLocationsRepositoryFactory()
        let syncEngineOperationsRepository = syncEngineOperationsRepositoryFactory()
        
        Task(priority: .userInitiated) { [weak self] in
            do {
                var location = location
                location.lastModified = .now
                var locations = self?.locations ?? []
                if let index = locations.firstIndex(where: { $0.id == location.id }) {
                    locations.remove(at: index)
                }
                locations = self?.adjustedPositions(of: locations) ?? []
                for var location in locations {
                    location.lastModified = .now
                }
                try await savedLocationsRepository.delete(location)
                try await syncEngineOperationsRepository.deleteRecord(of: location)
                try await syncEngineOperationsRepository.saveRecords(of: locations)
            } catch {
                logger.log("Deleting saved location failed: \(error)")
                self?.locations = oldLocations
            }
        }
    }
    
    func displayToastForRemovalOf(_ location: Location) {
        toastShouldPerformOnDismissAction = true
        var old = [Location]()
        let toast = Toast(
            style: .delete,
            title: "Location Removed",
            message: "Removed \(location.nickname) from Locations".grantAttributes(to: location.nickname, values: Location.toastMessageAttributeValues),
            trailingButton: .init(
                style: .text("Undo")
            ) {
                self.undoLocationsChange(from: old)
            }
        ) {
            self.delete(location, oldLocations: old)
        }
        setToast(to: toast)
        old = performLocalDelete(of: location)
    }
    
    func undoLocationsChange(from old: [Location]) {
        withAnimation {
            locations = old
            toastShouldPerformOnDismissAction = false
            displayedToast = nil
        }
    }
    
    func move(from offsets: IndexSet, to offset: Int) {
        withAnimation {
            locations.move(fromOffsets: offsets, toOffset: offset)
        }
    }
    
    private func adjustedPositions(of locations: [Location]) -> [Location] {
        zip(0..<locations.count, locations).map { $1.atPosition($0) }
    }
    
    func onMoveCompletion() {
        locations = adjustedPositions(of: locations)
        let savedLocationsRepository = savedLocationsRepositoryFactory()
        let syncEngineOperationsRepository = syncEngineOperationsRepositoryFactory()
        
        Task(priority: .userInitiated) { [weak self] in
            do {
                var locations = self?.locations ?? []
                for var location in locations {
                    location.lastModified = .now
                }
                try await savedLocationsRepository.setLocations(to: locations)
                try await syncEngineOperationsRepository.saveRecords(of: locations)
            } catch {
                logger.log("Deleting saved location failed: \(error)")
                #warning("Need to undo changes here")
            }
        }
    }
    
    func editNickname(ofLocationAt index: Int, to nickname: String) {
        locations[index].nickname = nickname
        let savedLocationsRepository = savedLocationsRepositoryFactory()
        let syncEngineOperationsRepository = syncEngineOperationsRepositoryFactory()
        
        Task(priority: .userInitiated) {
            do {
                var location = self.locations[index]
                location.lastModified = .now
                try await savedLocationsRepository.changeNickname(ofLocationAt: index, to: nickname)
                try await syncEngineOperationsRepository.saveRecord(of: location)
            } catch {
                logger.log("Deleting saved location failed: \(error)")
                #warning("Need to undo changes here")
            }
        }
    }
    
    func updateMaxNumberOfDisplayedLocations(to maxLocations: MaxLocations) {
        let savedLocationsRepository = savedLocationsRepositoryFactory()
        let syncEngineOperationsRepository = syncEngineOperationsRepositoryFactory()
        let maxLocations = maxLocations.amount
        
        if locations.count > maxLocations {
            let numberToRemove = locations.count - maxLocations
            let locationsToRemove = Array(locations[(locations.count - numberToRemove)...(locations.count - 1)])
            locations.removeLast(numberToRemove)
            Task {
                try await savedLocationsRepository.setLocations(to: locations)
                try await syncEngineOperationsRepository.deleteRecords(of: locationsToRemove)
            }
        }
    }
    
    func setToast(to value: Toast) {
        displayedToast = nil
        withAnimation {
            displayedToast = value
        }
    }
}

#warning("Use a better Error type?")
enum CurrentLocationError: Error {
    case outdated
}
