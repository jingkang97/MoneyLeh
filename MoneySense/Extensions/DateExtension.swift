//
//  DateExtension.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 5/5/26.
//
import SwiftUI

extension Date {
    var isoString: String {
        ISO8601DateFormatter().string(from: self)
    }
        
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
}
