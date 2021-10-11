//
//  DoseScheduleView.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//
import Combine
import SwiftUI

struct DoseScheduleView: View {
    
    enum Field: Hashable {
        case takableName
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewModel: DoseScheduleViewModel = DoseScheduleViewModel()
    @State private var showingAlert = false
    @State var isEditMode: Bool = true
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
                .pillMeNavigationBar(title: viewModel.title, backButtonAction: {
                    guard isEditMode else {
                        presentationMode.wrappedValue.dismiss()
                        return
                    }
                    showingAlert = true
                })
                .alert(isPresented: $showingAlert, content: {
                    Alert(title: Text("추가를 중단하고 나가기"),
                          message: Text("지금까지의 내용은 저장되지 않습니다. 정말 나가시겠습니까?"),
                          primaryButton: .cancel(Text("확인"), action: {
                            presentationMode.wrappedValue.dismiss()
                          }),
                          secondaryButton: .default(Text("취소")))
                })
            
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(DoseScheduleQuestion.allCases, id: \.self) { question in
                            if let currentQuestion = viewModel.currentQuestion, question == currentQuestion {
                                getQuestionView(of: question)
                                    .padding(.top, currentQuestion == .takableType ? 0 : 15)
                            } else if question.rawValue < (viewModel.lastQuestion?.rawValue ?? DoseScheduleQuestion.oneDay.rawValue + 1) {
                                HStack(spacing: 10) {
                                    getQuestionView(of: question)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "pencil")
                                        .frame(width: 44, alignment: .trailing)
                                        .onTapGesture {
                                            withAnimation {
                                                self.viewModel.currentQuestion = question
                                            }
                                        }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mainColor)
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
                
                if isEditMode {
                    if viewModel.currentQuestion == nil && viewModel.lastQuestion == nil {
                        Button {
                            withAnimation { self.viewModel.save() {
                                self.isEditMode = false
                            } }
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
            viewModel.reset()
        }.onChange(of: viewModel.currentQuestion) { question in
            if question == .name {
                self.focusedField = .takableName // issue:: 두번째 변경부터는 적용되지 않는다.
            } else {
                self.focusedField = nil
            }
        }
    }
    
    func getQuestionView(of step: DoseScheduleQuestion) -> AnyView {
        let view: AnyView
        switch step {
        case .takableType: view = AnyView(takableTypeQuestionView)
        case .name: view = AnyView(nameQuestionView)
        case .startDate: view = AnyView(startDateQuestionView)
        case .cycle: view = AnyView(cycleQuestionView)
        case .oneDay: view = AnyView(oneDayQuestionView)
        }
        return view
    }
    
    private var takableTypeQuestionView: some View {
        
        if viewModel.currentQuestion == .takableType {
            return AnyView(QuestionView(question: "약의 종류는 무엇인가요?") {
                HStack(alignment: .center, spacing: 5) {
                    ForEach(TakableType.allCases, id: \.self) { type in
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
                        .buttonStyle(PillMeButton(style: .medium, color: isSelected ? .tintColor : .mainColor, textColor: isSelected ? .mainColor : .white))
                    }
                }.frame(maxWidth: .infinity)
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
                        .underlineTextField()
                        .font(.system(size: 20))
                        .focused($focusedField, equals: .takableName)
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
                }
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
            if viewModel.cycle == 0 && viewModel.doseDays.isEmpty {
                return AnyView(QuestionView(question: "어떻게 드시나요?") {
                    HStack(alignment: .center) {
                        Button("매일매일 먹어요") {
                            self.viewModel.cycle = 1
                            self.viewModel.doseDays = []
                            self.viewModel.confirm()
                        }.buttonStyle(PillMeButton(style: .small))
                        Button("요일별로 먹어요") {
                            self.viewModel.cycle = -1
                            self.viewModel.doseDays = []
                        }.buttonStyle(PillMeButton(style: .small))
                        Button("주기에 따라 먹어요") {
                            self.viewModel.cycle = 2
                            self.viewModel.doseDays = []
                        }.buttonStyle(PillMeButton(style: .small))
                    }
                })
            } else if viewModel.cycle >= 1 {
                return AnyView(QuestionView(question: "며칠에 한번 드세요?") {
                    HStack(alignment: .center) {
                        Spacer()
                        TextField("", value: self.$viewModel.cycle, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .accentColor(.tintColor)
                            .foregroundColor(.tintColor)
                        Text("일 마다")
                            .padding(.trailing, 20)
                    }
                    .font(.system(size: 20))
                })
            } else if viewModel.cycle < 0 {
                return AnyView(QuestionView(question: "무슨 요일에 드세요?") {
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
                                .buttonStyle(PillMeButton(style: .small, color: .mainColor, textColor: .white))
                            }
                        }
                    }
                })
            } else {
                return AnyView(Spacer(minLength: 0))
            }
        } else {
            if self.viewModel.cycle < 0 {
                return AnyView(AnswerView(title: "복용 요일") {
                    Text(self.viewModel.doseDays.sorted { $0.rawValue < $1.rawValue }.map { $0.shortKor }.joined(separator: ", "))
                        .fontWeight(.semibold)
                        .foregroundColor(.tintColor)
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
                            .background(Color.mainColor)
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

struct DoseScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        DoseScheduleView()
    }
}

struct QuestionView<Content: View>: View {
    var question: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(question)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 32, weight: .ultraLight))
                .padding(0)
                .allowsTightening(true)
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
