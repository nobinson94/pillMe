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
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
                .pillMeNavigationBar(title: "새로운 약 추가하기", backButtonAction: {
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
            
            VStack {
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(DoseScheduleQuestion.allCases, id: \.self) { question in
                            if let currentQuestion = viewModel.currentQuestion, question == currentQuestion {
                                getQuestionView(of: question)
                                    .padding(.top, currentQuestion == .takableType ? 0 : 15)
                            } else if question.rawValue < (viewModel.lastQuestion?.rawValue ?? DoseScheduleQuestion.oneDay.rawValue + 1) {
                                HStack {
                                    getQuestionView(of: question)
                                    Spacer()
                                    Image(systemName: "pencil")
                                        .frame(minWidth: 44, alignment: .trailing)
                                        .onTapGesture {
                                            withAnimation {
                                                self.viewModel.currentQuestion = question
                                            }
                                        }
                                }
                            }
                        }
                        .background(Color.clear)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
                
                if viewModel.canConfirm, viewModel.currentQuestion?.showNextButton ?? false {
                    Button {
                        withAnimation { self.viewModel.confirm() }
                    } label: {
                        Text("다음")
                            .frame(width: UIScreen.main.bounds.width, height: 70, alignment: .center)
                            .background(Color.tintColor)
                            .foregroundColor(.mainColor)
                    }
                }
            }
            
        }.onAppear {
            viewModel.reset()
        }.onChange(of: viewModel.currentQuestion) { question in
            if question == .name {
                print("### FOCUS!!")
                self.focusedField = .takableName
            } else {
                print("### UNFOCUS!!")
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
        VStack(alignment: .leading) {
            if viewModel.currentQuestion == .takableType {
                Text("약의 종류는 무엇인가요?")
                    .queustionText()
                    .padding(.bottom, 20)
                HStack(alignment: .center, spacing: 5) {
                    ForEach(TakableType.allCases, id: \.self) { type in
                        Button(type.name) {
                            self.viewModel.type = type
                            self.viewModel.confirm()
                        }
                        .buttonStyle(PillMeButton(style: .medium))
                    }
                }.frame(maxWidth: .infinity)
            } else {
                Group {
                    Text("약의 종류는 ") +
                    Text("\(viewModel.type.name)").foregroundColor(Color.tintColor).fontWeight(.semibold) +
                    Text("이고,")
                }.answerText()
            }
        }
    }
    
    private var nameQuestionView: some View {
        
        return VStack(alignment: .leading, spacing: 10) {
            if viewModel.currentQuestion == .name {
                Text("약의 이름이 무엇인가요?").queustionText()
                TextField("", text: $viewModel.name)
                    .underlineTextField()
                    .font(.system(size: 20))
                    .focused($focusedField, equals: .takableName)
            } else {
                Group {
                    Text("약의 이름은 ") +
                    Text(viewModel.name).foregroundColor(.tintColor).fontWeight(.semibold) +
                    Text("입니다.")
                }
                .answerText()
                .padding(.bottom, 5)
            }
        }
    }
    
    private var startDateQuestionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.currentQuestion == .startDate {
                Text("언제부터 복용하나요?")
                    .queustionText()
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
            } else {
                Group {
                    Text(viewModel.startDate.dateString)
                        .foregroundColor(.tintColor)
                        .fontWeight(.semibold) +
                    Text("부터 복용할 계획입니다.")
                }.answerText()
            }
        }
    }
    
    private var cycleQuestionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.currentQuestion == .cycle {
                if viewModel.cycle == 0 && viewModel.doseDays.isEmpty {
                    Text("어떻게 드시나요?").queustionText()
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
                } else if viewModel.cycle >= 1 {
                    Text("몇 일에 한 번 드시나요?").queustionText()
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
                } else if viewModel.cycle < 0 {
                    Text("무슨 요일에 드세요?").queustionText()
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
                }
            } else {
                Group {
                    if self.viewModel.cycle < 0 {
                        Text(self.viewModel.doseDays.sorted { $0.rawValue < $1.rawValue }.map { $0.shortKor }.joined(separator: ", ")).fontWeight(.semibold).foregroundColor(.tintColor) +
                        Text(" 복용합니다.")
                    } else if self.viewModel.cycle > 0 {
                        Text("\(self.viewModel.cycle.cycleString)").fontWeight(.semibold).foregroundColor(.tintColor) +
                        Text(" 복용합니다.")
                    }
                }.answerText()
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
        
        return VStack(alignment: .leading, spacing: 5) {
            Text("하루 중 복용하는 때를 선택하세요").queustionText()
            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 5) {
                ForEach(TakeTime.allCases, id: \.self) { takeTime in
                    if let index = self.viewModel.doseMethods.firstIndex { $0.time == takeTime } {
                        Button {
                            self.viewModel.doseMethods.remove(at: index)
                        } label: {
                            Text(takeTime.title)
                                .font(.system(size: 12))
                                .foregroundColor(.mainColor)
                                .padding(.trailing, 5)
                                .padding(.leading, 5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.tintColor)
                        .cornerRadius(5)
                    } else {
                        Button {
                            self.viewModel.doseMethods.append(DoseMethod(time: takeTime))
                        } label: {
                            Text(takeTime.title)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(.trailing, 5)
                                .padding(.leading, 5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.mainColor)
                        .cornerRadius(5)
                    }
                }
            }
        }
    }
}

struct DoseScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        DoseScheduleView()
    }
}
