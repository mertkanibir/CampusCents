import SwiftUI

enum InsightTone {
    case watch
    case positive
    case neutral
}

struct Insight: Identifiable {
    let id: String
    let icon: String
    let title: String
    let detail: String
    let tint: Color
    let tone: InsightTone
}
