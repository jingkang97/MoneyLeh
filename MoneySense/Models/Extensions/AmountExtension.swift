//
//  AmountExtension.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/5/26.
//
import SwiftUI

extension Double {
    func walletFormatted(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 1
        
        switch self {
        case 1_000_000...:
            return "\(formatter.currencySymbol ?? "$")\((self / 1_000_000).formatted(.number.precision(.fractionLength(1))))M"
        case 1_000...:
            return "\(formatter.currencySymbol ?? "$")\((self / 1_000).formatted(.number.precision(.fractionLength(1))))K"
        default:
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: self)) ?? "$0"
        }
    }

    func cappedPercentLabel(max: Double = 100) -> String {
        let value = abs(self)
        if value > max {
            return String(format: "%.0f%%+", max)
        }
        return String(format: "%.0f%%", value)
    }
}
