//
//  PillListView.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//
import Combine
import SwiftUI

struct PillListView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: PillListViewModel
    
    init(viewModel: PillListViewModel = PillListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
                .pillMeNavigationBar(title: viewModel.title, backButtonAction: {
                    presentationMode.wrappedValue.dismiss()
                })
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.pills, id: \.self) { pill in
                        PillInfoCell(pill: pill)
                    }
                }
                .padding(20)
            }
        }.onAppear {
            viewModel.fetch()
        }
    }
}

struct PillListView_Previews: PreviewProvider {
    static var previews: some View {
        PillListView()
    }
}

class PillListViewModel: ObservableObject {
    
    @Published var pills: [Pill] = []
    
    var title: String { "복용 중인 약" }

    func fetch() {
        self.pills = PillMeDataManager.shared.getPills()
    }
}
