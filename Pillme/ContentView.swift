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
            50 + safeAreaTop
        }
    }
    
    var headerViewOpacity: Double {
        switch contentOffset {
        case ...0:
            return 0
        case 0...100:
            return Double(contentOffset) / 100.0
        default:
            return 1
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                ZStack {
                    ScrollView(.vertical) {
                        ZStack {
                            VStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("권용태님")
                                    Text("점심 맛있게 드셨나요?")
                                    Text("식사 후에 ") + Text("오메가3").foregroundColor(Color.tintColor).fontWeight(.heavy) + Text(" 잊지마세요!")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: Layout.headerHeight, leading: 20, bottom: 10, trailing: 20))
                                .font(.system(size: 27, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    ZStack(alignment: .leading) {
                                        Color.white.opacity(0.1)
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("잊은 약❓").foregroundColor(.white).font(.title2).fontWeight(.bold)
                                            HStack {
                                                PillNameButtonView("아연")
                                            }
                                        }.padding(20)
                                    }.cornerRadius(20)
                                    Spacer(minLength: 20)
                                    ZStack(alignment: .leading) {
                                        Color.white.opacity(0.1)
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("먹은 약").foregroundColor(.white).font(.title2).fontWeight(.bold)
                                            HStack {
                                                PillNameButtonView("유산균")
                                                PillNameButtonView("아르기닌")
                                                PillNameButtonView("칼슘")
                                            }
                                        }.padding(20)
                                    }.cornerRadius(20)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                
                                ZStack {
                                    Color.white.opacity(0.1)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("월간 복용도").foregroundColor(.white).font(.title2).fontWeight(.bold)
                                        CalendarView(width: UIScreen.main.bounds.size.width - 80, fontColor: .white)
                                    }.padding(20)
                                }.cornerRadius(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                
                                Spacer()
                            }
                            
                            GeometryReader { geo in
                                let offset = geo.frame(in: .named("scroll")).minY
                                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: -offset)
                            }
                            
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                        self.contentOffset = value
                    }
                    
                    GeometryReader { geo in
                        ZStack {
                            Blur(style: .dark).opacity(headerViewOpacity)
                            VStack {
                                HStack {
                                    Text("💊 PillMe")
                                        .foregroundColor(.white)
                                        .font(.system(size: 23, weight: .semibold))
                                        .padding(.leading, 20)
                                    Spacer()
                                    NavigationLink(destination: LazyView(NewDoseScheduleView())) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.white)
                                    }.padding(.trailing, 10)
                                    NavigationLink(destination: LazyView(NewDoseScheduleView())) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.white)
                                    }.padding(.trailing, 20)
                                }.padding(.top, Layout.safeAreaTop)
                            }.padding(0)
                        }.frame(maxWidth: .infinity, maxHeight: Layout.headerHeight)
                        .ignoresSafeArea()
                    }
                }
            }
            .navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
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


struct PillNameButtonView: View {
    var name: String = ""
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Text(name)
            .padding(5)
            .foregroundColor(Color.black)
            .background(Color.white)
            .cornerRadius(5)
    }
}
