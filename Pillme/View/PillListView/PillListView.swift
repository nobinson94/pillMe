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
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(viewModel.pills, id: \.self) { pill in
                        NavigationLink(destination: LazyView(PillInfoView(viewModel: PillInfoViewModel(id: pill.id)))) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Image("pillIcon")
                                        .resizable()
                                        .frame(width: 26, height: 26, alignment: .center)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(pill.type.name)").foregroundColor(.gray).font(.system(size: 12))
                                        Text("\(pill.name)").font(.system(size: 19, weight: .bold))
                                    }
                                    Spacer()
                                }
                            }
                        }.foregroundColor(.white)
                    }
                }.padding(20)
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
    
    enum ListType {
        case today
        case all
    }
    
    var listType: ListType = .all
    var title: String {
        switch listType {
        case .today: return "오늘 먹을 약 목록"
        case .all: return "전체 약 목록"
        }
    }
    
    init(listType: ListType = .all) {
        self.listType = listType
    }
    
    func fetch() {
        switch listType {
        case .today:
            pills = PillMeDataManager.shared.getPills(for: Date())
        case .all:
            pills = PillMeDataManager.shared.getPills()
        }
    }
}
