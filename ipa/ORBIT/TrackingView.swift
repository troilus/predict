import SwiftUI
import CoreLocation
import CoreMotion
import Combine

struct TrackingView: View {
    let satellite: Satellite
    let location: (latitude: Double, longitude: Double, altitude: Double)

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager

    @StateObject private var trackingManager = TrackingManager()

    @State private var currentPosition: SatellitePosition?
    @State private var isTracking = true

    var body: some View {
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

                // Compass
                compassView

                // Satellite Info
                satelliteInfoView

                Spacer()

                // Control Buttons
                controlButtons
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startTracking()
        }
        .onDisappear {
            stopTracking()
        }
    }

    private var colorScheme: ColorScheme {
        #if os(iOS)
        return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        #else
        return .light
        #endif
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(satellite.name)
                    .font(.headline)

                if let position = currentPosition {
                    Text(String(format: "%.2f km", position.range))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isTracking {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding()
    }

    // MARK: - Compass View

    private var compassView: some View {
        ZStack {
            // Compass background
            Circle()
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark ?
                            [Color(red: 0.2, green: 0.2, blue: 0.3), Color(red: 0.1, green: 0.1, blue: 0.2)] :
                            [Color(red: 0.9, green: 0.9, blue: 1.0), Color(red: 0.8, green: 0.8, blue: 0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                )

            // Compass ticks
            ForEach(0..<360, id: \.self) { angle in
                if angle % 30 == 0 {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: angle % 90 == 0 ? 3 : 1, height: 10)

                        if angle % 90 == 0 {
                            Text(compassLabel(for: angle))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .rotationEffect(.degrees(Double(angle)))
                    .offset(y: -120)
                }
            }

            // Direction indicator (device orientation)
            if let heading = trackingManager.currentHeading {
                Triangle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 30)
                    .rotationEffect(.degrees(-heading))
            }

            // Satellite position indicator
            if let position = currentPosition {
                let angle = position.azimuth
                let distance = 120 - (position.elevation * 120 / 90)

                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .rotationEffect(.degrees(angle))
                    .offset(y: -distance)
            }

            // Center crosshair
            Circle()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 8, height: 8)
        }
        .padding()
    }

    private func compassLabel(for angle: Int) -> String {
        switch angle {
        case 0: return "N"
        case 90: return "E"
        case 180: return "S"
        case 270: return "W"
        default: return ""
        }
    }

    // MARK: - Satellite Info View

    private var satelliteInfoView: some View {
        VStack(spacing: 12) {
            if let position = currentPosition {
                // Azimuth
                HStack {
                    Image(systemName: "compass")
                        .foregroundColor(.blue)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.localizedString(for: "azimuth", language: languageManager.currentLanguage))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.1f°", position.azimuth))
                            .font(.headline)
                    }

                    Spacer()

                    Text(compassDirection(position.azimuth))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.05))
                )

                // Elevation
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.green)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.localizedString(for: "elevation", language: languageManager.currentLanguage))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.1f°", position.elevation))
                            .font(.headline)
                    }

                    Spacer()

                    ProgressView(value: position.elevation / 90)
                        .frame(width: 100)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.05))
                )

                // Distance
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(.orange)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.localizedString(for: "distance", language: languageManager.currentLanguage))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.1f km", position.range))
                            .font(.headline)
                    }

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.05))
                )

                // Coordinates
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.purple)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latitude")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.4f°", position.latitude))
                            .font(.subheadline)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Longitude")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.4f°", position.longitude))
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.05))
                )
            }
        }
        .padding()
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                if isTracking {
                    stopTracking()
                } else {
                    startTracking()
                }
            }) {
                Label(
                    isTracking ? "Pause" : "Resume",
                    systemImage: isTracking ? "pause.fill" : "play.fill"
                )
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isTracking ? Color.orange : Color.green)
                )
            }

            Button(action: {
                // Add to calendar
            }) {
                Label(
                    Localization.localizedString(for: "calendar", language: languageManager.currentLanguage),
                    systemImage: "calendar"
                )
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                )
            }
        }
        .padding()
    }

    // MARK: - Tracking Functions

    private func startTracking() {
        isTracking = true
        trackingManager.startTracking(
            satellite: satellite,
            location: location
        )

        trackingManager.$currentPosition
            .receive(on: RunLoop.main)
            .sink { position in
                self.currentPosition = position
            }
            .store(in: &trackingManager.cancellables)
    }

    private func stopTracking() {
        isTracking = false
        trackingManager.stopTracking()
    }

    private func compassDirection(_ azimuth: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((azimuth + 22.5) / 45) % 8
        return directions[index]
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Tracking Manager

class TrackingManager: ObservableObject {
    @Published var currentPosition: SatellitePosition?
    @Published var currentHeading: Double?

    private var calculator = SatelliteCalculator()
    private var timer: Timer?
    private var motionManager: MotionManager?

    var cancellables = Set<AnyCancellable>()

    func startTracking(satellite: Satellite, location: (latitude: Double, longitude: Double, altitude: Double)) {
        // Start motion manager for compass
        motionManager = MotionManager()
        motionManager?.startUpdates { heading in
            self.currentHeading = heading
        }

        // Start position updates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePosition(satellite: satellite, location: location)
        }

        // Initial update
        updatePosition(satellite: satellite, location: location)
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
        motionManager?.stopUpdates()
        motionManager = nil
    }

    private func updatePosition(satellite: Satellite, location: (latitude: Double, longitude: Double, altitude: Double)) {
        let satrec = calculator.twoline2satrec(tleLine1: satellite.tle[0], tleLine2: satellite.tle[1])
        let positionAndVelocity = calculator.propagate(satrec: satrec, date: Date())

        let gmst = calculator.gmst(date: Date())
        let positionGd = calculator.eciToGeodetic(
            positionEci: positionAndVelocity.position,
            gmst: gmst
        )

        let observerGd = SatelliteCalculator.GeodeticCoordinate(
            latitude: location.latitude * .pi / 180,
            longitude: location.longitude * .pi / 180,
            height: location.altitude / 1000
        )

        let lookAngles = calculator.eciToLookAngles(
            observerGd: observerGd,
            positionEci: positionAndVelocity.position,
            gmst: gmst
        )

        currentPosition = SatellitePosition(
            latitude: positionGd.latitude * 180 / .pi,
            longitude: positionGd.longitude * 180 / .pi,
            altitude: positionGd.height,
            azimuth: lookAngles.azimuth * 180 / .pi,
            elevation: lookAngles.elevation * 180 / .pi,
            range: lookAngles.range,
            rangeRate: lookAngles.rangeRate,
            velocity: positionAndVelocity.velocity,
            timestamp: Date()
        )
    }
}

// MARK: - Motion Manager

class MotionManager {
    private var motionManager = CMMotionManager()
    private var headingUpdateHandler: ((Double) -> Void)?

    func startUpdates(handler: @escaping (Double) -> Void) {
        headingUpdateHandler = handler

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let motion = motion else { return }

                let heading = motion.heading
                self?.headingUpdateHandler?(heading)
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Extension for CMDeviceMotion

extension CMDeviceMotion {
    var heading: Double {
        let x = gravity.x
        let y = gravity.y
        let z = gravity.z

        let roll = atan2(y, z)
        let pitch = atan2(-x, sqrt(y * y + z * z))

        var heading = atan2(
            sin(roll) * y - cos(roll) * x,
            cos(pitch) * z + sin(pitch) * sin(roll) * y + sin(pitch) * cos(roll) * x
        )

        heading = heading * 180 / .pi
        if heading < 0 {
            heading += 360
        }

        return heading
    }
}

// MARK: - Preview

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        let satellite = Satellite(
            id: 25544,
            name: "ISS (ZARYA)",
            tle: [
                "1 25544U 98067A   23074.96341883  .00001423  00000-0  29428-4 0  9992",
                "2 25544  51.6410 102.4898 0003906 353.0866  70.3061 15.49612049443270"
            ],
            catalogNumber: "25544",
            internationalDesignator: nil
        )

        return TrackingView(
            satellite: satellite,
            location: (39.9042, 116.4074, 50.0)
        )
        .environmentObject(LanguageManager())
    }
}