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
                if let encourageMessage = viewModel.encourageMessage {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(viewModel.currentTime.welcomeMessage)")
                        Text(encourageMessage)
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 27, weight: .bold, design: .default))
                    .foregroundColor(.white)
                }
                
                if !viewModel.schedules.isEmpty {
                    SectionView(title: "복용 관리", showMoreButton: true) {
                        ScheduleListView()
                    } content: {
                        ForEach($viewModel.prevSchedules, id: \.self) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date)
                        }
                        ForEach($viewModel.currentSchedules, id: \.self) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date)
                        }
                        ForEach($viewModel.nextSchedules, id: \.self) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date)
                        }
                    }
                }
                
                SectionView(title: "복용 중인 약", showMoreButton: true) {
                    PillListView()
                } content: {
                    if viewModel.allPills.isEmpty {
                        VStack(spacing: 0) {
                            Text("복용하시는 약이 없네요.\n건강을 위해 영양제를 추가해보세요!").lineSpacing(10)
                            NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel()))) {
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
                        VStack(spacing: 0) {
                            ForEach($viewModel.allPills, id: \.id) { pill in
                                PillInfoCell(pill: pill)
                            }
                        }
                    }
                }
                
                SectionView(title: "\(viewModel.date.month)월 복용도", showMoreButton: false) {
                    CalendarView(fontColor: .white,
                                 selectable: false,
                                 showHeader: false,
                                 type: .doseGrade)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
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
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .foregroundColor(.white)
            content
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
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
