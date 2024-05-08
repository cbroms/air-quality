//
//  Sensor.swift
//  air-quality-client
//
//  Created by Christian Broms on 5/7/24.
//

import Foundation
import SwiftData

@Model
final class Sensor {
    var name: String
    var data: [SensorData]
    
    init(name: String, data: [SensorData]) {
        self.name = name
        self.data = data
    }
}
