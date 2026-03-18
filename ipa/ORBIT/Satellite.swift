import Foundation

// MARK: - Satellite Model
struct Satellite: Identifiable, Codable {
    let id: Int
    let name: String
    let tle: [String] // Two-line orbital element
    let catalogNumber: String?
    let internationalDesignator: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tle
        case catalogNumber = "catalog_number"
        case internationalDesignator = "international_designator"
    }
}

// MARK: - Satellite Position
struct SatellitePosition {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let azimuth: Double
    let elevation: Double
    let range: Double
    let rangeRate: Double
    let velocity: [Double]
    let timestamp: Date
}

// MARK: - Pass Info
struct PassInfo: Identifiable, Codable {
    let id = UUID()
    let satelliteName: String
    let startTime: Date
    let endTime: Date
    let maxElevationTime: Date
    let maxElevation: Double
    let maxElevationAzimuth: Double
    let maxElevationLatitude: Double
    let maxElevationLongitude: Double
    let duration: TimeInterval

    enum CodingKeys: String, CodingKey {
        case satelliteName
        case startTime
        case endTime
        case maxElevationTime
        case maxElevation
        case maxElevationAzimuth
        case maxElevationLatitude
        case maxElevationLongitude
        case duration
    }

    var durationFormatted: String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(seconds)s"
    }

    var startTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: startTime)
    }

    var maxElevationTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: maxElevationTime)
    }
}