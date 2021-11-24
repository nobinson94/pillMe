//
//  ScheduleListView.swift
//  Pillme
//
//  Created by USER on 2021/11/16.
//

import Combine
import SwiftUI

struct ScheduleListView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ScheduleListViewModel
    
    init(viewModel: ScheduleListViewModel = ScheduleListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 20)
                    HStack(alignment: .bottom) {
                        Text("\(viewModel.currentDateTitle) \(viewModel.currentDateString)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        Spacer()
                        Button {
                            viewModel.switchDate()
                        } label: {
                            HStack(alignment: .bottom) {
                                Text(viewModel.otherDateTitle)
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 20)
                            }
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.tintColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("하루가 더 지난 경우 복용기록을 수정할 수 없어요!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        
                    Spacer(minLength: 20)
                    
                    if viewModel.schedules.isEmpty {
                        VStack {
                            Text("복용할 약이 없습니다").foregroundColor(.white).font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    ForEach($viewModel.schedules, id: \.header) { section in
                        Section(header:
                            HStack {
                                Text(section.header.wrappedValue)
                                    .foregroundColor(Color.gray)
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.leading, 20)
                                Spacer()
                            }.frame(height: 50)
                        ) {
                            VStack(spacing: 20) {
                                ForEach(section.items, id: \.self) { schedule in
                                    TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, takeDate: schedule.date, isTaken: schedule.isTaken, showSubTitle: false)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetch()
        }
        .pillMeNavigationBar(title: viewModel.title, backButtonAction: {
            presentationMode.wrappedValue.dismiss()
        })
        
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView()
    }
}

class ScheduleListViewModel: ObservableObject {
    
    var title: String { "복용 관리" }
    private var bag = Set<AnyCancellable>()
    private var today: Date = Calendar.current.startOfDay(for: Date())
    @Published var schedules: [SectionModel<DoseSchedule>] = []
    @Published var currentDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var otherDate: Date = Calendar.current.startOfDay(for: Date())
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 dd일 (EE)"

        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale(identifier: "ko")
        
        return formatter.string(from: currentDate)
    }
    
    var currentDateTitle: String {
        if currentDate == today {
            return "오늘"
        } else if currentDate == today.yesterday {
            return "어제"
        }
        return ""
    }
    
    var otherDateTitle: String {
        if otherDate == today {
            return "오늘"
        } else if otherDate == today.yesterday {
            return "어제"
        }
        return ""
    }
    
    init() {
        if TakeTime.isOverNight {
            currentDate = currentDate.yesterday
            otherDate = today
        } else {
            otherDate = currentDate.yesterday
        }
    }
    
    func fetch() {
        let pills = PillMeDataManager.shared.getPills(for: currentDate)
        schedules = TakeTime.allCases.compactMap { takeTime in
            let schedules = pills.filter { $0.doseMethods.contains(where: { $0.time == takeTime }) }.map { DoseSchedule(pill: $0, date: currentDate, takeTime: takeTime) }
            if schedules.isEmpty { return nil }
            return SectionModel(header: takeTime.title, items: schedules)
        }
    }
    
    func switchDate() {
        let tempCurrentDate = currentDate
        self.currentDate = otherDate
        self.otherDate = tempCurrentDate
        self.fetch()
    }
}

struct SectionModel<Item> {
    var header: String
    var items: [Item]
}
