//
//  PillInfoCell.swift
//  Pillme
//
//  Created by USER on 2021/11/15.
//

import SwiftUI

struct PillInfoCell: View {
    @Binding var pill: Pill
    var subTitle: String = ""
    var body: some View {
        NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel(id: pill.id)))) {
            HStack(spacing: 10) {
                Image("pillIcon")
                    .resizable()
                    .frame(width: 44, height: 44, alignment: .center)
                    .padding(.leading, 20)
                VStack(alignment: .leading, spacing: 5) {
                    Text(subTitle.isEmpty ? pill.type.name : subTitle).foregroundColor(.gray).font(.system(size: 14))
                    Text("\(pill.name)").font(.system(size: 20, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 20)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .buttonStyle(BlinkOnPressStyle())
        .frame(maxWidth: .infinity)
    }
}

struct BlinkOnPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(.easeInOut, value: configuration.isPressed)
            .background(configuration.isPressed ? Color.black.opacity(0.1) : Color.clear)
    }
}
