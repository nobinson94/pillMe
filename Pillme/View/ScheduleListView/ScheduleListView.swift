//
//  ScheduleListView.swift
//  Pillme
//
//  Created by USER on 2021/11/16.
//

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
                .pillMeNavigationBar(title: viewModel.title, backButtonAction: {
                    presentationMode.wrappedValue.dismiss()
                })
            
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(viewModel.schedules, id: \.header) { section in
                        Section(header: HStack {
                            Text(section.header)
                                .foregroundColor(Color.gray)
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                        }) {
                            VStack(spacing: 20) {
                                ForEach(section.items, id: \.self) { schedule in
                                    TakePillInfoCell(pill: schedule.pill, takeTime: schedule.takeTime, showSubTitle: false)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }.onAppear {
            viewModel.fetch()
        }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView()
    }
}

class ScheduleListViewModel: ObservableObject {
    @Published var schedules: [SectionModel<DoseSchedule>] = []
    var title: String { "복용 관리" }
    var date: Date = Date()
    
    init() {
        let currentTime = TakeTime.current
        if currentTime.isOverNight {
            date = date.yesterday
        }
    }
    
    func fetch() {
        let pills = PillMeDataManager.shared.getPills(for: date)
        schedules = TakeTime.allCases.compactMap { takeTime in
            let schedules = pills.filter { $0.doseMethods.contains(where: { $0.time == takeTime }) }.map { DoseSchedule(pill: $0, date: date, takeTime: takeTime) }
            if schedules.isEmpty { return nil }
            return SectionModel(header: takeTime.title, items: schedules)
        }
    }
}

struct SectionModel<Item> {
    var header: String
    var items: [Item]
}
