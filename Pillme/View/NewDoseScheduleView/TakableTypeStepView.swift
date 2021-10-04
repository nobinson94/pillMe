//
//  TakableTypeStepView.swift
//  Pillme
//
//  Created by USER on 2021/08/24.
//

import Combine
import SwiftUI

struct TakableQuestionView: QuestionView {
    var currentStep: Int = 0
    var totalStep: Int = 1
    @Binding var type: TakableType?
    var question: NewDoseScheduleQuestion { .takableType }
    var isCurrentQuestion: Bool = false
    var goNextQuestion: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if isCurrentQuestion {
                Text("약의 종류는 무엇인가요? ")
                    .queustionText()
                    .padding(.bottom, 20)
                HStack(alignment: .center, spacing: 5) {
                    ForEach(TakableType.allCases, id: \.self) { type in
                        Button(type.name) {
                            self.type = type
                            self.goNextQuestion?()
                        }
                        .buttonStyle(PillMeButton(style: .medium))
                    }
                }.frame(maxWidth: .infinity)
            } else {
                Group {
                    Text("약의 종류는 ") + Text("\(type?.name ?? "")").foregroundColor(Color.tintColor).fontWeight(.semibold) + Text("이고,")
                }.answerText()
            }
        }
    }
}

struct TakableQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            TakableQuestionView(type: .constant(.pill), isCurrentQuestion: true)
        }
    }
}


enum PillMeButtonStyle {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 45
        case .medium: return 60
        case .large: return 100
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 17
        case .large: return 22
        }
    }
}

struct PillMeButton: ButtonStyle {
    var style: PillMeButtonStyle = .medium
    var fontSize: CGFloat { style.fontSize }
    var height: CGFloat { style.height }
    var color: Color = .tintColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.mainColor)
            .font(.system(size: fontSize))
            .frame(maxWidth: .infinity, minHeight: height)
            .background(color)
            .cornerRadius(10)
    }
}
