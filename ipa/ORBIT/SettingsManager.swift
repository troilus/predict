import Foundation
import SwiftUI
import Combine

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    @Published var days: Int = 3
    @Published var elevationThreshold: Int = 15
    @Published var timeFilter: Bool = false
    @Published var utcTime: Bool = false
    
    private let daysKey = "settings_days"
    private let elevationThresholdKey = "settings_elevation_threshold"
    private let timeFilterKey = "settings_time_filter"
    private let utcTimeKey = "settings_utc_time"
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        days = UserDefaults.standard.integer(forKey: daysKey)
        if days == 0 { days = 3 }
        
        elevationThreshold = UserDefaults.standard.integer(forKey: elevationThresholdKey)
        if elevationThreshold == 0 { elevationThreshold = 15 }
        
        timeFilter = UserDefaults.standard.bool(forKey: timeFilterKey)
        utcTime = UserDefaults.standard.bool(forKey: utcTimeKey)
    }
    
    func saveSettings() {
        UserDefaults.standard.set(days, forKey: daysKey)
        UserDefaults.standard.set(elevationThreshold, forKey: elevationThresholdKey)
        UserDefaults.standard.set(timeFilter, forKey: timeFilterKey)
        UserDefaults.standard.set(utcTime, forKey: utcTimeKey)
    }
    
    func resetToDefaults() {
        days = 3
        elevationThreshold = 15
        timeFilter = false
        utcTime = false
        saveSettings()
    }
}