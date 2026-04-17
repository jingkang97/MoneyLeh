//
//  Locale+CurrencyCode.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//
import SwiftUI

extension Locale {
    var currencyCode: String {
        currency?.identifier ?? "SGD"
    }
}
