//
//  TakePillInfoCell.swift
//  Pillme
//
//  Created by USER on 2021/11/15.
//

import SwiftUI

struct TakePillInfoCell: View {
    var pill: Pill
    var takeTime: TakeTime
    var takeDate: Date
    var doseMethod: DoseMethod?
    
    var subTitle: String {
        if let doseMethod = doseMethod {
            return "\(doseMethod.time.title) (\(doseMethod.num)정)"
        }
        return "\(takeTime.title)"
    }
    
    var title: String {
        guard let doseMethod = doseMethod else {
            return pill.name
        }

        return showSubTitle ? pill.name : "\(pill.name) (\(doseMethod.num)정)"
    }
    
    private var showSubTitle: Bool = true
    
    @State private var isTaken: Bool = false
    @State private var takeButtonDisabled: Bool = false
    
    
    init(pill: Pill, takeTime: TakeTime, takeDate: Date = Date(), showSubTitle: Bool = true) {
        self.pill = pill
        self.takeTime = takeTime
        self.doseMethod = self.pill.doseMethods.first(where: { $0.time == takeTime })
        self.takeDate = takeDate
        self.showSubTitle = showSubTitle
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image("pillIcon")
                .resizable()
                .frame(width: 26, height: 26, alignment: .center)
            VStack(alignment: .leading, spacing: 5) {
                if showSubTitle {
                    Text(subTitle)
                        .foregroundColor(.gray).font(.system(size: 14))
                }
                Text(title).font(.system(size: 20, weight: .bold))
            }
            Spacer()
            if isTaken {
                Button {
                    self.takeButtonDisabled = true
                    PillMeDataManager.shared.untakePill(for: pill.id, time: takeTime, date: Date()) {
                        self.takeButtonDisabled = false
                        self.isTaken = false
                    }
                } label: {
                    Text("복용 완료")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 70, height: 30)
                        .background(Color.tintColor.cornerRadius(5))
                        .foregroundColor(.backgroundColor)
                }.disabled(self.takeButtonDisabled)
            } else {
                Button {
                    self.takeButtonDisabled = true
                    PillMeDataManager.shared.takePill(for: pill.id, time: takeTime, date: Date()) {
                        self.takeButtonDisabled = false
                        self.isTaken = true
                    }
                } label: {
                    Text("복용 전")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 70, height: 30)
                        .background(Color.backgroundColor.cornerRadius(5).opacity(0.6))
                        .foregroundColor(.white)
                }.disabled(self.takeButtonDisabled)
            }
        }.onAppear {
            self.isTaken = PillMeDataManager.shared.isTaken(pillID: pill.id, takeTime: takeTime, date: takeDate)
        }
    }
}
