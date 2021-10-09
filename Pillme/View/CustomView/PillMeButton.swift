//
//  PillMeButton.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//

import SwiftUI

enum PillMeButtonStyle {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 45
        case .medium: return 60
        case .large: return 100
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 17
        case .large: return 22
        }
    }
}

struct PillMeButton: ButtonStyle {
    var style: PillMeButtonStyle = .medium
    var fontSize: CGFloat { style.fontSize }
    var height: CGFloat { style.height }
    var color: Color = .tintColor
    var textColor: Color = .mainColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor)
            .font(.system(size: fontSize))
            .frame(maxWidth: .infinity, minHeight: height)
            .background(color)
            .cornerRadius(10)
    }
}
