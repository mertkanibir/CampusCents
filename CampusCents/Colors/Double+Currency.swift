import Foundation

extension Double {
    var currency: String {
        formatted(.currency(code: "USD"))
    }
}
