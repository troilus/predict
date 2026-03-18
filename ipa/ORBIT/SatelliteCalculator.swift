import Foundation

// MARK: - Satellite Calculator
class SatelliteCalculator {

    // Constants
    private let pi = Double.pi
    private let twoPi = Double.pi * 2
    private let deg2rad = Double.pi / 180.0
    private let rad2deg = 180.0 / Double.pi
    private let minutesPerDay = 1440.0
    private let mu = 398600.8 // Earth's gravitational constant (km^3/s^2)
    private let earthRadius = 6378.135 // Earth's radius (km)
    private let xke = 60.0 / sqrt(pow(6378.135, 3) / 398600.8)
    private let vkmpersec = 6378.135 * (60.0 / sqrt(pow(6378.135, 3) / 398600.8)) / 60.0

    // MARK: - TLE Parsing

    struct SatelliteRecord {
        var satnum: Int
        var epochyr: Int
        var epochdays: Double
        var ndot: Double
        var nddot: Double
        var bstar: Double
        var inclo: Double
        var nodeo: Double
        var ecco: Double
        var argpo: Double
        var mo: Double
        var no: Double
    }

    func twoline2satrec(tleLine1: String, tleLine2: String) -> SatelliteRecord {
        var satrec = SatelliteRecord(
            satnum: 0,
            epochyr: 0,
            epochdays: 0.0,
            ndot: 0.0,
            nddot: 0.0,
            bstar: 0.0,
            inclo: 0.0,
            nodeo: 0.0,
            ecco: 0.0,
            argpo: 0.0,
            mo: 0.0,
            no: 0.0
        )

        let line1 = Array(tleLine1)
        let line2 = Array(tleLine2)

        // Line 1
        satrec.satnum = Int(String(line1[2..<8])) ?? 0
        satrec.epochyr = Int(String(line1[18..<20])) ?? 0
        satrec.epochdays = Double(String(line1[20..<32])) ?? 0.0

        let ndotStr = String(line1[33..<43])
        satrec.ndot = Double(ndotStr.replacingOccurrences(of: " ", with: "")) ?? 0.0

        let nddotStr = String(line1[44..<52])
        let nddotExp = Int(String(line1[51..<52])) ?? 0
        var nddot = Double(String(nddotStr.replacingOccurrences(of: ".", with: ""))) ?? 0.0
        satrec.nddot = nddot * pow(10.0, Double(nddotExp))

        let bstarStr = String(line1[53..<61])
        let bstarExp = Int(String(line1[59..<60])) ?? 0
        var bstar = Double(String(bstarStr.replacingOccurrences(of: ".", with: ""))) ?? 0.0
        satrec.bstar = bstar * pow(10.0, Double(bstarExp))

        // Line 2
        satrec.inclo = Double(String(line2[8..<16])) ?? 0.0
        satrec.nodeo = Double(String(line2[17..<25])) ?? 0.0
        satrec.ecco = Double("0.\(String(line2[26..<33]))") ?? 0.0
        satrec.argpo = Double(String(line2[34..<42])) ?? 0.0
        satrec.mo = Double(String(line2[43..<51])) ?? 0.0

        let noStr = String(line2[52..<63])
        satrec.no = Double(noStr.replacingOccurrences(of: " ", with: "")) ?? 0.0

        return satrec
    }

    // MARK: - Propagation

    struct PositionAndVelocity {
        var position: [Double] // ECI coordinates (km)
        var velocity: [Double] // ECI velocity (km/s)
    }

    struct LookAngles {
        var azimuth: Double
        var elevation: Double
        var range: Double
        var rangeRate: Double
    }

    struct GeodeticCoordinate {
        var latitude: Double
        var longitude: Double
        var height: Double
    }

    func propagate(satrec: SatelliteRecord, date: Date) -> PositionAndVelocity {
        // Calculate time since epoch
        let epochYear = satrec.epochyr + (satrec.epochyr < 57 ? 2000 : 1900)
        let epochDate = julianDate(year: epochYear, month: 1, day: 1) + satrec.epochdays
        let currentDate = julianDate(from: date)
        let minutesSinceEpoch = (currentDate - epochDate) * minutesPerDay

        // Mean motion (rev/day)
        let no = satrec.no
        let n0 = no * minutesPerDay // rad/min

        // Mean anomaly at epoch
        let m0 = satrec.mo * deg2rad

        // Current mean anomaly
        let m = m0 + n0 * minutesSinceEpoch

        // Eccentric anomaly (solve Kepler's equation)
        let e = satrec.ecco
        var E = m
        for _ in 0..<10 {
            let dE = (E - e * sin(E) - m) / (1 - e * cos(E))
            E -= dE
            if abs(dE) < 1e-6 { break }
        }

        // True anomaly
        let sinE = sin(E)
        let cosE = cos(E)
        let nu = 2.0 * atan2(sqrt(1.0 + e) * sin(E / 2.0), sqrt(1.0 - e) * cos(E / 2.0))

        // Radius
        let r = a(no: n0) * (1.0 - e * cos(E))

        // Position in orbital plane
        let u = nu + satrec.argpo * deg2rad
        let xOrb = r * cos(u)
        let yOrb = r * sin(u)

        // Orbital elements
        let i = satrec.inclo * deg2rad
        let Om = satrec.nodeo * deg2rad
        let w = satrec.argpo * deg2rad

        // Rotation matrices
        let cosOm = cos(Om)
        let sinOm = sin(Om)
        let cosi = cos(i)
        let sini = sin(i)
        let cosw = cos(w)
        let sinw = sin(w)

        // ECI coordinates
        let x = xOrb * (cosOm * cosw - sinOm * sinw * cosi) - yOrb * (cosOm * sinw + sinOm * cosw * cosi)
        let y = xOrb * (sinOm * cosw + cosOm * sinw * cosi) + yOrb * (-sinOm * sinw + cosOm * cosw * cosi)
        let z = xOrb * (sinw * sini) + yOrb * (cosw * sini)

        // Simplified velocity (not precise, but sufficient for basic tracking)
        let n = n0
        let vx = -n * y
        let vy = n * x
        let vz = 0.0

        return PositionAndVelocity(position: [x, y, z], velocity: [vx, vy, vz])
    }

    // MARK: - Coordinate Conversions

    func eciToGeodetic(positionEci: [Double], gmst: Double) -> GeodeticCoordinate {
        let x = positionEci[0]
        let y = positionEci[1]
        let z = positionEci[2]

        // Convert ECI to ECEF
        let theta = gmst
        let xEcef = x * cos(theta) + y * sin(theta)
        let yEcef = -x * sin(theta) + y * cos(theta)
        let zEcef = z

        // ECEF to geodetic
        let p = sqrt(xEcef * xEcef + yEcef * yEcef)
        let thetaPrime = atan2(zEcef * earthRadius, p * (1.0 - 0.00669437999014))
        let latitude = atan2(zEcef + 0.00669437999014 * earthRadius * pow(sin(thetaPrime), 3),
                               p - 0.00669437999014 * earthRadius * pow(cos(thetaPrime), 3))
        let longitude = atan2(yEcef, xEcef)

        // Height above Earth's surface
        let n = earthRadius / sqrt(1.0 - 0.00669437999014 * pow(sin(latitude), 2))
        let height = p / cos(latitude) - n

        return GeodeticCoordinate(latitude: latitude, longitude: longitude, height: height)
    }

    func eciToLookAngles(observerGd: GeodeticCoordinate, positionEci: [Double], gmst: Double) -> LookAngles {
        // Convert observer position to ECI
        let sinLat = sin(observerGd.latitude)
        let cosLat = cos(observerGd.latitude)
        let sinLon = sin(observerGd.longitude)
        let cosLon = cos(observerGd.longitude)

        let theta = gmst + observerGd.longitude

        let r = earthRadius + observerGd.height
        let rx = r * cosLat * cos(theta)
        let ry = r * cosLat * sin(theta)
        let rz = r * sinLat

        // Satellite position in ECI
        let sx = positionEci[0]
        let sy = positionEci[1]
        let sz = positionEci[2]

        // Relative position
        let dx = sx - rx
        let dy = sy - ry
        let dz = sz - rz

        // Range
        let range = sqrt(dx * dx + dy * dy + dz * dz)

        // Observer's local coordinate system
        let topS = -sinLat * cos(theta) * dx + -sinLat * sin(theta) * dy + cosLat * dz
        let topE = -sin(theta) * dx + cos(theta) * dy
        let topZ = cosLat * cos(theta) * dx + cosLat * sin(theta) * dy + sinLat * dz

        // Elevation and azimuth
        let el = asin(topZ / range)
        let az = atan2(topE, topS)

        return LookAngles(azimuth: az, elevation: el, range: range, rangeRate: 0.0)
    }

    // MARK: - Helper Functions

    private func julianDate(year: Int, month: Int, day: Int) -> Double {
        if month <= 2 {
            return julianDate(year: year - 1, month: month + 12, day: day)
        }
        let A = year / 100
        let B = 2 - A + A / 4
        return floor(365.25 * Double(year + 4716)) +
               floor(30.6001 * Double(month + 1)) +
               Double(day) + Double(B) - 1524.5
    }

    private func julianDate(from date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = components.year!
        let month = components.month!
        let day = components.day!
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)

        let jd = julianDate(year: year, month: month, day: day)
        let fraction = (hour + minute / 60.0 + second / 3600.0) / 24.0
        return jd + fraction
    }

    func gmst(date: Date) -> Double {
        let jd = julianDate(from: date)
        let jd0 = floor(jd) - 0.5
        let t = (jd0 - 2451545.0) / 36525.0

        let gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
                   0.000387933 * t * t - t * t * t / 38710000.0

        var gmstRad = gmst * deg2rad
        gmstRad = gmstRad.truncatingRemainder(dividingBy: twoPi)
        if gmstRad < 0 {
            gmstRad += twoPi
        }

        return gmstRad
    }

    private func a(no: Double) -> Double {
        return pow(mu / pow(no / 60.0, 2), 1.0 / 3.0)
    }

    // MARK: - Sun Position (Simplified)

    struct SunPosition {
        var altitude: Double
        var azimuth: Double
    }

    func calculateSunPosition(latitude: Double, longitude: Double, date: Date) -> SunPosition {
        // Simplified sun position calculation
        let jd = julianDate(from: date)
        let n = jd - 2451545.0
        let L = (280.460 + 0.9856474 * n).truncatingRemainder(dividingBy: 360)
        let g = (357.528 + 0.9856003 * n).truncatingRemainder(dividingBy: 360)

        let gRad = g * deg2rad
        let lambda = (L + 1.915 * sin(gRad) + 0.020 * sin(2 * gRad)).truncatingRemainder(dividingBy: 360)
        let lambdaRad = lambda * deg2rad

        let epsilon = 23.439 - 0.0000004 * n
        let epsilonRad = epsilon * deg2rad

        let alpha = atan2(cos(epsilonRad) * sin(lambdaRad), cos(lambdaRad)) * rad2deg
        let delta = asin(sin(epsilonRad) * sin(lambdaRad)) * rad2deg

        let hourAngle = gmst(date: date) * rad2deg + longitude - alpha

        let latRad = latitude * deg2rad
        let deltaRad = delta * deg2rad
        let haRad = hourAngle * deg2rad

        let altitude = asin(sin(latRad) * sin(deltaRad) + cos(latRad) * cos(deltaRad) * cos(haRad))
        let azimuth = atan2(sin(haRad), cos(haRad) * sin(latRad) - tan(deltaRad) * cos(latRad))

        return SunPosition(altitude: altitude, azimuth: azimuth)
    }
}