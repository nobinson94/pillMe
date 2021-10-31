//
//  CalendarView.swift
//  Pillme
//
//  Created by USER on 2021/08/26.
//

import Combine
import SwiftUI

struct CalendarView: View {
    
    @StateObject var calendarHelper: CalendarHelper = CalendarHelper()
    
    @State var showChangeMonthButton: Bool = true
    @State var width: CGFloat = UIScreen.main.bounds.size.width - 80
    @State var fontColor: Color = .black
    @State var selectable: Bool = true
    @Binding var selectedDate: Date
    
    init(fixMonth: Bool = false,
         width: CGFloat = UIScreen.main.bounds.size.width - 80,
         fontColor: Color = .white,
         selectable: Bool = false,
         selectedDate: Binding<Date> = .constant(Date())) {
        self._selectedDate = selectedDate
        self.showChangeMonthButton = !fixMonth
        self.fontColor = fontColor
        self.width = width
        self.selectable = selectable
    }
    
    var body: some View {
        VStack {
            
            HStack {
                if showChangeMonthButton {
                    Button(action: {
                        calendarHelper.setPrevMonth()
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
                    }, label: {
                        Image(systemName: "chevron.right")
                    }).padding(.trailing, 20)
                }
            }
            .foregroundColor(.white)
            .padding(.bottom, 20)
            .padding(.top, 20)
            .frame(width: width, height: 60, alignment: .center)
            
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(WeekDay.allCases, id: \.self) { weekDay in
                        WeekDayNameCellView(weekday: weekDay)
                            .frame(width: width/7, height: 25, alignment: .center)
                    }
                }
                ForEach(0..<6) { row in
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(1..<8) { weekDayIndex in
                            if calendarHelper.days.count > row*7+weekDayIndex-1, let day = calendarHelper.days[row*7+weekDayIndex-1]  {
                                DayCellView(day: day,
                                            weekday: WeekDay(rawValue: weekDayIndex),
                                            isToday: calendarHelper.isToday(day: day),
                                            isSelected: isSelected(day: day) && selectable)
                                    .onTapGesture() {
                                        self.selectDate(day: day)
                                    }
                                    .frame(width: width/7, height: 45, alignment: .center)
                            } else {
                                DayCellView(day: nil)
                                    .frame(width: width/7, height: 45, alignment: .center)
                            }
                        }
                    }
                }
            }
            .padding(.trailing, 5)
            .padding(.leading, 5)
            
        }
        .cornerRadius(20)
        .foregroundColor(fontColor)
    }
    
    func isSelected(day: Int) -> Bool {
        return calendarHelper.year == selectedDate.year && calendarHelper.month == selectedDate.month && day == selectedDate.day
    }
    
    func selectDate(day: Int) {
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

struct DayCellView: View {
    var day: Int?
    var weekday: WeekDay?
    var isToday: Bool = false
    var isSelected: Bool = false
    
    var textColor: Color {
        guard !isSelected else {
            return .white
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
                backgroundColor
                Text(String(day))
                    .font(.system(size: 14, weight: isToday ? .bold : .light))
                    .foregroundColor(textColor)
            }
            .cornerRadius(15)
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
        case .mon: return "월요일"
        case .tue: return "화요일"
        case .wed: return "수요일"
        case .thu: return "목요일"
        case .fri: return "금요일"
        case .sat: return "토요일"
        case .sun: return "일요일"
        }
    }
    
    var shortKor: String {
        guard let firstCharacter = kor.first else { return "" }
        return String(firstCharacter)
    }
}

class CalendarHelper: ObservableObject {
    
    @Published var days: [Int?] = []
    
    var year: Int = Date().year
    var month: Int = Date().month
    let formatter = DateFormatter()
    
    var title: String {
        formatter.dateFormat = "yyyy년 mm월"
        let dateString = "\(year)년 \(month)월"
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
    
    init() {
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
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = "\(year)-\(month)-\(day)"
        return Calendar.current.isDateInToday(dateString.date)
    }
}

extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var weekDay: WeekDay {
        let weekDayIndex = Calendar.current.component(.weekday, from: self)
        return WeekDay(rawValue: weekDayIndex) ?? .mon
    }
    
    var isLeapYear: Bool {
        self.year % 4 == 0 && self.year % 100 != 0
    }
    
    var dateCountOfMonth: Int {
        switch month {
        case 2:
            if isLeapYear {
                return 29
            } else {
                return 28
            }
        case 1, 3, 5, 7, 8, 10, 12: return 31
        default: return 30
        }
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        if self.year == Date().year {
            formatter.dateFormat = "M월 dd일"
        } else {
            formatter.dateFormat = "yyyy년 M월 dd일"
        }
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale.current
        
        if Calendar.current.isDateInToday(self) {
            return "오늘 (\(formatter.string(from: self)))"
        }
        
        return formatter.string(from: self)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale.current
        
        return formatter.string(from: self)
    }
    
    func compareOnlyTime(_ other: Date) -> ComparisonResult {
        guard self.hour != other.hour else {
            if self.minute == other.minute {
                return .orderedSame
            } else if self.minute < other.minute {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }
        
        if self.hour < other.hour {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
    
    var tommorrow: Date {
        self.addingTimeInterval(86400)
    }
    
    var yesterday: Date {
        self.addingTimeInterval(-86400)
    }
    
}
