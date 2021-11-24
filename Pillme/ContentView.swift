//
//  ContentView.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var contentOffset: CGFloat = 0
    
    struct Layout {
        static var safeAreaTop: CGFloat {
            UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
        static var headerHeight: CGFloat {
            50 // + safeAreaTop
        }
        static var screenWidth: CGFloat {
            UIScreen.main.bounds.width
        }
    }
    
    var headerViewOpacity: Double {
        let offset = Layout.headerHeight + contentOffset
        switch offset {
        case ...0:
            return 0
        case 0...100:
            return Double(offset) / 100.0
        default:
            return 1
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                ScrollView(.vertical) {
                    Spacer(minLength: Layout.headerHeight)
                    MainView(viewModel: MainViewModel())
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    self.contentOffset = value
                }
                .frame(maxHeight: .infinity)

                HStack {
                    Image("pillIcon")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                    Text("PillMe")
                        .foregroundColor(.white)
                        .font(.system(size: 23, weight: .semibold))
                    Spacer()
                    NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel()))) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                            .frame(width: 33, height: 33, alignment: .trailing)
                    }
                    .frame(width: 33, height: 33)
                    NavigationLink(destination: LazyView(SettingView())) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .frame(width: 33, height: 33, alignment: .trailing)
                    }
                    .frame(width: 33, height: 33)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .frame(width: Layout.screenWidth, height: Layout.headerHeight)
                .background(Blur(style: .dark).opacity(headerViewOpacity).ignoresSafeArea())
            }
            .background(Color.backgroundColor.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .pillMeNavigationBar()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
