//
//  Int+Extension.swift
//  Pillme
//
//  Created by USER on 2021/09/25.
//

import Foundation

extension Int {
    var cycleString: String {
        guard self > 0 else { return "" }
        if self == 1 { return "매일" }
        return "\(self)일마다"
    }
}
