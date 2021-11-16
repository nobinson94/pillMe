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

struct RoundedCornersShape: Shape {
    
    let radius: CGFloat
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner = .allCorners) -> some View {
        clipShape(RoundedCornersShape(radius: radius, corners: corners))
    }
}
