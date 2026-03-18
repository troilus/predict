import Foundation
import CoreLocation
import Combine

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var error: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        // 不在初始化时设置位置管理器
        // locationManager 将在需要时设置
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 不在初始化时请求权限，等待用户主动操作
    }

func requestLocationPermission() {
        if locationManager.delegate == nil {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        if locationManager.delegate == nil {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        locationManager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.error = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error.localizedDescription
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            self.error = "Location access denied"
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    // MARK: - Convenience Properties

    var latitude: Double? {
        location?.coordinate.latitude
    }

    var longitude: Double? {
        location?.coordinate.longitude
    }

    var altitude: Double? {
        location?.altitude
    }

    var coordinates: (latitude: Double, longitude: Double, altitude: Double)? {
        guard let lat = latitude,
              let lon = longitude,
              let alt = altitude else { return nil }
        return (lat, lon, alt)
    }
}