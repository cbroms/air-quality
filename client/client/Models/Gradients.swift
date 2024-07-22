import Foundation
import SwiftUI

struct GradientRange {
    var range: Range<Int>
    var color: Color
    var annotation: String?
}

struct IntermediateGradientPosition {
    var percentThroughGradient: Float
    var value: Int
    var annotation: String?
    var annotationColor: Color
}

class GradientManager {
    var ranges: [GradientRange] = []
    var rangeMax: Int = 0
    var linearGradientZeroToMax: LinearGradient?
    var linearGradientMinToMax: LinearGradient?

    init(ranges: [GradientRange], rangeMax: Int) {
        self.ranges = ranges
        self.rangeMax = rangeMax
    }

    func recomputeGradients(maxValue: Int, minValue: Int) {
        linearGradientZeroToMax = computeGradient(maxValue: maxValue, minValue: 0, withOpacity: true)
        linearGradientMinToMax = computeGradient(maxValue: maxValue, minValue: minValue, withOpacity: false)
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
            annotation: nil,
            annotationColor: Color.white
        )
    }

    func computeGradient(maxValue: Int, minValue: Int, withOpacity: Bool) -> LinearGradient {
        // the base gradient is the full gradient from the minimum to max
        // specified in the GradientManager, for example 0-300 for AQI
        let baseGradientStops = ranges.map { range in
            Gradient.Stop(color: range.color, location: CGFloat(getIntermediateGradientPositionFromValue(value: range.range.lowerBound).percentThroughGradient))
        }
        let baseGradient = Gradient(stops: baseGradientStops)

        // now we filter down the gradient to only include the colors
        // necessary to display the actual data range, like 45-153
        let maxP = getIntermediateGradientPositionFromValue(value: maxValue).percentThroughGradient
        let minP = getIntermediateGradientPositionFromValue(value: minValue).percentThroughGradient
        // reduce the range of the gradient to min value -> max value
        var partialGradientStops = baseGradient.stops.filter { stop in
            stop.location >= CGFloat(minP) && stop.location <= CGFloat(maxP)
        }

        func getIntermediateGradientStopFromValue(value: Int) -> Gradient.Stop? {
            for (index, range) in ranges.enumerated() {
                if range.range.contains(value) {
                    let startColor = ranges[index].color
                    let endColor = ranges[index + 1].color
                    let startThreshold = ranges[index].range.lowerBound
                    let endThreshold = ranges[index].range.upperBound
                    // what percentage of the way are we through the current range?
                    let percentBetweenValues = Float(value - startThreshold) / Float(endThreshold - startThreshold)
                    // create an interpolated color between the current and next colors
                    let interpolatedColor = UIColor(startColor).interpolateRGBColorTo(end: UIColor(endColor), fraction: CGFloat(percentBetweenValues))
                    // calculate the max value's location; this is the location to place the stop with the new color
                    // note that this position is relative to the base gradient
                    let stopLocation = getIntermediateGradientPositionFromValue(value: value).percentThroughGradient

                    return Gradient.Stop(color: Color(interpolatedColor), location: CGFloat(stopLocation))
                }
            }
            return nil
        }

        // generate the stop for the max and min points
        let startStop = getIntermediateGradientStopFromValue(value: minValue)
        let endStop = getIntermediateGradientStopFromValue(value: maxValue)

        // add the partial stops
        partialGradientStops.append(endStop!)
        if minValue != 0 {
            partialGradientStops.insert(startStop!, at: 0)
        }

        // adjust the stop percentages to the new range
        func remapStop(stop: Gradient.Stop) -> Gradient.Stop {
            // round to .00 to prevent weirdness when remapping
            let currentStopLoc = round(stop.location * 100) / 100.0
            var adjustedStopLoc = currentStopLoc / CGFloat(maxP)
            if minP > 0 {
                // if the minimum is not zero, we need shift up by the new min
                adjustedStopLoc = (currentStopLoc - CGFloat(minP)) / (CGFloat(maxP) - CGFloat(minP))
            }
            var newColor = stop.color
            if withOpacity {
                // calculate the opacity as the adjusted location (will be 0 -> 1)
                newColor = newColor.opacity(Double(adjustedStopLoc) - 0.33)
            }
            return Gradient.Stop(color: newColor, location: CGFloat(adjustedStopLoc))
        }
        partialGradientStops = partialGradientStops.map(remapStop)
        // finally create the adjusted gradient
        let partialGradient = Gradient(stops: partialGradientStops)
        return LinearGradient(
            gradient: partialGradient,
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

class AqiGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<51, color: Color.green, annotation: "LO"),
            GradientRange(range: 51..<101, color: Color.yellow, annotation: "MOD"),
            GradientRange(range: 101..<151, color: Color.orange, annotation: "HI"),
            GradientRange(range: 151..<201, color: Color.red, annotation: "UN"),
            GradientRange(range: 201..<300, color: Color.purple, annotation: "VUN"),
            GradientRange(range: 300..<Int.max, color: Color.indigo, annotation: "HAZ")
        ], rangeMax: 300)
    }
}

class TempGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<45, color: Color.blue),
            GradientRange(range: 45..<65, color: Color.teal),
            GradientRange(range: 65..<75, color: Color.green),
            GradientRange(range: 75..<85, color: Color.yellow),
            GradientRange(range: 85..<95, color: Color.orange),
            GradientRange(range: 95..<Int.max, color: Color.red)
        ], rangeMax: 95)
    }
}

class Co2GradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<400, color: Color.green, annotation: "LO"),
            GradientRange(range: 400..<701, color: Color.green, annotation: "LO"),
            GradientRange(range: 701..<1201, color: Color.yellow, annotation: "MOD"),
            GradientRange(range: 1201..<1601, color: Color.orange, annotation: "HI"),
            GradientRange(range: 1601..<2001, color: Color.red, annotation: "UN"),
            GradientRange(range: 2001..<2500, color: Color.purple, annotation: "VUN"),
            GradientRange(range: 2500..<Int.max, color: Color.indigo, annotation: "HAZ")
        ], rangeMax: 2500)
    }
}

class HumidityGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<20, color: Color.red),
            GradientRange(range: 20..<40, color: Color.yellow),
            GradientRange(range: 40..<60, color: Color.green),
            GradientRange(range: 60..<Int.max, color: Color.blue)
        ], rangeMax: 100)
    }
}

class TvocGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<221, color: Color.green, annotation: "LO"),
            GradientRange(range: 221..<661, color: Color.yellow, annotation: "MOD"),
            GradientRange(range: 661..<1431, color: Color.orange, annotation: "HI"),
            GradientRange(range: 1431..<2201, color: Color.red, annotation: "UN"),
            GradientRange(range: 2201..<3300, color: Color.purple, annotation: "VUN"),
            GradientRange(range: 3300..<Int.max, color: Color.indigo, annotation: "HAZ")
        ], rangeMax: 3300)
    }
}
