import SwiftUI

@main
struct ORBITApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var tleDataManager = TLEDataManager()
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(tleDataManager)
                .environmentObject(languageManager)
        }
    }
}