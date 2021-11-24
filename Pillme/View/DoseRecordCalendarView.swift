//
//  DoseRecordCalendarView.swift
//  Pillme
//
//  Created by USER on 2021/11/22.
//

import Combine
import SwiftUI

struct DoseRecordCalendarView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: DoseRecordCalendarViewModel
    
    init(viewModel: DoseRecordCalendarViewModel = DoseRecordCalendarViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
            ScrollView {
                VStack {
                    Spacer(minLength: 20)
                    VStack {
                        HStack {
                            Text("\(viewModel.selectedDate.month)월").font(.system(size: 32, weight: .bold))
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            Spacer()
                        }
                        Spacer(minLength: 20)
                        if viewModel.totalScheduleCount > 0 {
                            HStack {
                                Group {
                                    Text("\(viewModel.doseGrade ?? "0")%").foregroundColor(.tintColor)
                                        .font(.system(size: 24, weight: .bold)) +
                                    Text(" 복용했어요")
                                        .font(.system(size: 24, weight: .semibold))
                                }
                                .padding(.leading, 20)
                                Spacer(minLength: 20)
                            }
                            Spacer(minLength: 5)
                            HStack {
                                Text(viewModel.doseGradeMessage ?? "")
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(.leading, 20)
                                Spacer(minLength: 20)
                            }
                        } else {
                            HStack {
                                Text("\(viewModel.selectedDate.month)월에는 먹어야할 약이 없었어요")
                                    .font(.system(size: 24, weight: .semibold))
                                    .padding(.leading, 20)
                                Spacer(minLength: 20)
                            }
                        }
                        Spacer(minLength: 20)
                    }
                    CalendarView(selectable: true, showHeader: true, selectedDate: $viewModel.selectedDate, type: .doseGrade)
                        .background(Color.backgroundColor.cornerRadius(15))
                        .padding()
                    
                    if viewModel.totalScheduleCount > 0 {
                        HStack {
                            Text("\(viewModel.selectedDate.dateString)")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.leading, 20)
                            Spacer()
                        }
                        Spacer(minLength: 10)
                        if viewModel.doseSchedules.isEmpty {
                            VStack {
                                Spacer(minLength: 20)
                                Text("먹어야할 약이 없었어요").font(.system(size: 16))
                                Spacer(minLength: 20)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.backgroundColor.cornerRadius(15))
                            .padding()
                        } else {
                            VStack {
                                Spacer(minLength: 10)
                                ForEach(viewModel.doseSchedules, id: \.self) { schedule in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(schedule.takeTime.title)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                            Text("\(schedule.pill.name)")
                                                .font(.system(size: 16))
                                        }.padding(.leading, 20)
                                        Spacer()
                                        if schedule.isTaken {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                                .font(.system(size: 15))
                                                .padding(.trailing, 20)
                                        } else if !Calendar.current.isDateInToday(schedule.date) {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.red)
                                                .font(.system(size: 15))
                                                .padding(.trailing, 20)
                                        }
                                    }.frame(height: 45)
                                }
                                Spacer(minLength: 10)
                            }
                            .background(Color.backgroundColor.cornerRadius(15))
                            .padding()
                        }
                    }
                }
            }
            .animation(.easeIn(duration: 0.3), value: viewModel.selectedDate)
            .foregroundColor(.white)
        }
        .onAppear {
            viewModel.fetch()
        }
        .onChange(of: viewModel.selectedDate, perform: { date in
            viewModel.fetch()
        })
        .pillMeNavigationBar(title: viewModel.title, backButtonAction: {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct DoseRecordView_Previews: PreviewProvider {
    static var previews: some View {
        DoseRecordCalendarView()
    }
}

class DoseRecordCalendarViewModel: ObservableObject {
    
    private var bag = Set<AnyCancellable>()
    
    var title: String { "월별 복용도" }
    var takenScheduleCount: Int = 0
    var totalScheduleCount: Int = 0
    var doseGrade: String? {
        guard totalScheduleCount > 0 else { return nil }
        return String(format: "%.1f", Float(takenScheduleCount) / Float(totalScheduleCount) * 100)
    }
    var doseGradeMessage: String? {
        guard totalScheduleCount > 0 else { return nil }
        let doseGradeRate = Float(takenScheduleCount) / Float(totalScheduleCount)
        if doseGradeRate > 0.7 {
            return "훌륭해요!"
        } else if doseGradeRate > 0.4 {
            return "조금만 더 노력해요!"
        } else {
            return "건강을 위해서 제 때 약을 먹는 습관을 들여요"
        }
    }
    
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var doseSchedules: [DoseSchedule] = []

    init() {
        $selectedDate
            .removeDuplicates(by: { $0.year == $1.year && $0.month == $1.month })
            .sink { [weak self] date in
                guard let self = self else { return }
                self.fetchMonthlyDoseGrade(date: date)
            }
            .store(in: &bag)
    }
    
    func fetch() {
        let pills = PillMeDataManager.shared.getPills(for: selectedDate)
        doseSchedules = TakeTime.allCases.reduce([]) { schedules, takeTime in
            schedules + pills.filter { $0.doseMethods.contains(where: { $0.time == takeTime }) }
            .map { DoseSchedule(pill: $0, date: selectedDate, takeTime: takeTime) }
        }
    }
    
    func fetchMonthlyDoseGrade(date: Date) {
        let calendarHelper = CalendarHelper(date: date)
        var schedules: [DoseSchedule] = []
        calendarHelper.days.forEach { day in
            guard let day = day, !calendarHelper.isFuture(day: day) else { return }
            let date = calendarHelper.getDate(day: day)
            let pills = PillMeDataManager.shared.getPills(for: date)
            let doseSchedules = TakeTime.allCases.reduce([]) { schedules, takeTime in
                schedules + pills.filter { $0.doseMethods.contains(where: { $0.time == takeTime }) }
                .map { DoseSchedule(pill: $0, date: date, takeTime: takeTime) }
            }
            
            schedules += doseSchedules
        }
        self.totalScheduleCount = schedules.count
        self.takenScheduleCount = schedules.filter { $0.isTaken }.count
    }
}
