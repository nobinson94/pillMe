//
//  NewDoseScheduleView.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import SwiftUI

protocol StepView {
    var question: String { get set }
    var step: Int { get set }
}

struct NewDoseScheduleView: View {
    
    @ObservedObject var viewModel: NewDoseScheduleViewModel = NewDoseScheduleViewModel()
    
    var currentStepView: some View {
        switch viewModel.step {
        case .takableTypeStep: return AnyView(TakableTypeStepView(type: $viewModel.pillType))
        case .nameStep: return AnyView(NameStepView(name: $viewModel.pillName))
        case .startDateStep: return AnyView(StartDateStepView())
        case .cycleStep: return AnyView(CycleStepView())
        case .oneDayStep: return AnyView(OneDayStepView())
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                currentStepView
                    .padding(.top, 50)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .background(Color.clear)
                Spacer(minLength: 10)
                Button("다음으로", action:
                        changeView)
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
            }.navigationBarHidden(true)
        }
        .background(Color.clear)
    }
    
    func changeView() {
        guard let nextStep = NewDoseScheduleStep(rawValue: viewModel.step.rawValue + 1) else {
            return
        }
        viewModel.step = nextStep
    }
}

struct NewDoseScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NewDoseScheduleView(viewModel: NewDoseScheduleViewModel())
    }
}

struct NameStepView: View {
    @Binding var name: String
    
    var body: some View {
        Text("먹으려는 약의 이름이 무엇입니까?").queustionText()
        TextField("", text: $name).underlineTextField()
    }
}

struct StartDateStepView: View {
    var body: some View {
        Text("언제부터 복용하나요?").queustionText()
    }
}

struct CycleStepView: View {
    var body: some View {
        Text("매일 드시나요?").queustionText()
    }
}

struct OneDayStepView: View {
    var body: some View {
        Text("드시는 날은 하루 몇 번 드실 건가요?").queustionText()
    }
}

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.white)
            .padding(10)
    }
    
    func queustionText() -> some View {
        self
            .foregroundColor(.white)
            .padding(.leading, 10)
            .padding(.top, 20)
            .padding(.bottom, 20)
            .font(.title2)
    }
}
