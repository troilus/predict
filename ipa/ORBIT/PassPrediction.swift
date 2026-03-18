import Foundation
import Combine

// MARK: - Pass Prediction Manager
class PassPredictionManager: ObservableObject {
    @Published var predictedPasses: [PassInfo] = []
    @Published var isCalculating = false
    @Published var error: String?

    private var calculator = SatelliteCalculator()
    private var cancellables = Set<AnyCancellable>()

    // Configuration
    var daysToPredict: Int = 3
    var minElevation: Double = 15.0
    var useNightTimeOnly: Bool = false
    var useUTC: Bool = false

    func predictPasses(for satellite: Satellite, at location: (latitude: Double, longitude: Double, altitude: Double)) {
        isCalculating = true
        error = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let passes = try self.calculatePasses(
                    satellite: satellite,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    altitude: location.altitude
                )

                DispatchQueue.main.async {
                    self.predictedPasses = passes
                    self.isCalculating = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isCalculating = false
                }
            }
        }
    }

    private func calculatePasses(satellite: Satellite, latitude: Double, longitude: Double, altitude: Double) throws -> [PassInfo] {
        var passes: [PassInfo] = []
        let startTime = Date()
        let endTime = Calendar.current.date(byAdding: .day, value: daysToPredict, to: startTime)!

        // Create satellite record
        let satrec = calculator.twoline2satrec(tleLine1: satellite.tle[0], tleLine2: satellite.tle[1])

        // Sample every 5 minutes to find passes
        var currentTime = startTime
        var inPass = false
        var passStart: Date?
        var passMaxElevation: Double = 0
        var passMaxElevationTime: Date?
        var passMaxElevationAzimuth: Double = 0
        var passMaxElevationLat: Double = 0
        var passMaxElevationLon: Double = 0

        while currentTime < endTime {
            let positionAndVelocity = calculator.propagate(
                satrec: satrec,
                date: currentTime
            )

            let gmst = calculator.gmst(date: currentTime)
            let positionGd = calculator.eciToGeodetic(
                positionEci: positionAndVelocity.position,
                gmst: gmst
            )

            let observerGd = SatelliteCalculator.GeodeticCoordinate(
                latitude: latitude * .pi / 180,
                longitude: longitude * .pi / 180,
                height: altitude / 1000
            )

            let lookAngles = calculator.eciToLookAngles(
                observerGd: observerGd,
                positionEci: positionAndVelocity.position,
                gmst: gmst
            )

            let elevation = lookAngles.elevation * 180 / .pi
            let azimuth = lookAngles.azimuth * 180 / .pi

            // Check if satellite is above minimum elevation
            if elevation >= minElevation {
                if !inPass {
                    // Start of a new pass
                    inPass = true
                    passStart = currentTime
                    passMaxElevation = elevation
                    passMaxElevationTime = currentTime
                    passMaxElevationAzimuth = azimuth
                    passMaxElevationLat = positionGd.latitude * 180 / .pi
                    passMaxElevationLon = positionGd.longitude * 180 / .pi
                } else {
                    // Check if this is the maximum elevation
                    if elevation > passMaxElevation {
                        passMaxElevation = elevation
                        passMaxElevationTime = currentTime
                        passMaxElevationAzimuth = azimuth
                        passMaxElevationLat = positionGd.latitude * 180 / .pi
                        passMaxElevationLon = positionGd.longitude * 180 / .pi
                    }
                }
            } else {
                if inPass {
                    // End of pass
                    inPass = false

                    // Filter by night time if enabled
                    if useNightTimeOnly {
                        let sunPosition = calculator.calculateSunPosition(
                            latitude: latitude,
                            longitude: longitude,
                            date: passMaxElevationTime!
                        )
                        if sunPosition.altitude > 0 {
                            // Sun is up, skip this pass
                            currentTime = Calendar.current.date(byAdding: .minute, value: 5, to: currentTime)!
                            continue
                        }
                    }

                    let pass = PassInfo(
                        satelliteName: satellite.name,
                        startTime: passStart!,
                        endTime: currentTime,
                        maxElevationTime: passMaxElevationTime!,
                        maxElevation: passMaxElevation,
                        maxElevationAzimuth: passMaxElevationAzimuth,
                        maxElevationLatitude: passMaxElevationLat,
                        maxElevationLongitude: passMaxElevationLon,
                        duration: currentTime.timeIntervalSince(passStart!)
                    )
                    passes.append(pass)
                }
            }

            // Move to next sample point
            currentTime = Calendar.current.date(byAdding: .minute, value: 5, to: currentTime)!
        }

        return passes
    }

    func clearPasses() {
        predictedPasses.removeAll()
        error = nil
    }
}