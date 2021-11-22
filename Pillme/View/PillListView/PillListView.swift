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
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("복용중인 약 개수").font(.system(size: 16, weight: .regular))
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        HStack {
                            Text("\(viewModel.pills.count)개").font(.system(size: 28, weight: .bold))
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                    
                    ForEach($viewModel.pills, id: \.id) { pill in
                        PillInfoCell(pill: pill)
                    }
                }
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
    
    enum sortType: String {
        case all
        case pillType
        case weekday
        
        var name: String {
            switch self {
            case .all: return "전체"
            case .pillType: return "종류별"
            case .weekday: return "요일별"
            }
        }
    }
    
    @Published var pills: [Pill] = []
    
    var title: String { "복용 중인 약" }
    
    func fetch() {
        self.pills = PillMeDataManager.shared.getPills()
    }
}
