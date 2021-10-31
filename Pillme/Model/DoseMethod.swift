//
//  DoseMethod.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//

import Foundation
import SwiftUI

enum TakeTime: Int, CaseIterable {
    case afterWakeup
    case beforeBreakfast
    case afterBreakfast
    case betweenBreakfastLunch
    case beforeLunch
    case afterLunch
    case betweenLunchDinner
    case beforeDinner
    case afterDinner
    case beforeSleep
    
    var title: String {
        switch self {
        case .afterWakeup: return "일어나자마자"
        case .beforeBreakfast: return "아침 먹기 전"
        case .afterBreakfast: return "아침 먹은 후"
        case .betweenBreakfastLunch: return "아침-점심 식간"
        case .beforeLunch: return "점심 먹기 전"
        case .afterLunch: return "점심 먹은 후"
        case .betweenLunchDinner: return "점심-저녁 식간"
        case .beforeDinner: return "저녁 먹기 전"
        case .afterDinner: return "저녁 먹은 후"
        case .beforeSleep: return "잠들기 전"
        }
    }
    
    var welcomeMessage: String {
        switch self {
        case .afterWakeup: return "상쾌한 아침입니다!"
        case .beforeBreakfast: return "바빠도 아침은 꼭 챙기세요!"
        case .afterBreakfast: return "좋은 하루 보내세요!"
        case .betweenBreakfastLunch: return "아침은 늘 힘들죠 😂"
        case .beforeLunch: return "오늘 점심 메뉴는 뭔가요?"
        case .afterLunch: return "점심 맛있게 드셨나요?"
        case .betweenLunchDinner: return "커피 한 잔 하시죠!"
        case .beforeDinner: return "벌써 배가 고프네요"
        case .afterDinner: return "맛있는 저녁 드셨나요?"
        case .beforeSleep: return "오늘 하루도 수고했어요."
        }
    }
    
    func encourageMessage(pillName: String) -> String {
        switch self {
        case .afterWakeup: return "\(pillName) 드시고 하루를 시작하세요!"
        case .beforeBreakfast: return "식전에 \(pillName)도 잊지 마시구요."
        case .afterBreakfast: return "아침 식사 후 \(pillName) 잊지 않으셨죠?"
        case .betweenBreakfastLunch: return "\(pillName) 드실 시간입니다"
        case .beforeLunch: return "점심 전에 \(pillName) 꼭 먹기!"
        case .afterLunch: return "식후엔 \(pillName) 빼먹지 마세요!"
        case .betweenLunchDinner: return "\(pillName)도 잊지 마시구요."
        case .beforeDinner: return "\(pillName) 드시고 저녁 식사하세요!"
        case .afterDinner: return "\(pillName) 챙기세요!"
        case .beforeSleep: return "\(pillName) 드시고 좋은 꿈 꾸세요."
        }
    }
    
    func encourageMessageView(pillName: String) -> some View { // todo
        Text(self.encourageMessage(pillName: pillName))
    }
    
    static var current: TakeTime {
        let nowComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return TakeTime.allCases.min { lhs, rhs in
            nowComponents.hourMinuteGap(with: lhs.components) < nowComponents.hourMinuteGap(with: rhs.components)
        } ?? .afterWakeup
    }
    
    static var closestNext: TakeTime {
        let nowComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        
        return TakeTime.allCases.first { takeTime in
            return nowComponents < takeTime.components
        } ?? .afterWakeup
    }
    
    var components: DateComponents {
        let userInfo = UserInfoManager.shared
        let minute = 60
        let time: Date
        switch self {
        case .afterWakeup:
            time = userInfo.wakeUpTime.time
        case .beforeBreakfast:
            time = userInfo.breakfastTime.time - TimeInterval(30 * minute)
        case .afterBreakfast:
            time = userInfo.breakfastTime.time + TimeInterval(30 * minute)
        case .betweenBreakfastLunch:
            let difference = userInfo.lunchTime.time.timeIntervalSince(userInfo.breakfastTime.time)
            time = userInfo.breakfastTime.time + difference / 2
        case .beforeLunch:
            time = userInfo.lunchTime.time - TimeInterval(30 * minute)
        case .afterLunch:
            time = userInfo.lunchTime.time + TimeInterval(30 * minute)
        case .betweenLunchDinner:
            let difference = userInfo.dinnerTime.time.timeIntervalSince(userInfo.lunchTime.time)
            time = userInfo.lunchTime.time + difference / 2
        case .beforeDinner:
            time = userInfo.dinnerTime.time - TimeInterval(30 * minute)
        case .afterDinner:
            time = userInfo.dinnerTime.time + TimeInterval(30 * minute)
        case .beforeSleep:
            time = userInfo.sleepTime.time - TimeInterval(30 * minute)
        }
        
        return Calendar.current.dateComponents([.hour, .minute], from: time)
    }
    
    var nextTime: TakeTime {
        return TakeTime(rawValue: self.rawValue + 1) ?? .afterWakeup
    }
    
    var prevTime: TakeTime {
        return TakeTime(rawValue: self.rawValue - 1) ?? .beforeSleep
    }
    
    var alertTime: DateComponents {
        let minute = 60
        guard let date = components.date else {
            return DateComponents(hour: components.hour, minute: components.minute)
        }
        return Calendar.current.dateComponents([.hour, .minute], from: date - TimeInterval(15 * minute))
    }
    
    var isLastTimeOfADay: Bool {
        return self.nextTime.components < self.components
    }
}

class DoseMethod {
    var time: TakeTime
    var num: Int = 1
    var pill: Pill?
    
    init(time: TakeTime, num: Int = 1, pill: Pill? = nil) {
        self.time = time
        self.num = num
        self.pill = pill
    }
    
    init(cdDoseMethod: CDDoseMethod) {
        self.time = TakeTime(rawValue: Int(cdDoseMethod.time)) ?? .afterWakeup
        self.num = Int(cdDoseMethod.num)
    }
}

extension DoseMethod: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(pill?.id.hashValue)
    }

    static func == (lhs: DoseMethod, rhs: DoseMethod) -> Bool {
        return lhs.time == rhs.time && lhs.pill == rhs.pill
    }
}

extension DateComponents {
    var hourMinuteIndex: Int {
        return (self.hour ?? 0)*60 + (self.minute ?? 0)
    }
    func hourMinuteGap(with other: DateComponents) -> Int {
        guard self.hourMinuteIndex > other.hourMinuteIndex else {
            return (24*60) - other.hourMinuteIndex + self.hourMinuteIndex
        }
        return self.hourMinuteIndex - other.hourMinuteIndex
    }
}
