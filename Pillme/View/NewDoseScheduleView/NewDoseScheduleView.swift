//
//  NewDoseScheduleView.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import SwiftUI

struct NewDoseScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: NewDoseScheduleViewModel = NewDoseScheduleViewModel()
    
    var currentStepView: some View {
        AnyView(self.stepViews[viewModel.step])
    }
    
    var stepViews: [NewDoseScheduleStep: AnyView] = [:]
    
    init() {
        stepViews = [
            .takableTypeStep: AnyView(TakableTypeStepView(type: $viewModel.pillType)),
            .nameStep: AnyView(NameStepView(name: $viewModel.pillName)),
            .startDateStep: AnyView(StartDateStepView()),
            .cycleStep: AnyView(CycleStepView()),
            .oneDayStep: AnyView(OneDayStepView())
        ]
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
                .navigationBarTitle("새로운 약 추가하기")
                
            VStack(alignment: .leading) {
                currentStepView
                    .background(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(alignment: .center) {
                    Spacer()
                    Button("다음으로", action:
                            changeView)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 70, alignment: .trailing)
                }.frame(maxWidth: .infinity)
                Spacer()
            }.frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
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
        NewDoseScheduleView()
    }
}

struct NameStepView: View {
    @Binding var name: String
    
    var body: some View {
        Text("먹으려는 약의 이름이 무엇인가요?").queustionText()
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
