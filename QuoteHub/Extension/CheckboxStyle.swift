//
//  CheckboxStyle.swift
//  QuoteHub
//
//  Created by 이융의 on 10/17/23.
//

import Foundation
import SwiftUI

struct CheckboxStyle: ToggleStyle {

    func makeBody(configuration: Self.Configuration) -> some View {

        return HStack {

            configuration.label

            Spacer()

            Image(systemName: configuration.isOn ? "circle" : "checkmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
//                .foregroundColor(configuration.isOn ? Color.appAccent : Color.appAccent)
                .font(.system(size: 20, weight: .medium, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }

    }
}
