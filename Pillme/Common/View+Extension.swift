//
//  View+Extension.swift
//  Pillme
//
//  Created by USER on 2021/08/25.
//

import SwiftUI

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .accentColor(.tintColor)
            .foregroundColor(.tintColor)
            .padding(10)
    }
}
