//
//  NMGLatLng+Extension.swift
//  NMapsCurve
//
//  Created by SuperMove on 2022/06/24.
//

import NMapsMap

extension Double {
    var radians: Double {
        return self * (.pi / 180)
    }
    
    var degrees: Double {
        return self * (180 / .pi)
    }
}
