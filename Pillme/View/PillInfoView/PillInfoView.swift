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
                                            .foregroundColor(.white)
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
                                Text("??????").foregroundColor(.mainColor)
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 70, alignment: .center)
                        }
                    } else if viewModel.canConfirm {
                        Button {
                            withAnimation { self.viewModel.confirm() }
                        } label: {
                            ZStack {
                                Color.tintColor.shadow(radius: 5).edgesIgnoringSafeArea(.bottom)
                                Text("??????").foregroundColor(.mainColor)
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
                self.focusedField = .pillName // issue:: ????????? ??????????????? ???????????? ?????????.
            } else {
                self.focusedField = nil
            }
        }
        .popup(isPresented: $showingDismissAlert) {
            BottomPopup {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("\(viewModel.isNewpill ? "?????????" : "?????????") ???????????? ?????????")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Text("??????????????? ??????????????? ???????????? ????????????. ?????? ??????????????????????")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Button("??????") {
                            self.showingDismissAlert = false
                        }.buttonStyle(PillMeButton(style: .medium, color: .backgroundColor, textColor: .white))
                        Button("?????????") {
                            self.showingDismissAlert = false
                            self.presentationMode.wrappedValue.dismiss()
                        }.buttonStyle(PillMeButton(style: .medium, color: .tintColor, textColor: .backgroundColor))
                    }
                }
                .foregroundColor(.white)
                .padding()
            }
        }
        .popup(isPresented: $showingDeleteAlert) {
            BottomPopup {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("????????????")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Text("??????????????? \(viewModel.name) ??????????????? ?????????????????????? ??????????????? ??????????????? ????????? ????????? ???????????? ?????? ??????????????? ?????? ????????? ????????????.")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Button("??????") {
                            self.showingDeleteAlert = false
                        }.buttonStyle(PillMeButton(style: .medium, color: .backgroundColor, textColor: .white))
                        Button("???????????? ??????") {
                            self.showingDeleteAlert = false
                            viewModel.finishDosePill {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }.buttonStyle(PillMeButton(style: .medium, color: .tintColor, textColor: .backgroundColor))
                        Button("?????? ??????") {
                            self.showingDeleteAlert = false
                            viewModel.deletePill {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }.buttonStyle(PillMeButton(style: .medium, color: .tintColor, textColor: .backgroundColor))
                    }
                }
                .foregroundColor(.white)
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
                Text("??????").foregroundColor(.white)
            })
        } else if viewModel.isNewpill {
            return AnyView(EmptyView())
        } else {
            return AnyView(Button {
                self.showingDeleteAlert = true
            } label: {
                Text("??????").foregroundColor(.white)
            })
        }
    }
    
    private var pillTypeQuestionView: some View {
        if viewModel.currentQuestion == .pillType {
            return AnyView(QuestionView(question: "?????? ????????? ????????????????") {
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
            return AnyView(AnswerView(title: "??????") {
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
                QuestionView(question: "?????? ????????? ????????????????") {
                    TextField("", text: $viewModel.name)
                        .underlineTextField(color: viewModel.nameDuplicated ? .red : .tintColor)
                        .font(.system(size: 20))
                        .focused($focusedField, equals: .pillName)
                    if viewModel.nameDuplicated {
                        Text("?????? ???????????? ?????? ???????????????.").foregroundColor(.red)
                            .padding(.leading, 10)
                    }
                }
            } else {
                AnswerView(title: "??????") {
                    Text(viewModel.name)
                        .foregroundColor(.tintColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var startDateQuestionView: some View {
        if viewModel.currentQuestion == .startDate {
            return AnyView(QuestionView(question: "???????????? ????????????????") {
                Group {
                    Text(viewModel.startDate.dateString)
                        .font(.system(size: 20))
                        .foregroundColor(.tintColor)
                        .fontWeight(.semibold) +
                    Text("??????")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.light)
                }.padding(10)
                CalendarView(fontColor: .white, selectable: true, selectedDate: $viewModel.startDate)
                    .frame(maxWidth: .infinity)
            })
        } else {
            return AnyView(AnswerView(title: "?????? ?????????") {
                Text(viewModel.startDate.dateString)
                    .foregroundColor(.tintColor)
                    .fontWeight(.semibold)
            })
        }
    }
    
    private var cycleQuestionView: some View {
        
        if viewModel.currentQuestion == .cycle {
            return AnyView(VStack(alignment: .leading, spacing: 30) {
                QuestionView(question: "????????? ?????????????") {
                    HStack(alignment: .center) {
                        Button("????????????") {
                            self.viewModel.cycle = 1
                            self.viewModel.doseDays = []
                            self.viewModel.confirm()
                        }.buttonStyle(PillMeButton(style: .small, color: viewModel.cycle == 1 ? .tintColor : .backgroundColor, textColor: viewModel.cycle == 1 ? .backgroundColor : .white))
                        Button("????????????") {
                            self.viewModel.cycle = -1
                            self.viewModel.doseDays = []
                        }.buttonStyle(PillMeButton(style: .small, color: viewModel.cycle == -1 ? .tintColor : .backgroundColor, textColor: viewModel.cycle == -1 ? .backgroundColor : .white))
                        Button("????????? ??????") {
                            self.viewModel.cycle = 2
                            self.viewModel.doseDays = []
                        }.buttonStyle(PillMeButton(style: .small, color: viewModel.cycle >= 2 ? .tintColor : .backgroundColor, textColor: viewModel.cycle >= 2 ? .backgroundColor : .white))
                    }.padding(10)
                }
                if viewModel.cycle >= 1 {
                    QuestionView(question: "????????? ?????? ??????????") {
                        HStack(alignment: .center) {
                            Spacer()
                            TextField("", value: self.$viewModel.cycle, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .accentColor(.tintColor)
                                .foregroundColor(.tintColor)
                                .multilineTextAlignment(.trailing)
                            Text("??? ??????")
                                .padding(.trailing, 20)
                        }
                        .font(.system(size: 20))
                    }
                } else if viewModel.cycle < 0 {
                    QuestionView(question: "?????? ????????? ??????????") {
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
                return AnyView(AnswerView(title: "?????? ??????") {
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
                return AnyView(AnswerView(title: "?????? ??????") {
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
            return AnyView(QuestionView(question: "???????????? ????????? ??????????") {
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
                                Text("\(doseMethod.num)???").font(.system(size: 17))
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
            return AnyView(AnswerView(title: "?????? ??????") {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(self.viewModel.doseMethods.sorted { $0.time.rawValue < $1.time.rawValue }.enumerated()), id: \.offset) { index, doseMethod in
                        Text("\(doseMethod.time.title) (\(doseMethod.num)???)")
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
