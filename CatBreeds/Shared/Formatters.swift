import Foundation

let lifespanFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    formatter.numberStyle = .decimal
    return formatter
}()
