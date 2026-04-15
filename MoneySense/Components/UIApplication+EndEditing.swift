//
//  UIApplication+EndEditing.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
