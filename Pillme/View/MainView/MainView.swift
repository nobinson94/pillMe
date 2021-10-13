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
//                    Text("권용태님")
                    Text("\(viewModel.currentTime.welcomeMessage)")
                    Text("\(viewModel.currentTime.encourageMessage(takableName: "오메가3"))")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                .font(.system(size: 27, weight: .bold, design: .default))
                .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("지금 먹을 약").foregroundColor(.white).font(.title2).fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }.onTapGesture {
                            print("### TAP 지금 먹을 약")
                        }
                        
                        ForEach(viewModel.todayTakables, id: \.id) { takable in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Image("pillIcon")
                                        .resizable()
                                        .frame(width: 26, height: 26, alignment: .center)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(takable.type.name)").foregroundColor(.gray).font(.system(size: 12))
                                        Text("\(takable.name)").font(.system(size: 19, weight: .bold))
                                    }
                                    Spacer()
                                    Button {
                                        print("### TAP")
                                    } label: {
                                        
                                    }

                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.mainColor)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        NavigationLink(destination: LazyView(TakableListView())) {
                            HStack {
                                Text("복용 중인 약").foregroundColor(.white).font(.title2).fontWeight(.bold)
                                Spacer()
                                if !viewModel.todayTakables.isEmpty {
                                    Image(systemName: "chevron.forward")
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .disabled(viewModel.todayTakables.isEmpty)
                        if viewModel.todayTakables.isEmpty {
                            VStack(spacing: 0){
                                Text("오늘은 먹을 약이 없네요.\n건강을 위해 영양제를 추가해보세요!").lineSpacing(10)
                                NavigationLink(destination: LazyView(DoseScheduleView())) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("새로운 약 추가하기").font(.system(size: 16, weight: .semibold))
                                    }.frame(height: 100)
                                }
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, minHeight: 150, alignment: .center)
                        } else {
                            ForEach(viewModel.todayTakables, id: \.id) { takable in
                                NavigationLink(destination: LazyView(DoseScheduleView(viewModel: DoseScheduleViewModel(id: takable.id)))) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 10) {
                                            Image("pillIcon")
                                                .resizable()
                                                .frame(width: 26, height: 26, alignment: .center)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text("\(takable.type.name)").foregroundColor(.gray).font(.system(size: 12))
                                                Text("\(takable.name)").font(.system(size: 19, weight: .bold))
                                            }
                                            Spacer()
                                        }
                                    }
                                }.foregroundColor(.white)
                            }
                        }
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
