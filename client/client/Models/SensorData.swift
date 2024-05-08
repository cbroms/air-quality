//
//  SensorData.swift
//  air-quality-client
//
//  Created by Christian Broms on 5/7/24.
//

import Foundation
import SwiftData

@Model
final class SensorData {
    var time: Date
    var aqi: Int?
    var co2: Int?
    var humidity: Int?
    var tempF: Float?

    init(time: Date, aqi: Int?, co2: Int?, humidity: Int?, tempF: Float?) {
        self.time = time
        self.aqi = aqi
        self.co2 = co2
        self.humidity = humidity
        self.tempF = tempF
    }
}
