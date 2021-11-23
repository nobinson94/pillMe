//
//  PillInfoView.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//
import Combine
import SwiftUI

struct PillInfoView: View {
    
    enum Field: Hashable {
        case pillName
    }
    
//    enum AlertType {
//        case
//    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewModel: PillInfoViewModel
    @State private var showingDismissAlert = false
    @State private var showingDeleteAlert = false
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
                .pillMeNavigationBar(
                    title: viewModel.title,
                    backButtonAction: {
                        guard viewModel.isEditMode && viewModel.lastQuestion != .pillType else {
                            presentationMode.wrappedValue.dismiss()
                            return
                        }
                        showingDismissAlert = true
                    }, rightView: navigationRightView)
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(DoseScheduleQuestion.allCases, id: \.self) { question in
                            if let currentQuestion = viewModel.currentQuestion, question == currentQuestion {
                                getQuestionView(of: question)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                            } else if question.rawValue < (viewModel.lastQuestion?.rawValue ?? DoseScheduleQuestion.oneDay.rawValue + 1) {
                                HStack(spacing: 10) {
                                    getQuestionView(of: question)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if viewModel.isEditMode {
                                        Image(systemName: "pencil")
                                            .frame(width: 44, alignment: .trailing)
                                            .onTapGesture {
                                                self.viewModel.currentQuestion = question
                                            }
                                    } else {
                                        Spacer()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.backgroundColor)
                                .cornerRadius(5)
                            }
                        }
                        .background(Color.clear)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
                
                if viewModel.isEditMode {
                    if viewModel.currentQuestion == nil && viewModel.lastQuestion == nil {
                        Button {
                            withAnimation { self.viewModel.save() }
                        } label: {
                            ZStack {
                                Color.tintColor.shadow(radius: 5).edgesIgnoringSafeArea(.bottom)
                                Text("저장").foregroundColor(.mainColor)
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 70, alignment: .center)
                        }
                    } else if viewModel.canConfirm {
                        Button {
                            withAnimation { self.viewModel.confirm() }
                        } label: {
                            ZStack {
                                Color.tintColor.shadow(radius: 5).edgesIgnoringSafeArea(.bottom)
                                Text("다음").foregroundColor(.mainColor)
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 70, alignment: .center)
                        }
                    }
                }
            }
            
        }.onAppear {
            viewModel.prepare()
        }.onChange(of: viewModel.currentQuestion) { question in
            if question == .name {
                self.focusedField = .pillName // issue:: 두번째 변경부터는 적용되지 않는다.
            } else {
                self.focusedField = nil
            }
        }
        .popup(isPresented: $showingDismissAlert) {
            BottomPopup {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("\(viewModel.isNewpill ? "추가를" : "변경을") 중단하고 나가기")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Text("지금까지의 변경사항은 저장되지 않습니다. 정말 나가시겠습니까?")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Button("취소") {
                            self.showingDismissAlert = false
                        }.buttonStyle(PillMeButton(style: .medium, color: .backgroundColor, textColor: .white))
                        Button("나가기") {
                            self.showingDismissAlert = false
                            self.presentationMode.wrappedValue.dismiss()
                        }.buttonStyle(PillMeButton(style: .medium, color: .tintColor, textColor: .backgroundColor))
                    }
                }
                .padding()
            }
        }
        .popup(isPresented: $showingDeleteAlert) {
            BottomPopup {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("삭제하기")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Text("지금까지의 \(viewModel.name) 복용기록도 삭제하시겠어요? 복용기록을 보관하시면 오늘이 마지막 복용일이 되고 내일부터는 복용 알림이 없습니다.")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Button("취소") {
                            self.showingDeleteAlert = false
                        }.buttonStyle(PillMeButton(style: .medium, color: .backgroundColor, textColor: .white))
                        Button("복용기록 보관") {
                            self.showingDeleteAlert = false
                            viewModel.finishDosePill {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }.buttonStyle(PillMeButton(style: .medium, color: .tintColor, textColor: .backgroundColor))
                        Button("모두 삭제") {
                            self.showingDeleteAlert = false
                            viewModel.deletePill {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }.buttonStyle(PillMeButton(style: .medium, color: .tintColor, textColor: .backgroundColor))
                    }
                }
                .padding()
            }
        }
    }
    
    func getQuestionView(of step: DoseScheduleQuestion) -> AnyView {
        let view: AnyView
        switch step {
        case .pillType: view = AnyView(pillTypeQuestionView)
        case .name: view = AnyView(nameQuestionView)
        case .startDate: view = AnyView(startDateQuestionView)
        case .cycle: view = AnyView(cycleQuestionView)
        case .oneDay: view = AnyView(oneDayQuestionView)
        }
        return view
    }
    
    
    private var navigationRightView: some View {
        if !viewModel.isEditMode {
            return AnyView(Button {
                self.viewModel.setEditMode(true)
            } label: {
                Text("수정").foregroundColor(.white)
            })
        } else if viewModel.isNewpill {
            return AnyView(EmptyView())
        } else {
            return AnyView(Button {
                self.showingDeleteAlert = true
            } label: {
                Text("삭제").foregroundColor(.white)
            })
        }
    }
    
    private var pillTypeQuestionView: some View {
        if viewModel.currentQuestion == .pillType {
            return AnyView(QuestionView(question: "약의 종류는 무엇인가요?") {
                HStack(alignment: .center, spacing: 5) {
                    ForEach(PillType.allCases, id: \.self) { type in
                        let isSelected = self.viewModel.type == type
                        Button(type.name) {
                            if viewModel.type == nil {
                                withAnimation {
                                    self.viewModel.type = type
                                    self.viewModel.confirm()
                                }
                            } else {
                                self.viewModel.type = type
                            }
                        }
                        .buttonStyle(PillMeButton(style: .medium, color: isSelected ? .tintColor : .backgroundColor, textColor: isSelected ? .mainColor : .white))
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
            })
        } else if let type = viewModel.type {
            return AnyView(AnswerView(title: "종류") {
                Text("\(type.name)")
                    .foregroundColor(.tintColor)
                    .fontWeight(.semibold)
            })
        } else {
            return AnyView(Spacer(minLength: 0))
        }
    }
    
    private var nameQuestionView: some View {
        
        return VStack(alignment: .leading, spacing: 0) {
            if viewModel.currentQuestion == .name {
                QuestionView(question: "약의 이름은 무엇인가요?") {
                    TextField("", text: $viewModel.name)
                        .underlineTextField(color: viewModel.nameDuplicated ? .red : .tintColor)
                        .font(.system(size: 20))
                        .focused($focusedField, equals: .pillName)
                    if viewModel.nameDuplicated {
                        Text("이미 존재하는 약의 이름입니다.").foregroundColor(.red)
                            .padding(.leading, 10)
                    }
                }
            } else {
                AnswerView(title: "이름") {
                    Text(viewModel.name)
                        .foregroundColor(.tintColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var startDateQuestionView: some View {
        if viewModel.currentQuestion == .startDate {
            return AnyView(QuestionView(question: "언제부터 복용하나요?") {
                Group {
                    Text(viewModel.startDate.dateString)
                        .font(.system(size: 20))
                        .foregroundColor(.tintColor)
                        .fontWeight(.semibold) +
                    Text("부터")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.light)
                }.padding(10)
                CalendarView(fontColor: .white, selectable: true, selectedDate: $viewModel.startDate)
                    .frame(maxWidth: .infinity)
            })
        } else {
            return AnyView(AnswerView(title: "복용 시작일") {
                Text(viewModel.startDate.dateString)
                    .foregroundColor(.tintColor)
                    .fontWeight(.semibold)
            })
        }
    }
    
    private var cycleQuestionView: some View {
        
        if viewModel.currentQuestion == .cycle {
            return AnyView(VStack(alignment: .leading, spacing: 30) {
                QuestionView(question: "어떻게 드시나요?") {
                    HStack(alignment: .center) {
                        Button("매일매일") {
                            self.viewModel.cycle = 1
                            self.viewModel.doseDays = []
                            self.viewModel.confirm()
                        }.buttonStyle(PillMeButton(style: .small, color: viewModel.cycle == 1 ? .tintColor : .backgroundColor, textColor: viewModel.cycle == 1 ? .backgroundColor : .white))
                        Button("요일별로") {
                            self.viewModel.cycle = -1
                            self.viewModel.doseDays = []
                        }.buttonStyle(PillMeButton(style: .small, color: viewModel.cycle == -1 ? .tintColor : .backgroundColor, textColor: viewModel.cycle == -1 ? .backgroundColor : .white))
                        Button("주기에 따라") {
                            self.viewModel.cycle = 2
                            self.viewModel.doseDays = []
                        }.buttonStyle(PillMeButton(style: .small, color: viewModel.cycle >= 2 ? .tintColor : .backgroundColor, textColor: viewModel.cycle >= 2 ? .backgroundColor : .white))
                    }.padding(10)
                }
                if viewModel.cycle >= 1 {
                    QuestionView(question: "며칠에 한번 드세요?") {
                        HStack(alignment: .center) {
                            Spacer()
                            TextField("", value: self.$viewModel.cycle, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .accentColor(.tintColor)
                                .foregroundColor(.tintColor)
                                .multilineTextAlignment(.trailing)
                            Text("일 마다")
                                .padding(.trailing, 20)
                        }
                        .font(.system(size: 20))
                    }
                } else if viewModel.cycle < 0 {
                    QuestionView(question: "무슨 요일에 드세요?") {
                        HStack(alignment: .center) {
                            ForEach(WeekDay.allCases, id: \.self) { doseDay in
                                if let index = self.viewModel.doseDays.firstIndex(of: doseDay) {
                                    Button(doseDay.shortKor) {
                                        self.viewModel.doseDays.remove(at: index)
                                    }
                                    .buttonStyle(PillMeButton(style: .small, color: .tintColor, textColor: .mainColor))
                                } else {
                                    Button(doseDay.shortKor) {
                                        self.viewModel.doseDays.append(doseDay)
                                    }
                                    .buttonStyle(PillMeButton(style: .small, color: .backgroundColor, textColor: .white))
                                }
                            }
                        }.padding(10)
                    }
                } else {
                    Spacer(minLength: 0)
                }
            })
        } else {
            if self.viewModel.cycle < 0 {
                return AnyView(AnswerView(title: "복용 요일") {
                    if viewModel.doseDays.count == 7 {
                        Text("\(1.cycleString)")
                            .fontWeight(.semibold)
                            .foregroundColor(.tintColor)
                    } else {
                        Text(self.viewModel.doseDays.sorted { $0.rawValue < $1.rawValue }.map { $0.shortKor }.joined(separator: ", "))
                            .fontWeight(.semibold)
                            .foregroundColor(.tintColor)
                    }
                })
            } else if self.viewModel.cycle > 0 {
                return AnyView(AnswerView(title: "복용 주기") {
                    Text("\(self.viewModel.cycle.cycleString)")
                        .fontWeight(.semibold)
                        .foregroundColor(.tintColor)
                })
            } else {
                return AnyView(Spacer(minLength: 0))
            }
        }
    }
    
    private var oneDayQuestionView: some View {
        let columns: [GridItem] = [
            GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5),
            GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5),
            GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5),
            GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5)
        ]
        
        if viewModel.currentQuestion == .oneDay {
            return AnyView(QuestionView(question: "복용법은 어떻게 되나요?") {
                VStack(alignment: .leading, spacing: 10) {
                    LazyVGrid(
                        columns: columns,
                        alignment: .center,
                        spacing: 5) {
                        ForEach(TakeTime.allCases, id: \.self) { takeTime in
                            let isAdded = self.viewModel.doseMethods.contains { $0.time == takeTime }
                            Button {
                                self.viewModel.doseMethods.append(DoseMethod(time: takeTime))
                            } label: {
                                Text(takeTime.title)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 5)
                                    .padding(.leading, 5)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .opacity(isAdded ? 0.4 : 1)
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.backgroundColor)
                            .cornerRadius(5)
                            .disabled(isAdded)
                        }
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(Array(self.viewModel.doseMethods.sorted { $0.time.rawValue < $1.time.rawValue }.enumerated()), id: \.offset) { index, doseMethod in
                            HStack {
                                Text(doseMethod.time.title).font(.system(size: 17))
                                Spacer()
                                Button {
                                    guard doseMethod.num > 1 else { return }
                                    doseMethod.num -= 1
                                    self.viewModel.objectWillChange.send()
                                } label: {
                                    Image(systemName: "minus.circle")
                                }.frame(minWidth: 45)
                                Text("\(doseMethod.num)정").font(.system(size: 17))
                                Button {
                                    doseMethod.num += 1
                                    self.viewModel.objectWillChange.send()
                                } label: {
                                    Image(systemName: "plus.circle")
                                }.frame(minWidth: 45)
                                Button {
                                    self.viewModel.doseMethods.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark").foregroundColor(.red)
                                }.frame(minWidth: 45)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(Color.tintColor)
                            .foregroundColor(.mainColor)
                            .cornerRadius(5)
                        }
                    }
                }
            })
        } else {
            return AnyView(AnswerView(title: "복용 방법") {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(self.viewModel.doseMethods.sorted { $0.time.rawValue < $1.time.rawValue }.enumerated()), id: \.offset) { index, doseMethod in
                        Text("\(doseMethod.time.title) (\(doseMethod.num)정)")
                            .fontWeight(.semibold)
                            .foregroundColor(.tintColor)
                    }
                }
            })
        }
    }
}

struct PillInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PillInfoView(viewModel: PillInfoViewModel())
    }
}

struct QuestionView<Content: View>: View {
    var question: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(question)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 28, weight: .bold))
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .allowsTightening(true)
            Spacer(minLength: 40)
            content
        }
    }
}

struct AnswerView<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
            content
        }
    }
}
