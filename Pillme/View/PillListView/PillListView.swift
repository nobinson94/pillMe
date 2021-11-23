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
            VStack {
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("복용 중인 약").font(.system(size: 16, weight: .regular))
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
                    HStack(spacing: 0) {
                        ForEach(PillSortType.allCases, id: \.self) { sortType in
                            let isSelected = viewModel.sortType == sortType
                            Button {
                                viewModel.setSortType(sortType)
                            } label: {
                                VStack {
                                    Text(sortType.name)
                                        .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                                    Rectangle().frame(height: 2, alignment: .bottom).foregroundColor(isSelected ? .white : .clear)
                                }
                                .contentShape(Rectangle())
                                .frame(height: 30)
                            }.frame(maxWidth: .infinity)
                        }
                    }.frame(maxWidth: .infinity)
                    Rectangle().frame(height: 0.3, alignment: .bottom).foregroundColor(.white.opacity(0.3))
                }
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach($viewModel.pillSections, id: \.header) { section in
                            if !section.items.wrappedValue.isEmpty {
                                Section(header:
                                    HStack {
                                        Text(section.header.wrappedValue)
                                            .foregroundColor(Color.gray)
                                            .font(.system(size: 15, weight: .semibold))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }.frame(height: section.header.wrappedValue.isEmpty ? 10 : 50)
                                ) {
                                    VStack(spacing: 0) {
                                        ForEach(section.items, id: \.self) { pill in
                                            if viewModel.sortType == .doseType {
                                                if pill.wrappedValue.cycle == 1 {
                                                    PillInfoCell(pill: pill)
                                                } else if pill.wrappedValue.cycle > 1 {
                                                    PillInfoCell(pill: pill, subTitle: "\(pill.type.wrappedValue.name) #\(pill.wrappedValue.cycle)일마다")
                                                } else if pill.wrappedValue.doseDays.count < 7 {
                                                    PillInfoCell(pill: pill, subTitle: "\(pill.type.wrappedValue.name) #\(pill.wrappedValue.doseDays.hashTagString())")
                                                } else {
                                                    PillInfoCell(pill: pill)
                                                }
                                            } else {
                                                PillInfoCell(pill: pill)
                                            }
                                        }
                                    }
                                }
                            }
                        }
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

enum PillSortType: String, CaseIterable {
    case all
    case pillType
    case doseType
    
    var name: String {
        switch self {
        case .all: return "전체"
        case .pillType: return "종류별"
        case .doseType: return "용법별"
        }
    }
}

class PillListViewModel: ObservableObject {
    
    @Published var pills: [Pill] = []
    @Published var pillSections: [SectionModel<Pill>] = []
    @Published var sortType: PillSortType = .all
    
    var title: String { "복용 중인 약" }
    
    func fetch() {
        self.pills = PillMeDataManager.shared.getPills()
        setSortType(sortType)
    }
    
    func setSortType(_ sortType: PillSortType) {
        self.sortType = sortType
        
        switch sortType {
        case .all:
            pillSections = [SectionModel(header: "", items: pills)]
        case .pillType:
            pillSections = PillType.allCases.map { type in
                SectionModel(header: type.name, items: pills.filter { $0.type == type })
            }
        case .doseType:
            var sections: [SectionModel<Pill>] = []
            sections.append(SectionModel(header: "매일", items: pills.filter { $0.cycle == 1 }))
            sections.append(SectionModel(header: "주기별", items: pills.filter { $0.cycle > 1 }))
            sections.append(SectionModel(header: "요일별", items: pills.filter { $0.cycle < 1 && $0.doseDays.count < 7 && $0.doseDays.count > 0 }))
            pillSections = sections
        }
    }
}

extension Array where Element == WeekDay {
    func hashTagString() -> String {
        if self.count == 1 { return self.map { "\($0.shortKor)요일"}.joined(separator: "") }
        return self.sorted { $0.rawValue < $1.rawValue }.map { $0.shortKor }.joined(separator: "")
    }
}
