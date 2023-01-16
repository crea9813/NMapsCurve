//
//  NMapsCurvePath.swift
//  NMapsCurve
//
//  Created by SuperMove on 2022/06/24.
//

import NMapsMap

open class NMFCurvePath: NMFPath {
    
    public convenience init?(point: [NMGLatLng]) {
        var points: [NMGLatLng] = []
        
        point.enumerated().forEach {
            if $0.offset == point.count - 1 { return }
            
            points.append(contentsOf: NMFCurvePath.convertToCurve(departure: $0.element, arrival: point[$0.offset + 1]))
        }
        self.init(points: points)
    }
}

extension NMFCurvePath {
    static let EARTH_RADIUS: Double = 6371000
    
    static func convertToCurve(departure: NMGLatLng, arrival: NMGLatLng) -> [NMGLatLng] {
        let SE = departure.distance(to: arrival)
        
        let angle = Double.pi / 2
        let ME = SE / 2.0
        let R = ME / sin(angle / 2)
        let MO = R * cos(angle / 2)
        
        let heading = departure.heading(to: arrival)
        let mCoordinate = computeOffset(from: departure, distance: ME / NMFCurvePath.EARTH_RADIUS, heading: heading)
        
        let direction = departure.lng - arrival.lng > 0 ? -1.0 : 1.0
        let angleFromCenter = 90.0 * direction
        
        let oCoordinate = computeOffset(from: mCoordinate, distance: MO / NMFCurvePath.EARTH_RADIUS, heading: heading + angleFromCenter)
        
        var points: [NMGLatLng] = []
        
        points.append(NMGLatLng(lat: arrival.lat, lng: arrival.lng))
        
        let num = 100
        
        let initialHeading = oCoordinate.heading(to: arrival)
        let degree = (180.0 * angle) / Double.pi
        
        for i in 1...num {
            let step = Double(i) * (degree / Double(num))
            let heading: Double = (-1.0) * direction
            
            let pointOnCurvedLine = computeOffset(from: oCoordinate, distance: R / NMFCurvePath.EARTH_RADIUS, heading: initialHeading + heading * step)
            points.append(NMGLatLng(lat: pointOnCurvedLine.lat, lng: pointOnCurvedLine.lng))
        }
        
        points = points.reversed()
        
        return points
    }
    
    static private func computeOffset(
        from: NMGLatLng,
        distance: Double,
        heading: Double) -> NMGLatLng {
            let bearing = heading.radians
            let latLng1 = from.latLngRadians
            let sinLat2 = sin(latLng1.latitude) * cos(distance) + cos(latLng1.latitude) * sin(distance) * cos(bearing)
            let lat2 = asin(sinLat2)
            let y = sin(bearing) * sin(distance) * cos(latLng1.latitude)
            let x = cos(distance) - sin(latLng1.latitude) * sinLat2
            let lng2 = latLng1.longitude + atan2(y, x)
            return NMGLatLng(
                lat: lat2.degrees,
                lng: Math.wrap(value: lng2.degrees, min: -180, max: 180)
            )
        }
}

public extension NMGLatLng {
    internal var latLngRadians: LatLngRadians {
        LatLngRadians(latitude: lat.radians, longitude: lng.radians)
    }
    
    internal func heading(to: NMGLatLng) -> Double {
        let bearing = Math.initialBearing(self.latLngRadians, to.latLngRadians)
        return Math.wrap(value: bearing * (180 / .pi), min: 0, max: 360)
    }
}
