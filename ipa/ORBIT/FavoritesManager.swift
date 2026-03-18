import Foundation
import Combine
import SwiftUI

// MARK: - Favorites Manager
class FavoritesManager: ObservableObject {
    @Published var favorites: [Satellite] = []

    private let favoritesKey = "favorite_satellites"

    init() {
        // 不在初始化时自动加载，延迟到后台线程
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let self = self {
                if let data = UserDefaults.standard.data(forKey: self.favoritesKey),
                   let favorites = try? JSONDecoder().decode([Satellite].self, from: data) {
                    DispatchQueue.main.async {
                        self.favorites = favorites
                    }
                }
            }
        }
    }

    // MARK: - Load Favorites

    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode([Satellite].self, from: data) {
            self.favorites = favorites
        }
    }

    // MARK: - Save Favorites

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    // MARK: - Add/Remove Favorite

    func addFavorite(_ satellite: Satellite) {
        if !favorites.contains(where: { $0.id == satellite.id }) {
            favorites.append(satellite)
            saveFavorites()
        }
    }

    func removeFavorite(_ satellite: Satellite) {
        favorites.removeAll { $0.id == satellite.id }
        saveFavorites()
    }

    func isFavorite(_ satellite: Satellite) -> Bool {
        favorites.contains { $0.id == satellite.id }
    }

    func toggleFavorite(_ satellite: Satellite) {
        if isFavorite(satellite) {
            removeFavorite(satellite)
        } else {
            addFavorite(satellite)
        }
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var tleDataManager: TLEDataManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var languageManager: LanguageManager

    @StateObject private var passPredictionManager = PassPredictionManager()
    @State private var selectedFavorite: Satellite?

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
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .font(.title2)
                        }

                        Text(Localization.localizedString(for: "favorites", language: languageManager.currentLanguage))
                            .font(.headline)

                        Spacer()
                    }
                    .padding()

                    // Favorites List
                    if favoritesManager.favorites.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "star.slash")
                                .foregroundColor(.secondary)
                                .font(.title)

                            Text(Localization.localizedString(for: "no_favorites", language: languageManager.currentLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(favoritesManager.favorites) { satellite in
                                FavoriteRow(
                                    satellite: satellite,
                                    language: languageManager.currentLanguage,
                                    onRemove: {
                                        favoritesManager.removeFavorite(satellite)
                                    },
                                    onShowPasses: {
                                        selectedFavorite = satellite
                                        showPasses(for: satellite)
                                    }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var colorScheme: ColorScheme {
        #if os(iOS)
        return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        #else
        return .light
        #endif
    }

    private func showPasses(for satellite: Satellite) {
        if let location = locationManager.coordinates {
            passPredictionManager.daysToPredict = 3
            passPredictionManager.minElevation = 15.0
            passPredictionManager.predictPasses(for: satellite, at: location)
        }
    }
}

// MARK: - Favorite Row

struct FavoriteRow: View {
    let satellite: Satellite
    let language: LanguageManager.Language
    let onRemove: () -> Void
    let onShowPasses: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(satellite.name)
                    .font(.headline)

                if let catalogNumber = satellite.catalogNumber {
                    Text("Cat #: \(catalogNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }

            Button(action: onShowPasses) {
                Text(Localization.localizedString(for: "show_selected", language: language))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.05))
        )
    }
}

// MARK: - Preview

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(FavoritesManager())
            .environmentObject(TLEDataManager())
            .environmentObject(LocationManager())
            .environmentObject(LanguageManager())
    }
}