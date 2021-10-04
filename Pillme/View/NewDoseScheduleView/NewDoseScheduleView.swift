//
//  NewDoseScheduleView.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import SwiftUI

struct NewDoseScheduleView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: NewDoseScheduleViewModel
    @State private var showingAlert = false
    
    init(viewModel: NewDoseScheduleViewModel = NewDoseScheduleViewModel()) {
        self.viewModel = viewModel
    }

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
        
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(NewDoseScheduleQuestion.allCases, id: \.self) { question in
                        if let currentQuestion = viewModel.currentQuestion, question == currentQuestion {
                            getQuestionView(of: question)
                                .padding(.top, currentQuestion == .takableType ? 0 : 15)
                            if viewModel.canConfirm, question.showNextButton {
                                Button {
                                    withAnimation { self.viewModel.confirm() }
                                } label: {
                                    Text("확인")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .frame(width: 50, height: 70, alignment: .trailing)
                                }
                            }
                        } else if question.rawValue < (viewModel.lastQuestion?.rawValue ?? NewDoseScheduleQuestion.oneDay.rawValue + 1) {
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
        }.onAppear {
            viewModel.reset()
        }
    }
    
    func getQuestionView(of step: NewDoseScheduleQuestion) -> AnyView {
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
        TakableQuestionView(type: $viewModel.pillType, isCurrentQuestion: viewModel.currentQuestion == .takableType) {
            withAnimation {
                viewModel.confirm()
            }
        }
    }
    
    private var nameQuestionView: some View {
        NameQuestionView(name: $viewModel.pillName, isCurrentQuestion: viewModel.currentQuestion == .name) {
            withAnimation {
                viewModel.confirm()
            }
        }
    }
    
    private var startDateQuestionView: some View {
        StartDateQuestionView(startDate: $viewModel.startDate, isCurrentQuestion: viewModel.currentQuestion == .startDate) {
            withAnimation {
                viewModel.confirm()
            }
        }
    }
    
    private var cycleQuestionView: some View {
        CycleQuestionView(cycle: $viewModel.cycle, hasFixedDays: $viewModel.hasFixedDays, weekDays: $viewModel.weekdays, isCurrentQuestion: viewModel.currentQuestion == .cycle) {
            withAnimation {
                viewModel.confirm()
            }
        }
    }
    
    private var oneDayQuestionView: some View {
        OneDayQuestionView(timesOfOneDay: $viewModel.timesOfOneDay, isCurrentQuestion: viewModel.currentQuestion == .oneDay)
    }
}

struct NewDoseScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NewDoseScheduleView()
    }
}

struct NameQuestionView: QuestionView {
    @Binding var name: String
    
    var currentStep: Int = 0
    var totalStep: Int = 1
    var question: NewDoseScheduleQuestion { .name }
    var isCurrentQuestion: Bool = false
    var goNextQuestion: (() -> Void)?
    
    var body: some View {
        if isCurrentQuestion {
            Text("약의 이름이 무엇인가요?").queustionText()
            TextField("", text: $name).underlineTextField().foregroundColor(.tintColor).font(.system(size: 20))
        } else {
            Group {
                Text("약의 이름은 ") +
                Text(name).foregroundColor(.tintColor).fontWeight(.semibold) +
                Text("입니다.")
            }
            .answerText()
            .padding(.bottom, 5)
        }
    }
}

struct StartDateQuestionView: QuestionView {
    @Binding var startDate: Date
    
    var currentStep: Int = 0
    var totalStep: Int = 1
    var question: NewDoseScheduleQuestion { .startDate }
    var isCurrentQuestion: Bool = false
    var goNextQuestion: (() -> Void)?
    var year: Int = Date().year
    var month: Int = Date().month
    var calendarHelper: CalendarHelper = CalendarHelper()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isCurrentQuestion {
                Text("언제부터 복용하나요?")
                    .queustionText()
                Group {
                    Text("\(startDate.dateString)")
                        .font(.system(size: 20))
                        .foregroundColor(.tintColor)
                        .fontWeight(.semibold) +
                    Text("부터")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.light)
                }
                CalendarView(fontColor: .white, selectable: true, selectedDate: $startDate)
                   .frame(maxWidth: .infinity)
            } else {
                Group {
                    Text(startDate.dateString).foregroundColor(.tintColor).fontWeight(.semibold) +
                    Text("부터 복용할 계획입니다.")
                }.answerText()
            }
        }
    }
}

struct CycleQuestionView: QuestionView {
    @Binding var cycle: Int
    @Binding var hasFixedDays: Bool
    @Binding var weekDays: [WeekDay]
    
    @State var currentStep: Int = 0
    
    var totalStep: Int = 3
    var question: NewDoseScheduleQuestion { .cycle }
    var isCurrentQuestion: Bool = false
    var goNextQuestion: (() -> Void)?
    
    var body: some View {
        if isCurrentQuestion {
            if currentStep == 0 {
                VStack(alignment: .leading, spacing: 10) {
                    Text("매일 드시나요?").queustionText()
                    HStack(alignment: .center, spacing: 10) {
                        Button("네") {
                            goNextQuestion?()
                            self.cycle = 1
                        }.buttonStyle(PillMeButton(style: .small))
                        Button("아니오") {
                            self.currentStep = 1
                        }.buttonStyle(PillMeButton(style: .small))
                    }
                }
            } else if currentStep == 1 {
                Text("어떻게 드시나요?").queustionText()
                HStack(alignment: .center) {
                    Button("요일별로 먹어요") {
                        self.hasFixedDays = true
                        self.cycle = 0
                        self.currentStep = 2
                    }.buttonStyle(PillMeButton(style: .small))
                    Button("주기에 따라 먹어요") {
                        self.hasFixedDays = false
                        self.cycle = 2
                        self.currentStep = 2
                    }.buttonStyle(PillMeButton(style: .small))
                }
            } else if currentStep == 2 {
                if hasFixedDays {
                    Text("무슨 요일에 드세요?").queustionText()
                    HStack(alignment: .center) {
                        ForEach(WeekDay.allCases, id: \.self) { weekDay in
                            Button("\(weekDay.shortKor)") {
                                if let index = weekDays.firstIndex(of: weekDay) {
                                    weekDays.remove(at: index)
                                } else {
                                    weekDays.append(weekDay)
                                }
                            }.buttonStyle(PillMeButton(style: .small))
                            .opacity(weekDays.contains(weekDay) ? 1 : 0.4)
                        }
                    }
                } else {
                    Text("몇 일에 한 번 드시나요?").queustionText()
                    HStack(alignment: .center) {
                        Spacer()
                        TextField("", value: $cycle, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .accentColor(.tintColor)
                            .foregroundColor(.tintColor)
    //                        .frame(width: 40)
                        Text("일 마다")
                            .padding(.trailing, 20)
                    }
                    .font(.system(size: 20))
                    .animation(.easeInOut)
                }
            }
        } else {
            Group {
                if hasFixedDays {
                    Text(weekDays.sorted { $0.rawValue < $1.rawValue }.map { $0.shortKor }.joined(separator: ", ")).fontWeight(.semibold).foregroundColor(.tintColor) +
                    Text(" 복용합니다.")
                } else if let cycle = cycle {
                    Text("\(cycle.cycleString)").fontWeight(.semibold).foregroundColor(.tintColor) +
                    Text(" 복용합니다.")
                }
            }.answerText()
        }
    }
}

struct OneDayQuestionView: QuestionView {
    @Binding var timesOfOneDay: [TakeTime]
    
    var currentStep: Int = 0
    var totalStep: Int = 1
    var question: NewDoseScheduleQuestion { .oneDay }
    var isCurrentQuestion: Bool = false
    var goNextQuestion: (() -> Void)?
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5),
        GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5),
        GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5),
        GridItem(.adaptive(minimum: 50, maximum: 100), spacing: 5)
    ]
    
    var body: some View {
        Text("하루 중 복용하는 때를 선택하세요").queustionText()
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 5) {
            ForEach(TakeTime.allCases, id: \.self) { takeTime in
                Button {
                    if let index = self.timesOfOneDay.firstIndex(of: takeTime) {
                        self.timesOfOneDay.remove(at: index)
                    } else {
                        self.timesOfOneDay.append(takeTime)
                    }
                } label: {
                    Text(takeTime.title)
                        .font(.system(size: 12))
                        .foregroundColor(self.timesOfOneDay.contains(takeTime) ? .mainColor : .white)
                        .padding(.trailing, 5)
                        .padding(.leading, 5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(self.timesOfOneDay.contains(takeTime) ? Color.tintColor : Color.mainColor)
                .cornerRadius(5)
            }
        }
    }
}
