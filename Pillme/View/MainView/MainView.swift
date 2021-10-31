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
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
//                    Text("권용태님")
                    Text("\(viewModel.currentTime.welcomeMessage)")
                    Text("\(viewModel.currentTime.encourageMessage(pillName: "오메가3"))")
                }
                .padding(.leading, 5)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 27, weight: .bold, design: .default))
                .foregroundColor(.white)
                SectionView(title: "지금 먹을 약", showMoreButton: true) {
                    PillListView(viewModel: PillListViewModel(listType: .today))
                } content: {
                    if viewModel.nowPills.isEmpty {
                        VStack(spacing: 0){
                            Text("지금은 복용하실 약이 없어요!")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 90, alignment: .center)
                    } else {
                        if let prevTime = viewModel.prevTime {
                            ForEach(viewModel.prevPills, id: \.id) { pill in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        Image("pillIcon")
                                            .resizable()
                                            .frame(width: 26, height: 26, alignment: .center)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("\(prevTime.title)").foregroundColor(.gray).font(.system(size: 12))
                                            Text("\(pill.name)").font(.system(size: 19, weight: .bold))
                                        }
                                        Spacer()
                                        Button {
                                            print("### TAP")
                                        } label: {
                                            Text("먹었어요!")
                                                .font(.system(size: 12))
                                                .padding()
                                                .background(Color.backgroundColor.cornerRadius(10).opacity(0.6))
                                                .foregroundColor(.white)
                                        }

                                    }
                                }
                            }
                        }
                        
                        ForEach(viewModel.currentPills, id: \.id) { pill in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Image("pillIcon")
                                        .resizable()
                                        .frame(width: 26, height: 26, alignment: .center)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(viewModel.currentTime.title)").foregroundColor(.gray).font(.system(size: 12))
                                        Text("\(pill.name)").font(.system(size: 19, weight: .bold))
                                    }
                                    Spacer()
                                    Button {
                                        print("### TAP")
                                    } label: {
                                        Text("복용 전")
                                            .font(.system(size: 12))
                                            .padding()
                                            .background(Color.backgroundColor.cornerRadius(10).opacity(0.6))
                                            .foregroundColor(.white)
                                    }

                                }
                            }
                        }
                        
                        if let nextTime = viewModel.nextTime {
                            ForEach(viewModel.nextPills, id: \.id) { pill in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        Image("pillIcon")
                                            .resizable()
                                            .frame(width: 26, height: 26, alignment: .center)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("\(nextTime.title)").foregroundColor(.gray).font(.system(size: 12))
                                            Text("\(pill.name)").font(.system(size: 19, weight: .bold))
                                        }
                                        Spacer()
                                        Button {
                                            print("### TAP")
                                        } label: {
                                            Text("먹었어요!")
                                                .font(.system(size: 12))
                                                .padding()
                                                .background(Color.backgroundColor.cornerRadius(10).opacity(0.6))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
                
                SectionView(title: "복용 중인 약", showMoreButton: true) {
                    PillListView(viewModel: PillListViewModel(listType: .all))
                } content: {
                    if viewModel.allPills.isEmpty {
                        VStack(spacing: 0){
                            Text("오늘은 먹을 약이 없네요.\n건강을 위해 영양제를 추가해보세요!").lineSpacing(10)
                            NavigationLink(destination: LazyView(PillInfoView())) {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("새로운 약 추가하기").font(.system(size: 15, weight: .semibold))
                                }.frame(height: 100)
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 150, alignment: .center)
                    } else {
                        ForEach(viewModel.allPills, id: \.id) { pill in
                            NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel(id: pill.id)))) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        Image("pillIcon")
                                            .resizable()
                                            .frame(width: 26, height: 26, alignment: .center)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("\(pill.type.name)").foregroundColor(.gray).font(.system(size: 12))
                                            Text("\(pill.name)").font(.system(size: 19, weight: .bold))
                                        }
                                        Spacer()
                                    }
                                }
                            }.foregroundColor(.white)
                        }
                    }
                }
                
                SectionView(title: "월간 복용도", showMoreButton: false) {
                    CalendarView(width: UIScreen.main.bounds.size.width - 80, fontColor: .white, selectable: false)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            .padding(.leading, 20)
            .padding(.trailing, 20)
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

struct SectionView<Link: View, Content: View>: View {
    
    var title: String
    var showMoreButton: Bool
    
    @ViewBuilder var link: Link
    @ViewBuilder var content: Content
    
    init(title: String = "", showMoreButton: Bool = false, @ViewBuilder link: () -> Link, @ViewBuilder content: () -> Content) {
        self.title = title
        self.showMoreButton = showMoreButton
        self.link = link()
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink(destination: LazyView(link)) {
                HStack {
                    Text(title).foregroundColor(.white).font(.title2).fontWeight(.bold)
                    Spacer()
                    if showMoreButton {
                        Image(systemName: "chevron.forward")
                    }
                }
            }.foregroundColor(.white)
            content
        }
        .padding(20)
        .background(Color.mainColor)
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}

extension SectionView where Link == EmptyView {
    init(title: String = "", showMoreButton: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(title: title, showMoreButton: showMoreButton, link: { EmptyView() }, content: content)
    }
}

