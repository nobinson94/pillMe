//
//  MainVIew.swift
//  Pillme
//
//  Created by USER on 2021/09/24.
//

import SwiftUI

struct MainView: View {
    @State private var contentOffset: CGFloat = 0
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("권용태님")
                    Text("점심 맛있게 드셨나요?")
                    Text("식사 후에 ") + Text("오메가3").foregroundColor(Color.tintColor).fontWeight(.heavy) + Text(" 잊지마세요!")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                .font(.system(size: 27, weight: .bold, design: .default))
                .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("복용중인 약").foregroundColor(.white).font(.title2).fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        ForEach(viewModel.allTakables, id: \.id) { takable in
                            HStack {
                                Text("\(takable.name)")
                                Spacer()
                            }
                        }//.frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(Color.mainColor)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    
                    ZStack {
                        Color.mainColor
                        VStack(alignment: .leading, spacing: 10) {
                            Text("월간 복용도").foregroundColor(.white).font(.title2).fontWeight(.bold)
                            CalendarView(width: UIScreen.main.bounds.size.width - 80, fontColor: .white, selectable: false)
                        }.padding(20)
                    }.cornerRadius(20)
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Spacer()
            }
            .padding(.top, 30)
            .onAppear {
                viewModel.fetch()
            }
            
            GeometryReader { geo in
                let offset = geo.frame(in: .named("scroll")).minY
                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: -offset)
            }
            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
