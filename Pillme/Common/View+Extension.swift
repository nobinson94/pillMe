//
//  View+Extension.swift
//  Pillme
//
//  Created by USER on 2021/08/25.
//

import SwiftUI

extension View {
    func underlineTextField(color: Color = .tintColor) -> some View {
        self
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .accentColor(color)
            .foregroundColor(color)
            .padding(10)
    }
}
