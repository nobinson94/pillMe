//
//  Color+Pillme.swift
//  Pillme
//
//  Created by USER on 2021/08/22.
//

import SwiftUI

extension Color {
    static var mainColor: Color {
        return Color(.mainColor)
    }
    static var tintColor: Color {
        return Color(.tintColor)
    }
    static var subColor: Color {
        return Color(.subColor)
    }
    static var backgroundColor: Color {
        return Color(.backgroundColor)
    }
}

extension UIColor {
    static var mainColor: UIColor {
        return #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
    }
    static var tintColor: UIColor {
        return #colorLiteral(red: 0.9438474205, green: 0.7795540713, blue: 0.07557181467, alpha: 1)
    }
    static var subColor: UIColor {
        return #colorLiteral(red: 0.9647058824, green: 0.8784313725, blue: 0.8034269161, alpha: 1)
    }
    static var backgroundColor: UIColor {
        return #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1)
    }
}
