//
//  CalendarView.swift
//  Pillme
//
//  Created by USER on 2021/08/26.
//

import Combine
import SwiftUI

enum CalendarType: String {
    case common
    case doseGrade
}

struct CalendarView: View {
    
    @ObservedObject var calendarHelper: CalendarHelper
    
    var showChangeMonthButton: Bool = true
    var fontColor: Color = .black
    var selectable: Bool = false
    var showHeader: Bool = true
    var type: CalendarType = .common
    
    @Binding var selectedDate: Date
    
    var height: CGFloat {
        let endDayIndex = calendarHelper.days.endIndex
        let rowCount: Int
        if endDayIndex / 7 == 4 && endDayIndex % 7 == 0 {
            rowCount = 4
        } else if endDayIndex / 7 == 4 {
            rowCount = 5
        } else {
            rowCount = 6
        }
        if showHeader {
            return CGFloat((rowCount+1)*45 + 70 + 45)
        } else {
            return CGFloat((rowCount+1)*45 + 20)
        }
    }
    
    init(fixMonth: Bool = false,
         fontColor: Color = .white,
         selectable: Bool = false,
         showHeader: Bool = true,
         selectedDate: Binding<Date> = .constant(Date()),
         type: CalendarType = .common) {
        self._selectedDate = selectedDate
        self.showChangeMonthButton = !fixMonth
        self.fontColor = fontColor
        self.selectable = selectable
        self.showHeader = showHeader
        self.calendarHelper = CalendarHelper(date: selectedDate.wrappedValue)
        self.type = type
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if showHeader {
                    HStack {
                        if showChangeMonthButton {
                            Button(action: {
                                calendarHelper.setPrevMonth()
                                if type == .doseGrade {
                                    self.selectDate(day: 1)
                                }
                            }, label: {
                                Image(systemName: "chevron.left")
                            }).padding(.leading, 20)
                        }
                        Spacer()
                        Text(calendarHelper.title).fontWeight(.medium)
                        Spacer()
                        if showChangeMonthButton {
                            Button(action: {
                                calendarHelper.setNextMonth()
                                if type == .doseGrade {
                                    self.selectDate(day: 1)
                                }

                            }, label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor((type == .doseGrade && calendarHelper.isThisMonth) ? .white.opacity(0.2) : .white)
                            })
                            .padding(.trailing, 20)
                            .disabled(type == .doseGrade && calendarHelper.isThisMonth)
                        }
                    }
                    .frame(height: 30)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                } else {
                    Spacer(minLength: 20)
                }
                    
                VStack {
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(WeekDay.allCases, id: \.self) { weekDay in
                            WeekDayNameCellView(weekday: weekDay)
                                .frame(width: geometry.size.width/7, height: 25, alignment: .center)
                        }
                    }
                    ForEach(0..<6) { row in
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(1..<8) { weekDayIndex in
                                if calendarHelper.days.count > row*7+weekDayIndex-1, let day = calendarHelper.days[row*7+weekDayIndex-1]  {
                                    cell(day: day, weekDay: WeekDay(rawValue: weekDayIndex))
                                        .frame(width: geometry.size.width/7, height: 45, alignment: .center)
                                } else {
                                    CommonDayCell(day: nil)
                                        .frame(width: geometry.size.width/7, height: 45, alignment: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: self.height)
        .foregroundColor(fontColor)
    }
    
    func cell(day: Int, weekDay: WeekDay?) -> AnyView {
        if type == .doseGrade {
            let date = calendarHelper.getDate(day: day)
            let pills = PillMeDataManager.shared.getPills(for: date)
            let schedulesCount = pills.reduce(0) { $0 + $1.doseMethods.count }
            let doseRecordsCount = PillMeDataManager.shared.getDoseRecords(date: date).count
            let doseGrade: Float? = schedulesCount == 0 ? nil : Float(doseRecordsCount) / Float(schedulesCount)
            let isFuture = calendarHelper.isFuture(day: day)
            return AnyView(DoseInfoDayCell(day: day,
                                           weekday: weekDay,
                                           isFuture: isFuture,
                                           isToday: calendarHelper.isToday(day: day),
                                           isSelected: isSelected(day: day) && selectable,
                                           doseGrade: doseGrade)
                            .onTapGesture {
                if !isFuture {
                    self.selectDate(day: day)
                }
            })
            
        } else {
            return AnyView(CommonDayCell(day: day,
                                         weekday: weekDay,
                                         isToday: calendarHelper.isToday(day: day),
                                         isSelected: isSelected(day: day) && selectable)
                            .onTapGesture {
                self.selectDate(day: day)
            })
        }
    }
    
    func isSelected(day: Int) -> Bool {
        return calendarHelper.year == selectedDate.year && calendarHelper.month == selectedDate.month && day == selectedDate.day
    }
    
    func selectDate(day: Int) {
        guard selectable else { return }
        self.selectedDate = "\(calendarHelper.year)-\(calendarHelper.month)-\(day)".date
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .background(Color.black)
    }
}

struct WeekDayNameCellView: View {
    var weekday: WeekDay
    var textColor: Color {
        switch weekday {
        case .sun: return .red.opacity(0.6)
        case .sat: return .blue.opacity(0.6)
        default: return .white.opacity(0.4)
        }
    }
    
    var body: some View {
        Text(weekday.shortKor)
            .padding(0)
            .font(.system(size: 13, weight: .light))
            .foregroundColor(textColor)
    }
}

protocol DayPresentableCell: View {
    var day: Int? { get set }
    var weekday: WeekDay? { get set }
    var isToday: Bool { get set }
    
    var textColor: Color { get }
    var backgroundColor: Color { get }
}

struct DoseInfoDayCell: DayPresentableCell {
    var day: Int?
    var weekday: WeekDay?
    var isFuture: Bool = false
    var isToday: Bool = false
    var isSelected: Bool = false
    var doseGrade: Float?

    var textColor: Color {
        if isSelected { return .mainColor }
        if isToday && !isSelected { return .tintColor }
        return isFuture ? .white.opacity(0.2) : .white
    }

    var backgroundColor: Color {
        guard !isSelected else {
            return .tintColor
        }
        return .clear
    }
    
    var circleStrokeColor: Color {
        return .tintColor
    }

    var body: some View {
        if let day = day {
            ZStack {
                Circle()
                    .padding(10)
                    .foregroundColor(backgroundColor)
                if !isFuture, let doseGrade = doseGrade {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                        .opacity(0.2)
                        .foregroundColor(circleStrokeColor)
                        .padding(5)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(doseGrade, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(circleStrokeColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .padding(5)
                }
                Text(String(day))
                    .font(.system(size: 14, weight: isToday ? .bold : .light))
                    .foregroundColor(textColor)
            }
        } else {
            Text("")
                .padding(0)
        }
    }
}

struct CommonDayCell: DayPresentableCell {
    var day: Int?
    var weekday: WeekDay?
    var isToday: Bool = false
    var isSelected: Bool = false
    
    var textColor: Color {
        guard !isSelected else {
            return .mainColor
        }
        guard !isToday else {
            return .tintColor
        }
        switch weekday {
        case .sun, .sat: return .white.opacity(0.4)
        default: return .white
        }
    }
    
    var backgroundColor: Color {
        guard !isSelected else {
            return .tintColor
        }
        return .clear
    }
    
    var body: some View {
        if let day = day {
            ZStack {
                Circle()
                    .padding(10)
                    .foregroundColor(backgroundColor)
                Text(String(day))
                    .font(.system(size: 14, weight: isToday ? .bold : .light))
                    .foregroundColor(textColor)
            }
        } else {
            Text("")
                .padding(0)
        }
    }
}


enum WeekDay: Int, CaseIterable {
    case sun = 1
    case mon = 2
    case tue = 3
    case wed = 4
    case thu = 5
    case fri = 6
    case sat = 7
    
    var kor: String {
        switch self {
        case .mon: return "?????????"
        case .tue: return "?????????"
        case .wed: return "?????????"
        case .thu: return "?????????"
        case .fri: return "?????????"
        case .sat: return "?????????"
        case .sun: return "?????????"
        }
    }
    
    var shortKor: String {
        guard let firstCharacter = kor.first else { return "" }
        return String(firstCharacter)
    }
}

class CalendarHelper: ObservableObject {
    
    @Published var days: [Int?] = []
    
    var year: Int
    var month: Int
    let formatter = DateFormatter()
    
    var title: String {
        formatter.dateFormat = "yyyy??? mm???"
        let dateString = "\(year)??? \(month)???"
        let date = formatter.date(from: dateString) ?? Date()
        return formatter.string(from: date)
    }
    
    var firstDateOfThisMonth: Date {
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = "\(year)-\(month)-01"
        return formatter.date(from: dateString) ?? Date()
    }
    
    var firstWeekDayOfThisMonth: WeekDay {
        firstDateOfThisMonth.weekDay
    }
    
    var isThisMonth: Bool {
        let today = Date()
        return today.year == year && today.month == month
    }
    
    init(date: Date? = nil) {
        let today = Date()
        self.year = date?.year ?? today.year
        self.month = date?.month ?? today.month
        setDays()
    }
    
    func setNextMonth() {
        if month == 12 {
            month = 1
            year += 1
        } else {
            month += 1
        }
        setDays()
    }
    
    func setPrevMonth() {
        if month == 1 {
            month = 12
            year -= 1
        } else {
            month -= 1
        }
        setDays()
    }
    
    func setDate(month: Int, year: Int) {
        self.month = month
        self.year = year
        setDays()
    }
    
    func setDays() {
        var days: [Int?] = []
        let dateCountOfMonth = firstDateOfThisMonth.dateCountOfMonth
        let firstWeekDayIndex = firstWeekDayOfThisMonth.rawValue - 1
        for _ in 0..<firstWeekDayIndex {
            days.append(nil)
        }
        
        for day in 1...dateCountOfMonth {
            days.append(day)
        }

        self.days = days
    }
    
    func isToday(day: Int) -> Bool {
        return Calendar.current.isDateInToday(self.getDate(day: day))
    }
    
    func isFuture(day: Int) -> Bool {
        return Calendar.current.startOfDay(for: Date().tommorrow) <= self.getDate(day: day)
    }
    
    func getDate(day: Int) -> Date {
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = "\(year)-\(month)-\(day)"
        
        return dateString.date
    }
}
