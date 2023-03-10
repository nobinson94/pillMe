//
//  TakePillInfoCell.swift
//  Pillme
//
//  Created by USER on 2021/11/15.
//
import Combine
import SwiftUI

struct TakePillInfoCell: View {
    @Binding var pill: Pill
    @Binding var takeTime: TakeTime
    @Binding var takeDate: Date
    @Binding var isTaken: Bool
    
    var doseMethod: DoseMethod? {
        self.pill.doseMethods.first(where: { $0.time == takeTime })
    }
    
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

    @State private var takeButtonDisabled: Bool = false
    
    init(pill: Binding<Pill>, takeTime: Binding<TakeTime>, takeDate: Binding<Date> = .constant(Date()), isTaken: Binding<Bool>, showSubTitle: Bool = true) {
        self._pill = pill
        self._takeTime = takeTime
        self._takeDate = takeDate
        self._isTaken = isTaken
        self.showSubTitle = showSubTitle
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image("pillIcon")
                .resizable()
                .frame(width: 44, height: 44, alignment: .center)
                .padding(.leading, 20)
            VStack(alignment: .leading, spacing: 5) {
                if showSubTitle {
                    Text(subTitle)
                        .foregroundColor(.gray).font(.system(size: 14))
                }
                Text(title).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            }
            Spacer()
            if isTaken {
                Button {
                    self.takeButtonDisabled = true
                    PillMeDataManager.shared.untakePill(for: pill.id, time: takeTime, date: takeDate) {
                        self.takeButtonDisabled = false
                        self.isTaken = false
                    }
                } label: {
                    Text("복용 완료")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 70, height: 30)
                        .background(Color.tintColor.cornerRadius(5))
                        .foregroundColor(.backgroundColor)
                }
                .disabled(self.takeButtonDisabled)
                .padding(.trailing, 20)
            } else {
                Button {
                    self.takeButtonDisabled = true
                    PillMeDataManager.shared.takePill(for: pill.id, time: takeTime, date: takeDate) {
                        self.takeButtonDisabled = false
                        self.isTaken = true
                    }
                } label: {
                    Text("복용 하기")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 70, height: 30)
                        .background(Color.backgroundColor.cornerRadius(5).opacity(0.6))
                        .foregroundColor(.white)
                }
                .disabled(self.takeButtonDisabled)
                .padding(.trailing, 20)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}
