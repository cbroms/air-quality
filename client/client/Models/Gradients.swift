import Foundation
import SwiftUI

struct GradientRange {
    var range: Range<Int>
    var color: Color
    var annotation: String
}

struct IntermediateGradientPosition {
    var percentThroughGradient: Float
    var value: Int
    var annotation: String
    var annotationColor: Color
}

class GradientManager {
    var ranges: [GradientRange] = []
    var rangeMax: Int = 0
    var gradient: LinearGradient?

    init(ranges: [GradientRange], rangeMax: Int, maxValue: Int) {
        self.ranges = ranges
        self.rangeMax = rangeMax

        computeGradient(maxValue: maxValue)
    }

    func getIntermediateGradientPositionFromValue(value: Int) -> IntermediateGradientPosition {
        let p = Float(value) / Float(rangeMax)
        for range in ranges {
            if range.range.contains(value) {
                return IntermediateGradientPosition(
                    percentThroughGradient: p,
                    value: value,
                    annotation: range.annotation,
                    annotationColor: range.color
                )
            }
        }
        return IntermediateGradientPosition(
            percentThroughGradient: p,
            value: value,
            annotation: "?",
            annotationColor: Color.white
        )
    }

    func computeGradient(maxValue: Int) {
        let baseGradientStops = ranges.map { range in
            Gradient.Stop(color: range.color, location: CGFloat(getIntermediateGradientPositionFromValue(value: range.range.lowerBound).percentThroughGradient))
        }
        let baseGradient = Gradient(stops: baseGradientStops)

        let maxP = getIntermediateGradientPositionFromValue(value: maxValue).percentThroughGradient
        // reduce the range of the gradient to 0 -> max value
        var partialGradientStops = baseGradient.stops.filter { stop in
            stop.location >= 0 && stop.location <= CGFloat(maxP)
        }

        // if the partial gradient is between two values, find the intermediate
        // color and add it to the end
        if partialGradientStops.count < baseGradient.stops.count {
            // find the range we're in
            for (index, range) in ranges.enumerated() {
                if range.range.contains(maxValue) {
                    // get the color of the next range in the list (this range was filtered out)
                    let nextColor = ranges[index + 1].color
                    let nextThreshold = ranges[index + 1].range.lowerBound
                    let previousThreshold = range.range.lowerBound
                    // what percentage of the way are we through the current range?
                    let percentBetweenValues = Float(maxValue - previousThreshold) / Float(nextThreshold - previousThreshold)
                    // create an interpolated color between the current and next colors
                    let interpolatedColor = UIColor(range.color).interpolateRGBColorTo(end: UIColor(nextColor), fraction: CGFloat(percentBetweenValues))
                    // calculate the max value's location; this is the location to place the stop with the new color
                    let stopLocation = getIntermediateGradientPositionFromValue(value: maxValue).percentThroughGradient
                    // now add as the last stop
                    partialGradientStops.append(Gradient.Stop(color: Color(interpolatedColor), location: CGFloat(stopLocation)))
                }
            }
        }

        // adjust the stop percentages to the new range
        func remapStop(stop: Gradient.Stop) -> Gradient.Stop {
            let currentStopLoc = stop.location
            let adjustedStopLoc = currentStopLoc / CGFloat(maxP)
            // calculate the opacity as the adjusted location
            var newColor = stop.color
            //     newColor = newColor.opacity(Double(adjustedStopLoc))
            return Gradient.Stop(color: newColor, location: CGFloat(adjustedStopLoc))
        }
        partialGradientStops = partialGradientStops.map(remapStop)
        // finally create the adjusted gradient
        let partialGradient = Gradient(stops: partialGradientStops)
        gradient = LinearGradient(
            gradient: partialGradient,
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

class AqiGradientManager: GradientManager {
    init(maxValue: Int) {
        super.init(ranges: [
            GradientRange(range: 0..<51, color: Color.green, annotation: "LO"),
            GradientRange(range: 51..<101, color: Color.yellow, annotation: "MOD"),
            GradientRange(range: 101..<151, color: Color.orange, annotation: "UNS"),
            GradientRange(range: 151..<201, color: Color.red, annotation: "UN"),
            GradientRange(range: 201..<300, color: Color.purple, annotation: "VUN"),
            GradientRange(range: 300..<Int.max, color: Color.indigo, annotation: "HAZ")
        ], rangeMax: 300, maxValue: maxValue)
    }
}

class TempGradientManager: GradientManager {
    init(maxValue: Int) {
        super.init(ranges: [
            GradientRange(range: 0..<45, color: Color.blue, annotation: ""),
            GradientRange(range: 45..<65, color: Color.teal, annotation: ""),
            GradientRange(range: 65..<75, color: Color.green, annotation: ""),
            GradientRange(range: 75..<85, color: Color.yellow, annotation: ""),
            GradientRange(range: 85..<95, color: Color.orange, annotation: ""),
            GradientRange(range: 95..<Int.max, color: Color.red, annotation: "HAZ")
        ], rangeMax: 95, maxValue: maxValue)
    }
}

class Co2GradientManager: GradientManager {
    init(maxValue: Int) {
        super.init(ranges: [
            GradientRange(range: 0..<400, color: Color.green, annotation: "LO"),
            GradientRange(range: 400..<701, color: Color.green, annotation: "LO"),
            GradientRange(range: 701..<1001, color: Color.yellow, annotation: "MOD"),
            GradientRange(range: 1001..<1501, color: Color.orange, annotation: "UNS"),
            GradientRange(range: 1501..<2001, color: Color.red, annotation: "UN"),
            GradientRange(range: 2001..<2500, color: Color.purple, annotation: "VUN"),
            GradientRange(range: 2500..<Int.max, color: Color.indigo, annotation: "HAZ")
        ], rangeMax: 2500, maxValue: maxValue)
    }
}

class HumidityGradientManager: GradientManager {
    init(maxValue: Int) {
        super.init(ranges: [
            GradientRange(range: 0..<30, color: Color.yellow, annotation: ""),
            GradientRange(range: 30..<80, color: Color.green, annotation: ""),
            GradientRange(range: 80..<Int.max, color: Color.blue, annotation: "")
        ], rangeMax: 100, maxValue: maxValue)
    }
}
