import Foundation
import UIKit

struct ColorComponents {
    var r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat
}

extension UIColor {
    func getComponents() -> ColorComponents {
        if let cc = cgColor.components {
            if cgColor.numberOfComponents == 2 {
                return ColorComponents(r: cc[0], g: cc[0], b: cc[0], a: cc[1])
            } else {
                return ColorComponents(r: cc[0], g: cc[1], b: cc[2], a: cc[3])
            }
        } else {
            // TODO: is this the best default?
            return ColorComponents(r: 0, g: 0, b: 0, a: 0)
        }
    }

    func interpolateRGBColorTo(end: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)

        let c1 = self.getComponents()
        let c2 = end.getComponents()

        let r = c1.r + (c2.r - c1.r) * f
        let g = c1.g + (c2.g - c1.g) * f
        let b = c1.b + (c2.b - c1.b) * f
        let a = c1.a + (c2.a - c1.a) * f

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
