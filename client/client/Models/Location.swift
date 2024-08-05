
import CoreLocation
import Foundation

extension CLLocation {
    // distance is in meters
    func addVector(distance: CLLocationDistance, direction: CLLocationDegrees) -> CLLocation {
        let bearing = direction * .pi / 180
        let radius = 6371e3 // Earth's radius in meters

        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180

        let lat2 = asin(sin(lat1) * cos(distance / radius) + cos(lat1) * sin(distance / radius) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distance / radius) * cos(lat1), cos(distance / radius) - sin(lat1) * sin(lat2))

        let newLat = lat2 * 180 / .pi
        let newLon = lon2 * 180 / .pi

        return CLLocation(latitude: newLat, longitude: newLon)
    }
}
