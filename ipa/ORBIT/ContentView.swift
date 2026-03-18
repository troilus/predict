import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var tleDataManager: TLEDataManager
    @EnvironmentObject var languageManager: LanguageManager

    @StateObject private var passPredictionManager = PassPredictionManager()
    @StateObject private var favoritesManager = FavoritesManager()

    @State private var searchText = ""
    @State private var selectedSatellite: Satellite?
    @State private var showingTrackingView = false
    @State private var showingFavorites = false

    @State private var daysFilter = 3
    @State private var elevationFilter = 15
    @State private var useNightTimeOnly = false
    @State private var useUTC = false

    @State private var showingLanguageSelector = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: colorScheme == .dark ?
                        [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.1)] :
                        [Color(red: 0.95, green: 0.95, blue: 1.0), Color(red: 0.9, green: 0.9, blue: 0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Search Bar
                    searchBar

                    // Popular Satellites
                    popularSatellitesSection

                    // Filters
                    filtersView

                    // Buttons
                    actionButtons

                    // Location Info
                    locationInfoView

                    // Pass Predictions
                    predictionsList

                    Spacer()

                    // Footer
                    footerView
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingTrackingView) {
            if let satellite = selectedSatellite,
               let location = locationManager.coordinates {
                TrackingView(
                    satellite: satellite,
                    location: location
                )
            }
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView()
                .environmentObject(favoritesManager)
                .environmentObject(tleDataManager)
                .environmentObject(locationManager)
                .environmentObject(languageManager)
        }
        .actionSheet(isPresented: $showingLanguageSelector) {
            ActionSheet(
                title: Text(Localization.localizedString(for: "language", language: languageManager.currentLanguage)),
                buttons: LanguageManager.Language.allCases.map { language in
                    .default(Text(language.displayName)) {
                        languageManager.setLanguage(language)
                    }
                } + [.cancel()]
            )
        }
    }

    private var colorScheme: ColorScheme {
        // Check system color scheme
        #if os(iOS)
        return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        #else
        return .light
        #endif
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Localization.localizedString(for: "app_title", language: languageManager.currentLanguage))
                    .font(.title)
                    .fontWeight(.bold)

                Button(action: {
                    showingLanguageSelector = true
                }) {
                    Text(languageManager.currentLanguage.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: {
                showingFavorites = true
            }) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
            }
        }
        .padding()
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                Localization.localizedString(for: "search_placeholder", language: languageManager.currentLanguage),
                text: $searchText
            )
            .textFieldStyle(PlainTextFieldStyle())
            .autocapitalization(.none)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.1))
        )
        .padding(.horizontal)
    }

    // MARK: - Popular Satellites

    private var popularSatellitesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localization.localizedString(for: "popular_satellites", language: languageManager.currentLanguage))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tleDataManager.getPopularSatellites()) { satellite in
                        SatelliteCard(
                            satellite: satellite,
                            isSelected: selectedSatellite?.id == satellite.id,
                            onTap: {
                                selectedSatellite = satellite
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Filters

    private var filtersView: some View {
        VStack(spacing: 12) {
            // Days Filter
            HStack {
                Text(Localization.localizedString(for: "days_label", language: languageManager.currentLanguage))
                    .font(.subheadline)

                Picker("", selection: $daysFilter) {
                    ForEach([1, 3, 5, 10, 15], id: \.self) { days in
                        Text("\(days)").tag(days)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Spacer()
            }

            // Elevation Filter
            HStack {
                Text(Localization.localizedString(for: "elevation_label", language: languageManager.currentLanguage))
                    .font(.subheadline)

                Picker("", selection: $elevationFilter) {
                    ForEach([0, 10, 15, 20, 25, 30, 35, 40, 45], id: \.self) { elevation in
                        Text("\(elevation)°").tag(elevation)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Spacer()
            }

            // Toggle Filters
            HStack {
                Toggle(
                    Localization.localizedString(for: "time_filter_label", language: languageManager.currentLanguage),
                    isOn: $useNightTimeOnly
                )

                Spacer()

                Toggle(
                    Localization.localizedString(for: "utc_filter_label", language: languageManager.currentLanguage),
                    isOn: $useUTC
                )
            }
            .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.05))
        )
        .padding(.horizontal)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                if let satellite = selectedSatellite {
                    passPredictionManager.daysToPredict = daysFilter
                    passPredictionManager.minElevation = Double(elevationFilter)
                    passPredictionManager.useNightTimeOnly = useNightTimeOnly
                    passPredictionManager.predictPasses(
                        for: satellite,
                        at: locationManager.coordinates ?? (39.9042, 116.4074, 50.0)
                    )
                }
            }) {
                Text(Localization.localizedString(for: "show_selected", language: languageManager.currentLanguage))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedSatellite != nil ? Color.blue : Color.gray)
                    )
            }
            .disabled(selectedSatellite == nil)

            Button(action: {
                showingFavorites = true
            }) {
                Text(Localization.localizedString(for: "show_favorites", language: languageManager.currentLanguage))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(favoritesManager.favorites.isEmpty ? Color.gray : Color.green)
                    )
            }
            .disabled(favoritesManager.favorites.isEmpty)
        }
        .padding(.horizontal)
    }

    // MARK: - Location Info

    private var locationInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let location = locationManager.coordinates {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)

                    Text(String(format: "%.4f, %.4f", location.latitude, location.longitude))
                        .font(.subheadline)

                    Spacer()

                    if locationManager.authorizationStatus == .authorizedWhenInUse ||
                       locationManager.authorizationStatus == .authorizedAlways {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "location.slash")
                        .foregroundColor(.red)

                    Text(Localization.localizedString(for: "no_location", language: languageManager.currentLanguage))
                        .font(.subheadline)

                    Spacer()

                    Button(action: {
                        locationManager.requestLocation()
                    }) {
                        Text(Localization.localizedString(for: "retry", language: languageManager.currentLanguage))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }

            // Notes
            Text(Localization.localizedString(for: "notes", language: languageManager.currentLanguage))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.05))
        )
        .padding(.horizontal)
    }

    // MARK: - Predictions List

    private var predictionsList: some View {
        Group {
            if passPredictionManager.isCalculating {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text(Localization.localizedString(for: "calculating", language: languageManager.currentLanguage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            } else if let error = passPredictionManager.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .font(.title)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if passPredictionManager.predictedPasses.isEmpty {
                VStack {
                    Image(systemName: "satellite")
                        .foregroundColor(.secondary)
                        .font(.title)
                    Text(Localization.localizedString(for: "no_passes", language: languageManager.currentLanguage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(passPredictionManager.predictedPasses) { pass in
                        PassRow(
                            pass: pass,
                            language: languageManager.currentLanguage,
                            onTap: {
                                selectedSatellite = tleDataManager.satellites.first { $0.name == pass.satelliteName }
                                showingTrackingView = true
                            },
                            onDateTap: {
                                addToCalendar(pass: pass)
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 4) {
            Text("Made with ❤ by bd8ckf")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("https://github.com/troilus/predict")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
    }

    // MARK: - Helper Functions

    private func addToCalendar(pass: PassInfo) {
        // Implementation for adding pass to calendar
        // This would require EventKit framework
        print("Adding pass to calendar: \(pass.satelliteName) at \(pass.maxElevationTime)")
    }
}

// MARK: - Satellite Card

struct SatelliteCard: View {
    let satellite: Satellite
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "satellite")
                .foregroundColor(isSelected ? .blue : .secondary)
                .font(.title2)

            Text(satellite.name)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Pass Row

struct PassRow: View {
    let pass: PassInfo
    let language: LanguageManager.Language
    let onTap: () -> Void
    let onDateTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pass.satelliteName)
                    .font(.headline)
                Spacer()
                Text(pass.durationFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Button(action: onDateTap) {
                    Text(pass.startTimeFormatted)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Spacer()

                Text(String(format: "%.1f°", pass.maxElevation))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(pass.maxElevation > 45 ? Color.green :
                                  pass.maxElevation > 30 ? Color.blue :
                                  pass.maxElevation > 15 ? Color.orange : Color.red)
                    )
                    .foregroundColor(.white)

                Text(String(format: "%.1f°", pass.maxElevationAzimuth))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: onTap) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                }
            }

            Text(Localization.localizedString(for: "max_elevation", language: language) + ": \(pass.maxElevationTimeFormatted)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.05))
        )
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
            .environmentObject(TLEDataManager())
            .environmentObject(LanguageManager())
    }
}