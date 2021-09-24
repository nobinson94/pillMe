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

    init(viewModel: NewDoseScheduleViewModel = NewDoseScheduleViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.backward").imageScale(.large).accentColor(.white).padding(.trailing, 20)
                }))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitle("새로운 약 추가하기", displayMode: .automatic)
                
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(NewDoseScheduleStep.allCases, id: \.self) { step in
                        if step.rawValue < viewModel.currentStep.rawValue {
                            getStepView(of: step)
                        } else if step == viewModel.currentStep {
                            getStepView(of: step).padding(.top, 30)
                        }
                    }
                    .background(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    HStack(alignment: .center) {
                        Spacer()
                        Button {
                            withAnimation { viewModel.prev() }
                        } label: {
                            Text("이전")
                                .foregroundColor(.white)
                                .frame(width: 50, height: 70, alignment: .trailing)
                        }
                        if viewModel.canGoNext {
                            Button {
                                withAnimation { viewModel.next() }
                            } label: {
                                Text("다음")
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 70, alignment: .trailing)
                            }
                        }
                    }.frame(maxWidth: .infinity)
                    Spacer()
                }.frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
        }.onAppear {
            viewModel.reset()
        }
    }
    
    func changeStep(to step: NewDoseScheduleStep) {
        guard viewModel.currentStep != step else { return }
        withAnimation {
            viewModel.currentStep = step
        }
    }
    
    func getStepView(of step: NewDoseScheduleStep) -> AnyView {
        switch step {
        case .takableTypeStep: return AnyView(takableTypeStepView)
        case .nameStep: return AnyView(nameStepView)
        case .startDateStep: return AnyView(startDateStepView)
        case .cycleStep: return AnyView(cycleStepView)
        case .oneDayStep: return AnyView(oneDayStepView)
        }
    }
    
    private var currentStepView: some View {
        return AnyView(getStepView(of: viewModel.currentStep))
    }
    
    private var takableTypeStepView: some View {
        TakableTypeStepView(isCurrentStep: viewModel.currentStep == .takableTypeStep, type: $viewModel.pillType)
    }
    
    private var nameStepView: some View {
        NameStepView(isCurrentStep: viewModel.currentStep == .nameStep, name: $viewModel.pillName)
    }
    
    private var startDateStepView: some View {
        StartDateStepView(isCurrentStep: viewModel.currentStep == .startDateStep, startDate: $viewModel.startDate)
    }
    
    private var cycleStepView: some View {
        CycleStepView(isCurrentStep: viewModel.currentStep == .cycleStep, cycle: $viewModel.cycle)
    }
    
    private var oneDayStepView: some View {
        OneDayStepView(isCurrentStep: viewModel.currentStep == .oneDayStep)
    }
}

struct NewDoseScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NewDoseScheduleView()
    }
}

struct NameStepView: StepView {
    var step: NewDoseScheduleStep { .nameStep }
    var isCurrentStep: Bool = false
    
    @Binding var name: String
    
    var body: some View {
        if isCurrentStep {
            Text("약의 이름이 무엇인가요?").queustionText()
            TextField("", text: $name).underlineTextField().foregroundColor(.tintColor)
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

struct StartDateStepView: StepView {
    
    var step: NewDoseScheduleStep { .startDateStep }
    var isCurrentStep: Bool = false
    var year: Int = Date().year
    var month: Int = Date().month
    
    @Binding var startDate: Date
    
    var calendarHelper: CalendarHelper = CalendarHelper()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isCurrentStep {
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

struct CycleStepView: StepView {
    
    var step: NewDoseScheduleStep { .cycleStep }
    var isCurrentStep: Bool = false
    
    @State var isCycleDaily: Bool = true
    @Binding var cycle: Int
    
    var body: some View {
        if isCurrentStep {
            if isCycleDaily {
                HStack(alignment: .center, spacing: 10) {
                    Text("매일 드시나요?").queustionText()
                    Button("네") {
                        self.cycle = 1
                    }.queustionText()
                    Button("아니오") {
                        withAnimation {
                            isCycleDaily = false
                        }
                    }.queustionText()
                }
            } else {
                Text("몇 일에 한 번 드시나요?").queustionText()
                HStack(alignment: .center) {
                    Spacer()
                    TextField("", value: $cycle, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .accentColor(.tintColor)
                        .foregroundColor(.tintColor)
                        .font(.system(size: 20))
                        .frame(width: 40)
                    Text("일 마다")
                        .font(.system(size: 20))
                        .padding(.trailing, 20)
                }.animation(.easeInOut)
            }
        } else {
            Group {
                Text("\(cycle.cycleString)").fontWeight(.semibold).foregroundColor(.tintColor) +
                Text(" 복용합니다.")
            }.answerText()
        }
    }
}

struct OneDayStepView: StepView {
    var step: NewDoseScheduleStep { .oneDayStep }
    var isCurrentStep: Bool = false
    
    var body: some View {
        Text("하루 몇 번 드시나요?").queustionText()
    }
}

extension Int {
    var cycleString: String {
        guard self > 0 else { return "" }
        if self == 1 { return "매일" }
        return "\(self)일마다"
    }
}
