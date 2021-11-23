//
//  NavigationBar.swift
//  Pillme
//
//  Created by USER on 2021/09/25.
//

import SwiftUI

struct PillMeNavigationBar: ViewModifier {
    
    init() {
        let tintColor: UIColor = .white
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.mainColor
        appearance.titleTextAttributes = [.foregroundColor: tintColor, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: tintColor, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        appearance.setBackIndicatorImage(UIImage(named: "chevron.backward"), transitionMaskImage: nil)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
        UINavigationBar.appearance().prefersLargeTitles = false
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
    }
}

extension View {
    func pillMeNavigationBar<Content>(title: String = "", backButtonAction: (() -> ())? = nil, rightView: Content) -> some View where Content : View {
        self.modifier(PillMeNavigationBar())
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: backButtonAction ?? { }, label: {
                Image(systemName: "chevron.backward").imageScale(.large).accentColor(.white).padding(.trailing, 20)
            }), trailing: rightView)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(title)
    }
    
    func pillMeNavigationBar(title: String = "", backButtonAction: (() -> ())? = nil) -> some View {
        self.modifier(PillMeNavigationBar())
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: backButtonAction ?? { }, label: {
                Image(systemName: "chevron.backward").imageScale(.large).accentColor(.white).padding(.trailing, 20)
            }))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(title)
    }
}
