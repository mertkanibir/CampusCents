import Foundation

enum AffordabilityResult {
    case safe(String)
    case mostlySafe(String)
    case risky(String)
    case no(String)
}
