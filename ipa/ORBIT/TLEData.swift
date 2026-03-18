import Foundation
import Combine

// MARK: - TLE Data Manager
class TLEDataManager: ObservableObject {
    @Published var satellites: [Satellite] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var isUpdatingTLE = false
    @Published var isUpdatingTransmitters = false
    @Published var tleDownloadProgress = ""
    @Published var transmittersDownloadProgress = ""
    @Published var tleVersion = ""

    private let tleDataURL = "https://sat.xanyi.eu.org/satdata/satonline.txt"
    private let transmittersURL = "https://sat.xanyi.eu.org/satdata/transmitters.json"

    init() {
        // Delay loading to avoid issues during initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadSatellites()
        }
    }

    // MARK: - Load TLE Data

    func loadSatellites() {
        isLoading = true
        error = nil

        // Try to load from local storage first
        if let cachedData = loadFromCache() {
            self.satellites = cachedData
            isLoading = false
        }

        // Fetch fresh data from server
        fetchTLEData()
    }

    private func fetchTLEData() {
        guard let url = URL(string: tleDataURL) else {
            self.error = "Invalid URL"
            self.isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
                return
            }

            guard let data = data,
                  let text = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.error = "Failed to parse TLE data"
                    self.isLoading = false
                }
                return
            }

            let satellites = self.parseTLEData(text: text)

            DispatchQueue.main.async {
                self.satellites = satellites
                self.saveToCache(satellites)
                self.isLoading = false
            }
        }

        task.resume()
    }

    private func parseTLEData(text: String) -> [Satellite] {
        var satellites: [Satellite] = []
        let lines = text.components(separatedBy: .newlines)

        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)

            // Skip empty lines
            if line.isEmpty {
                i += 1
                continue
            }

            // Check if this is a satellite name line (not starting with '1' or '2')
            if !line.hasPrefix("1") && !line.hasPrefix("2") {
                // This is a satellite name
                let name = line

                // Get the next two lines (TLE lines)
                if i + 2 < lines.count {
                    let tleLine1 = lines[i + 1].trimmingCharacters(in: .whitespaces)
                    let tleLine2 = lines[i + 2].trimmingCharacters(in: .whitespaces)

                    // Validate TLE lines
                    if tleLine1.hasPrefix("1") && tleLine2.hasPrefix("2") {
                        // Extract catalog number from line 1
                        let catalogNumber = String(tleLine1[2..<8])

                        let satellite = Satellite(
                            id: Int(catalogNumber) ?? 0,
                            name: name,
                            tle: [tleLine1, tleLine2],
                            catalogNumber: catalogNumber,
                            internationalDesignator: nil
                        )
                        satellites.append(satellite)

                        i += 3
                        continue
                    }
                }
            }

            i += 1
        }

        return satellites
    }

    // MARK: - Cache Management

    private func cacheURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("satellites_cache.json")
    }

    private func saveToCache(_ satellites: [Satellite]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(satellites)
            try data.write(to: cacheURL())
        } catch {
            print("Failed to save cache: \(error)")
        }
    }

    private func loadFromCache() -> [Satellite]? {
        do {
            let data = try Data(contentsOf: cacheURL())
            let decoder = JSONDecoder()
            return try decoder.decode([Satellite].self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Search

    func searchSatellites(query: String) -> [Satellite] {
        guard !query.isEmpty else { return satellites }

        let lowercasedQuery = query.lowercased()
        return satellites.filter { satellite in
            satellite.name.lowercased().contains(lowercasedQuery) ||
            satellite.catalogNumber?.contains(lowercasedQuery) ?? false
        }
    }

    // MARK: - Update TLE Data
    
    func updateTLE() {
        isUpdatingTLE = true
        tleDownloadProgress = ""
        
        guard let url = URL(string: tleDataURL) else {
            DispatchQueue.main.async {
                self.error = "Invalid URL"
                self.isUpdatingTLE = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isUpdatingTLE = false
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.error = "Failed to download TLE data"
                    self.isUpdatingTLE = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.error = "No data received"
                    self.isUpdatingTLE = false
                }
                return
            }
            
            // Calculate progress
            let downloadedKB = Double(data.count) / 1024.0
            let totalSize = httpResponse.expectedContentLength > 0 ? Double(httpResponse.expectedContentLength) / 1024.0 : downloadedKB
            let progressText = String(format: "%.1f KB / %.1f KB", downloadedKB, totalSize)
            
            guard let text = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.error = "Failed to parse TLE data"
                    self.isUpdatingTLE = false
                }
                return
            }
            
            // Extract TLE version from first line
            let lines = text.components(separatedBy: .newlines)
            if let firstLine = lines.first, firstLine.count >= 32 {
                let epoch = String(firstLine[18..<32])
                self.tleVersion = epoch
            }
            
            let satellites = self.parseTLEData(text: text)
            
            DispatchQueue.main.async {
                self.satellites = satellites
                self.saveToCache(satellites)
                self.tleDownloadProgress = progressText
                self.isUpdatingTLE = false
            }
        }
        
        task.resume()
    }
    
    // MARK: - Update Transmitters Data
    
    func updateTransmitters() {
        isUpdatingTransmitters = true
        transmittersDownloadProgress = ""
        
        guard let url = URL(string: transmittersURL) else {
            DispatchQueue.main.async {
                self.error = "Invalid URL"
                self.isUpdatingTransmitters = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isUpdatingTransmitters = false
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.error = "Failed to download transmitters data"
                    self.isUpdatingTransmitters = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.error = "No data received"
                    self.isUpdatingTransmitters = false
                }
                return
            }
            
            // Calculate progress
            let downloadedKB = Double(data.count) / 1024.0
            let totalSize = httpResponse.expectedContentLength > 0 ? Double(httpResponse.expectedContentLength) / 1024.0 : downloadedKB
            let progressText = String(format: "%.1f KB / %.1f KB", downloadedKB, totalSize)
            
            // Save transmitters data to cache
            self.saveTransmittersToCache(data)
            
            DispatchQueue.main.async {
                self.transmittersDownloadProgress = progressText
                self.isUpdatingTransmitters = false
            }
        }
        
        task.resume()
    }
    
    private func saveTransmittersToCache(_ data: Data) {
        let fileManager = FileManager.default
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDir.appendingPathComponent("transmitters.json")
        
        try? data.write(to: fileURL)
    }

    // MARK: - Popular Satellites

    func getPopularSatellites() -> [Satellite] {
        let popularNames = [
            "ISS (ZARYA)",
            "NOAA 19",
            "NOAA 18",
            "NOAA 15",
            "METEOR-M 2",
            "METEOR-M 2 2",
            "FENGYUN 3C",
            "HINODE",
            "SOHO",
            "GOES 16",
            "GOES 17",
            "FALCONSAT-3",
            "AO-91",
            "AO-92",
            "LILACSAT-1",
            "CAS-4B",
            "FUNCUBE-1",
            "AO-7",
            "AO-73",
            "FO-29"
        ]

        return popularNames.compactMap { name in
            satellites.first { $0.name.uppercased().contains(name.uppercased()) }
        }
    }
}

// MARK: - String Extension
extension String {
    subscript(_ range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
}