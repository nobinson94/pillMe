//
//  TakableTypeStepView.swift
//  Pillme
//
//  Created by USER on 2021/08/24.
//

import Combine
import SwiftUI

struct TakableTypeStepView: StepView {
    var step: Int { 0 }
    var isCurrentStep: Bool = false
    
    @Binding var type: TakableType?
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("약의 종류는 ") + Text(type?.name ?? "").foregroundColor(Color.tintColor).fontWeight(.semibold) + Text("이고,")
            }.queustionText()
            .background(Color.black)
            .padding(.bottom, 20)
            HStack {
                ForEach(TakableType.allCases, id: \.self) { type in
                    Button(type.name) {
                        self.type = type
                        print("####")
                    }
                    .buttonStyle(PillTypeButtonStyle(isSelected: self.type == type))
                }
            }
        }
    }
}

struct TakableTypeStepView_Previews: PreviewProvider {
    static var previews: some View {
        TakableTypeStepView(type: .constant(.pill))
    }
}

struct PillTypeButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(isSelected ? Color.tintColor : Color.tintColor.opacity(0.4))
            .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.4))
            .cornerRadius(3)
            .font(.system(size: 20))
    }
}
