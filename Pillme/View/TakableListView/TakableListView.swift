//
//  TakableListView.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//
import Combine
import SwiftUI

struct TakableListView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: TakableListViewModel
    
    init(viewModel: TakableListViewModel = TakableListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
                .pillMeNavigationBar(title: "복용 중인 약 목록", backButtonAction: {
                    presentationMode.wrappedValue.dismiss()
                })
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(viewModel.takables, id: \.self) { takable in
                        Text("\(takable.name)")
                    }
                }
            }
        }.onAppear {
            viewModel.fetch()
        }
    }
}

struct TakableListView_Previews: PreviewProvider {
    static var previews: some View {
        TakableListView()
    }
}

class TakableListViewModel: ObservableObject {
    
    @Published var takables: [Takable] = []
    
    func fetch() {
        takables = PillMeDataManager.shared.getTakables()
    }
}
