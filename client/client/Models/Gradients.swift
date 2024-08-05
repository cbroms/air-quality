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

    // TODO: Is this the best default?
    var linearGradientZeroToMax: LinearGradient = .init(
        gradient: Gradient(colors: [Color.black, Color.black]),
        startPoint: .top,
        endPoint: .bottom
    )
    var linearGradientMinToMax: LinearGradient = .init(
        gradient: Gradient(colors: [Color.black, Color.black]),
        startPoint: .top,
        endPoint: .bottom
    )

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

        func getIntermediateGradientStopFromValue(value: Int) -> Gradient.Stop {
            for (index, range) in ranges[0..<ranges.count - 1].enumerated() {
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

            // TODO: Is this the best default?
            return Gradient.Stop(color: Color.black, location: 0.0)
        }

        // generate the stop for the max and min points
        let startStop = getIntermediateGradientStopFromValue(value: minValue)
        let endStop = getIntermediateGradientStopFromValue(value: maxValue)

        // add the partial stops
        partialGradientStops.append(endStop)
        if minValue != 0 {
            partialGradientStops.insert(startStop, at: 0)
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
            GradientRange(range: 0..<50, color: Color(UIColor.systemGreen), annotation: "LO"),
            GradientRange(range: 50..<100, color: Color(UIColor.systemYellow), annotation: "MOD"),
            GradientRange(range: 100..<150, color: Color(UIColor.systemOrange), annotation: "HI"),
            GradientRange(range: 150..<200, color: Color(UIColor.systemRed), annotation: "UN"),
            GradientRange(range: 200..<300, color: Color(UIColor.systemPurple), annotation: "VUN"),
            GradientRange(range: 300..<Int.max, color: Color(UIColor.systemIndigo), annotation: "HAZ")
        ], rangeMax: 300)
    }
}

class TempGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<45, color: Color(UIColor.systemBlue)),
            GradientRange(range: 45..<65, color: Color(UIColor.systemTeal)),
            GradientRange(range: 65..<75, color: Color(UIColor.systemGreen)),
            GradientRange(range: 75..<85, color: Color(UIColor.systemYellow)),
            GradientRange(range: 85..<95, color: Color(UIColor.systemOrange)),
            GradientRange(range: 95..<Int.max, color: Color(UIColor.systemRed))
        ], rangeMax: 95)
    }
}

class Co2GradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<400, color: Color(UIColor.systemGreen), annotation: "LO"),
            GradientRange(range: 400..<700, color: Color(UIColor.systemGreen), annotation: "LO"),
            GradientRange(range: 700..<1200, color: Color(UIColor.systemYellow), annotation: "MOD"),
            GradientRange(range: 1200..<1600, color: Color(UIColor.systemOrange), annotation: "HI"),
            GradientRange(range: 1600..<2000, color: Color(UIColor.systemRed), annotation: "UN"),
            GradientRange(range: 2000..<2500, color: Color(UIColor.systemPurple), annotation: "VUN"),
            GradientRange(range: 2500..<Int.max, color: Color(UIColor.systemIndigo), annotation: "HAZ")
        ], rangeMax: 2500)
    }
}

class HumidityGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<20, color: Color(UIColor.systemRed)),
            GradientRange(range: 30..<50, color: Color(UIColor.systemYellow)),
            GradientRange(range: 50..<60, color: Color(UIColor.systemGreen)),
            GradientRange(range: 60..<Int.max, color: Color(UIColor.systemBlue))
        ], rangeMax: 100)
    }
}

class TvocGradientManager: GradientManager {
    init() {
        super.init(ranges: [
            GradientRange(range: 0..<220, color: Color(UIColor.systemGreen), annotation: "LO"),
            GradientRange(range: 220..<660, color: Color(UIColor.systemYellow), annotation: "MOD"),
            GradientRange(range: 660..<1430, color: Color(UIColor.systemOrange), annotation: "HI"),
            GradientRange(range: 1430..<2200, color: Color(UIColor.systemRed), annotation: "UN"),
            GradientRange(range: 2200..<3300, color: Color(UIColor.systemPurple), annotation: "VUN"),
            GradientRange(range: 3300..<Int.max, color: Color(UIColor.systemIndigo), annotation: "HAZ")
        ], rangeMax: 3300)
    }
}
