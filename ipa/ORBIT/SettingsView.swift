import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var tleDataManager: TLEDataManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Prediction Settings
                Section(header: Text(localizedString("prediction_settings"))) {
                    // Days
                    Picker(localizedString("days_label"), selection: $settingsManager.days) {
                        ForEach([1, 3, 5, 10, 15], id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    
                    // Elevation Threshold
                    Picker(localizedString("elevation_label"), selection: $settingsManager.elevationThreshold) {
                        ForEach([0, 10, 15, 20, 25, 30, 35, 40, 45], id: \.self) { elevation in
                            Text("\(elevation)°").tag(elevation)
                        }
                    }
                    
                    // Time Filter
                    Toggle(localizedString("time_filter_label"), isOn: $settingsManager.timeFilter)
                    
                    // UTC Time
                    Toggle(localizedString("utc_filter_label"), isOn: $settingsManager.utcTime)
                }
                
                // MARK: - Data Updates
                Section(header: Text(localizedString("data_updates"))) {
                    // Update TLE
                    Button(action: {
                        tleDataManager.updateTLE()
                    }) {
                        HStack {
                            Text(localizedString("update_tle"))
                            Spacer()
                            if tleDataManager.isUpdatingTLE {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(tleDataManager.isUpdatingTLE)
                    
                    if !tleDataManager.tleDownloadProgress.isEmpty {
                        Text(tleDataManager.tleDownloadProgress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Update Transmitters
                    Button(action: {
                        tleDataManager.updateTransmitters()
                    }) {
                        HStack {
                            Text(localizedString("update_transmitters"))
                            Spacer()
                            if tleDataManager.isUpdatingTransmitters {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(tleDataManager.isUpdatingTransmitters)
                    
                    if !tleDataManager.transmittersDownloadProgress.isEmpty {
                        Text(tleDataManager.transmittersDownloadProgress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Reset
                Section {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        Text(localizedString("reset_settings"))
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: - Info
                Section(header: Text(localizedString("app_info"))) {
                    HStack {
                        Text(localizedString("app_version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(localizedString("tle_version"))
                        Spacer()
                        Text(tleDataManager.tleVersion.isEmpty ? "N/A" : tleDataManager.tleVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(localizedString("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizedString("done")) {
                        settingsManager.saveSettings()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(localizedString("reset_settings"), isPresented: $showResetAlert) {
                Button(localizedString("cancel"), role: .cancel) { }
                Button(localizedString("reset"), role: .destructive) {
                    settingsManager.resetToDefaults()
                }
            } message: {
                Text(localizedString("reset_settings_confirm"))
            }
        }
    }
    
    private func localizedString(_ key: String) -> String {
        return Localization.localizedString(for: key, language: languageManager.currentLanguage)
    }
}

// MARK: - Preview
#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // 不要在 preview 中创建实例，避免初始化问题
        EmptyView()
    }
}
#endif