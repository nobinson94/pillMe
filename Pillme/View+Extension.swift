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
            .foregroundColor(.white)
            .padding(10)
    }
    
    func queustionText() -> some View {
        self
            .foregroundColor(.white)
            .font(.system(size: 32, weight: .ultraLight))
            .padding(0)
    }
    
    func answerText() -> some View {
        self
            .foregroundColor(.white)
            .font(.system(size: 15, weight: .ultraLight))
            .padding(0)
    }
}
