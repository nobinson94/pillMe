//
//  LazyView.swift
//  Pillme
//
//  Created by USER on 2021/09/21.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let view: () -> Content
    init(_ view: @autoclosure @escaping () -> Content) {
        self.view = view
    }
    var body: Content {
        view()
    }
}
