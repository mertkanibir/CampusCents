import SwiftUI
import UIKit

struct ColorValue: Codable, Hashable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    init(_ color: Color) {
        let ui = UIColor(color)
        var rr: CGFloat = 0
        var gg: CGFloat = 0
        var bb: CGFloat = 0
        var aa: CGFloat = 0
        ui.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
        r = Double(rr)
        g = Double(gg)
        b = Double(bb)
        a = Double(aa)
    }

    var color: Color {
        Color(red: r, green: g, blue: b).opacity(a)
    }
}
