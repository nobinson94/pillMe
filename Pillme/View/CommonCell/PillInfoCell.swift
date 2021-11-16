//
//  PillInfoCell.swift
//  Pillme
//
//  Created by USER on 2021/11/15.
//

import SwiftUI

struct PillInfoCell: View {
    @Binding var pill: Pill
    
    var body: some View {
        NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel(id: pill.id)))) {
            HStack(spacing: 20) {
                Image("pillIcon")
                    .resizable()
                    .frame(width: 26, height: 26, alignment: .center)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(pill.type.name)").foregroundColor(.gray).font(.system(size: 14))
                    Text("\(pill.name)").font(.system(size: 20, weight: .bold))
                }
                Spacer()
            }
        }.foregroundColor(.white)
    }
}
