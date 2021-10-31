//
//  PillMeNotificationCenter.swift
//  Pillme
//
//  Created by USER on 2021/10/20.
//

import Foundation
import UserNotifications
import SwiftUI

class PillMeNotificationCenter {

    let userNotificationCenter = UNUserNotificationCenter.current()

    struct NotiIdentifier {
        static var alertPill: String { "PillAlert" }
    }
    
    init() {
        print("### PillMeNotificationCenter INIT")
        userNotificationCenter.getPendingNotificationRequests { requests in
            requests.forEach { request in
                print("#### \(request.content.title), \(request.content.body) \(request.content.userInfo["date"]) \(request.content.userInfo["takeTime"])")
            }
        }
    }
    
    func requestAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        
        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            guard let error = error else {
                return
            }
            print("### request Notification Auth Failed: \(error)")
        }
    }
    
    func setNextNotifications(for pillIDs: [String]) {
        pillIDs.forEach { pillID in
            guard let pill = PillMeDataManager.shared.getPill(id: pillID) else {
                return
            }
            setNextNotification(for: pill)
        }
    }
    
    func setNextNotification(for pill: Pill) {
        userNotificationCenter.getPendingNotificationRequests(completionHandler: { [self] requests in
            let originNotificationRequests = requests.filter({ request in
                guard let pillIDs = request.content.userInfo["pills"] as? String else { return false }
                return pillIDs.contains(pill.id)
            })
            
            originNotificationRequests.forEach { request in
                guard let alertDate = request.content.userInfo["date"] as? Date,
                      let takeTimeValue = request.content.userInfo["takeTime"] as? Int, let takeTime = TakeTime(rawValue: takeTimeValue) else { return }
                setNotification(alertDate: alertDate, takeTime: takeTime)
            }
        })
        
        if let nextTakeTime = pill.nextTakeTime {
            let today = Date()
            self.setNotification(alertDate: Calendar.current.startOfDay(for: today), takeTime: nextTakeTime)
        } else if let firstTakeTime = pill.doseMethods.first?.time {
            let nextTakeDate = pill.getNextTakeDate()
            self.setNotification(alertDate: Calendar.current.startOfDay(for: nextTakeDate), takeTime: firstTakeTime)
        }
    }
    
    func setNotification(alertDate: Date, takeTime: TakeTime) {
        var alertTimeComponenets = takeTime.alertTime
        alertTimeComponenets.year = alertDate.year
        alertTimeComponenets.month = alertDate.month
        alertTimeComponenets.day = alertDate.day

        guard let alertTime = Calendar.current.date(from: alertTimeComponenets) else {
            return
        }
        
        let identifier = self.notiIdentifier(date: alertDate, takeTime: takeTime)
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])

        // content
        let notiContent = UNMutableNotificationContent()
        let pills = PillMeDataManager.shared.getPills(for: alertDate, takeTime: takeTime)
        
        guard pills.count > 0 else {
            return
        }
        
        let pillListString = pills.map { $0.name }.joined(separator: ", ")
        notiContent.title = "\(takeTime.title) 약 드세요!"
        notiContent.body = "\(pillListString)"
        notiContent.userInfo = ["pills" : pills.map { $0.id }, "date": alertDate, "takeTime": takeTime.rawValue]
        
        // trigger
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alertTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: notiContent,
            trigger: trigger
        )
        
        print("#### setNotification: \(pillListString) \(alertTime.dateString) \(alertTime.timeString)")
        
        userNotificationCenter.add(request) { error in
            guard let error = error else {
                return
            }
            print("[addNotification Failed]: \(error)")
        }
    }
    
    func notiIdentifier(date: Date, takeTime: TakeTime) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return "\(formatter.string(from: date))_\(takeTime.title)_PillAlert"
    }

}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: lhs, to: now)! < calendar.date(byAdding: rhs, to: now)!
    }
}
