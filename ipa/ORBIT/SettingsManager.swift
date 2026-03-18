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
        // 不在初始化时自动加载，延迟到后台线程
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let self = self {
                let savedDays = UserDefaults.standard.integer(forKey: self.daysKey)
                let savedElevation = UserDefaults.standard.integer(forKey: self.elevationThresholdKey)
                let savedTimeFilter = UserDefaults.standard.bool(forKey: self.timeFilterKey)
                let savedUTC = UserDefaults.standard.bool(forKey: self.utcTimeKey)
                
                DispatchQueue.main.async {
                    self.days = savedDays == 0 ? 3 : savedDays
                    self.elevationThreshold = savedElevation == 0 ? 15 : savedElevation
                    self.timeFilter = savedTimeFilter
                    self.utcTime = savedUTC
                }
            }
        }
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