//
//  MainVIew.swift
//  Pillme
//
//  Created by USER on 2021/09/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
//                    Text("권용태님") // environmentobject 활용 가능할듯
                    Text("\(viewModel.currentTime.welcomeMessage)")
                    if let encourageMessage = viewModel.encourageMessage {
                        Text(encourageMessage)
                    }
                }
                .padding(.leading, 5)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 27, weight: .bold, design: .default))
                .foregroundColor(.white)
                
                if !viewModel.schedules.isEmpty {
                    SectionView(title: "복용 관리", showMoreButton: true) {
                        ScheduleListView()
                    } content: {
                        ForEach($viewModel.prevSchedules, id: \.pill.id) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime)
                        }
                        ForEach($viewModel.currentSchedules, id: \.pill.id) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime)
                        }
                        ForEach($viewModel.nextSchedules, id: \.pill.id) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime)
                        }
                    }
                }
                
                SectionView(title: "복용 중인 약", showMoreButton: true) {
                    PillListView()
                } content: {
                    if viewModel.allPills.isEmpty {
                        VStack(spacing: 0){
                            Text("복용하시는 약이 없네요.\n건강을 위해 영양제를 추가해보세요!").lineSpacing(10)
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
                        ForEach($viewModel.allPills, id: \.id) { pill in
                            PillInfoCell(pill: pill)
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
