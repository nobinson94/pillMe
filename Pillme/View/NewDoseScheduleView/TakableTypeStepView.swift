//
//  TakableTypeStepView.swift
//  Pillme
//
//  Created by USER on 2021/08/24.
//

import SwiftUI

struct TakableTypeStepView: View {
    @Binding var type: TakableType?
    
    var body: some View {
        Text("먹으려는 약의 종류가 무엇입니까?")
            .queustionText()
        HStack {
            ForEach(TakableType.allCases, id: \.self) { type in
                Text(type.name)
                    .onTapGesture {
                        self.type = type
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .background(type == self.type ? Color.tintColor : Color.tintColor.opacity(0.4))
                    .foregroundColor(type == self.type ? Color.white : Color.white.opacity(0.4))
                    .cornerRadius(3)
                    .font(.system(size: 20))
            }
        }
    }
}

struct TakableTypeStepView_Previews: PreviewProvider {
    static var previews: some View {
        TakableTypeStepView(type: .constant(.pill))
    }
}
