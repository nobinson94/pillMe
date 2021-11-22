//
//  BottomPopup.swift
//  Pillme
//
//  Created by USER on 2021/11/16.
//

import SwiftUI

struct BottomPopup<Content: View>: View {
    var backgroundColor: Color
    let content: Content
    
    init(backgroundColor: Color = .mainColor, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                content
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(backgroundColor)
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea([.bottom])
        }
        .transition(.move(edge: .bottom))
        .animation(.easeOut)
    }
}

struct OverlayModifier<OverlayView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    let overlayView: OverlayView
    
    init(isPresented: Binding<Bool>, @ViewBuilder overlayView: @escaping () -> OverlayView) {
        self._isPresented = isPresented
        self.overlayView = overlayView()
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Blur(style: .dark)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                    .transition(.opacity.animation(.linear))
                overlayView
            }
        }
    }
}

extension View {
    func popup<OverlayView: View>(isPresented: Binding<Bool>,
                                  blurRadius: CGFloat = 3,
                                  blurAnimation: Animation? = .linear,
                                  @ViewBuilder overlayView: @escaping () -> OverlayView) -> some View {
        return navigationBarHidden(isPresented.wrappedValue)
            .modifier(OverlayModifier(isPresented: isPresented, overlayView: overlayView))
            
    }
}
