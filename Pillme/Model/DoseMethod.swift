//
//  DoseMethod.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//

import Foundation

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
    
    func encourageMessage(takableName: String) -> String {
        switch self {
        case .afterWakeup: return "\(takableName) 드시고 하루를 시작하세요!"
        case .beforeBreakfast: return "식전에 \(takableName)도 잊지 마시구요."
        case .afterBreakfast: return "아침 식사 후 \(takableName) 잊지 않으셨죠?"
        case .betweenBreakfastLunch: return "\(takableName) 드실 시간입니다"
        case .beforeLunch: return "점심 전에 \(takableName) 꼭 먹기!"
        case .afterLunch: return "식후엔 \(takableName) 빼먹지 마세요!"
        case .betweenLunchDinner: return "\(takableName)도 잊지 마시구요."
        case .beforeDinner: return "\(takableName) 드시고 저녁 식사하세요!"
        case .afterDinner: return "\(takableName) 챙기세요!"
        case .beforeSleep: return "\(takableName) 드시고 좋은 꿈 꾸세요."
        }
    }
}

class DoseMethod {
    var time: TakeTime
    var pillNum: Int = 1
    
    init(time: TakeTime, pillNum: Int = 1) {
        self.time = time
        self.pillNum = pillNum
    }
    
    init(cdDoseMethod: CDDoseMethod) {
        self.time = TakeTime(rawValue: Int(cdDoseMethod.time)) ?? .afterWakeup
        self.pillNum = Int(cdDoseMethod.pillNum)
    }
}
