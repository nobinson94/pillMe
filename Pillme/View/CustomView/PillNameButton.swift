//
//  PillNameButton.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//

import SwiftUI

struct PillNameButton: View {
    var name: String = ""
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Text(name)
            .font(.system(size: 14))
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .frame(minHeight: 30, alignment: .center)
            .foregroundColor(Color.mainColor)
            .background(Color.tintColor)
            .cornerRadius(5)
    }
}

struct PillNameButton_Previews: PreviewProvider {
    static var previews: some View {
        PillNameButton("버튼")
    }
}
