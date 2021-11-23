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
                
                if !viewModel.allPills.isEmpty {
                    SectionView(title: "복용 관리", showMoreButton: true) {
                        ScheduleListView()
                    } content: {
                        if viewModel.schedules.isEmpty {
                            HStack {
                                Text("지금은 복용할 약이 없습니다")
                                    .lineSpacing(5)
                                    .padding(.leading, 20)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.gray)
                                Spacer(minLength: 20)
                            }
                        }
                        ForEach($viewModel.prevSchedules, id: \.self) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date, isTaken: schedule.isTaken)
                        }
                        ForEach($viewModel.currentSchedules, id: \.self) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date, isTaken: schedule.isTaken)
                        }
                        ForEach($viewModel.nextSchedules, id: \.self) { schedule in
                            TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date, isTaken: schedule.isTaken)
                        }
                    }
                }
                
                SectionView(title: "복용 중인 약", showMoreButton: viewModel.allPills.isEmpty ? false : true) {
                    PillListView()
                } content: {
                    if viewModel.allPills.isEmpty {
                        VStack(spacing: 0) {
                            NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel()))) {
                                HStack(spacing: 10) {
                                    Image("pillIcon")
                                        .resizable()
                                        .frame(width: 44, height: 44, alignment: .center)
                                        .padding(.leading, 20)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("새로운 약 추가하기").font(.system(size: 20, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing, 20)
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                            }
                            .buttonStyle(BlinkOnPressStyle())
                            .frame(maxWidth: .infinity)
                            Spacer(minLength: 20)
                            HStack {
                                Text("복용하시는 약이 없어요.\n건강을 위해 영양제를 추가해보세요!")
                                    .lineSpacing(5)
                                    .padding(.leading, 20)
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer(minLength: 20)
                            }
                            Spacer(minLength: 10)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(spacing: 0) {
                            ForEach((0..<min(5, viewModel.allPills.count)), id: \.self) { index in
                                PillInfoCell(pill: $viewModel.allPills[index])
                            }
                            if viewModel.allPills.count > 5 {
                                NavigationLink(destination: LazyView(PillListView())) {
                                    VStack {
                                        Spacer(minLength: 20)
                                        Rectangle().frame(height: 0.4, alignment: .top).foregroundColor(.white.opacity(0.2))
                                        Spacer(minLength: 25)
                                        Text("\(viewModel.allPills.count-5)개 더보기").foregroundColor(.white).font(.system(size: 16, weight: .semibold))
                                        Spacer(minLength: 10)
                                    }
                                }
                            }
                        }
                    }
                }
                
                SectionView(title: "\(viewModel.date.month)월 복용도", showMoreButton: true) {
                    DoseRecordCalendarView()
                } content: {
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
            if showMoreButton {
                NavigationLink(destination: LazyView(link)) {
                    HStack {
                        Text(title).foregroundColor(.white).font(.title2).fontWeight(.bold)
                        Spacer(minLength: 5)
                        Image(systemName: "chevron.forward")
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .foregroundColor(.white)
            } else {
                HStack {
                    Text(title).foregroundColor(.white).font(.title2).fontWeight(.bold)
                    Spacer(minLength: 10)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .foregroundColor(.white)
            }
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
