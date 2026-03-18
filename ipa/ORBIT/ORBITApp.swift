import SwiftUI

@main
struct ORBITApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var tleDataManager = TLEDataManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var settingsManager = SettingsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(tleDataManager)
                .environmentObject(languageManager)
                .environmentObject(settingsManager)
        }
    }
}