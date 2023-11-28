//
//  ColorExtension.swift
//  QuoteHub
//
//  Created by 이융의 on 10/20/23.
//

import Foundation
import SwiftUI

extension Color {
    static let appAccent = Color("mainColor")
}

extension Color {
    var uiColor: UIColor {
        return UIColor(self)
    }
}
