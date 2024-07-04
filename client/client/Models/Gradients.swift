import Foundation
import SwiftUI

struct PrimaryStopRange {
    var range: Range<Int>
    var color: Color
    var annotation: String
}

struct IntermediateStop {
    var percent: Float
    var annotation: String
}

class DataRange {
    var ranges: [PrimaryStopRange] = []
    var rangeMax: Int = 0

    init(ranges: [PrimaryStopRange], rangeMax: Int) {
        self.ranges = ranges
        self.rangeMax = rangeMax
    }

    func getIntermediateStopFromValue(value: Int) -> IntermediateStop {
        let p = Float(value) / Float(rangeMax)
        for range in ranges {
            if range.range.contains(value) {
                return IntermediateStop(percent: p, annotation: range.annotation)
            }
        }
        return IntermediateStop(percent: p, annotation: "?")
    }

    func getGradient(maxValue: Int) -> LinearGradient {
        let baseGradientStops = ranges.map { range in
            Gradient.Stop(color: range.color, location: CGFloat(getIntermediateStopFromValue(value: range.range.lowerBound).percent))
        }
        let baseGradient = Gradient(stops: baseGradientStops)

        let maxP = getIntermediateStopFromValue(value: maxValue).percent
        // reduce the range of the gradient to 0 -> max value
        var partialGradientStops = baseGradient.stops.filter { stop in
            stop.location >= 0 && stop.location <= CGFloat(maxP)
        }

        // if the partial gradient is between two values, find the intermediate color
        // and add it to the end
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
                    let stopLocation = getIntermediateStopFromValue(value: maxValue).percent
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
            newColor = newColor.opacity(Double(adjustedStopLoc))
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

class AqiStopRange: DataRange {
    init() {
        super.init(ranges: [
            PrimaryStopRange(range: 0..<51, color: Color.green, annotation: "LO"),
            PrimaryStopRange(range: 51..<101, color: Color.yellow, annotation: "MOD"),
            PrimaryStopRange(range: 101..<151, color: Color.orange, annotation: "UNS"),
            PrimaryStopRange(range: 151..<201, color: Color.red, annotation: "UN"),
            PrimaryStopRange(range: 201..<300, color: Color.purple, annotation: "VUN"),
            PrimaryStopRange(range: 300..<Int.max, color: Color.indigo, annotation: "HAZ")
        ], rangeMax: 300)
    }
}
