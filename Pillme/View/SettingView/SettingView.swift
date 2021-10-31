//
//  SettingView.swift
//  Pillme
//
//  Created by USER on 2021/10/12.
//
import Combine
import SwiftUI

struct SettingView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: SettingViewModel
    @State private var showingAlert = false
    @State private var isEditMode: Bool = false
    
    init(viewModel: SettingViewModel = SettingViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
                .pillMeNavigationBar(
                    title: viewModel.title,
                    backButtonAction: {
                        guard isEditMode && viewModel.isEdited else {
                            presentationMode.wrappedValue.dismiss()
                            return
                        }
                        showingAlert = true
                    }, rightView: isEditMode ?
                    AnyView(Button(action: {
                        viewModel.save()
                        withAnimation {
                            isEditMode = false
                        }
                    }, label: {
                        Text("완료")
                            .foregroundColor(.white)
                    })) :
                    AnyView(Button(action: {
                        withAnimation {
                            isEditMode = true
                        }
                    }, label: {
                        Text("수정")
                            .foregroundColor(.white)
                    })))
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    
                    infoView(title: UserInfo.name.title) {
                        if isEditMode {
                            VStack {
                                TextField("이름을 입력해주세요.", text: $viewModel.name)
                            }
                        } else {
                            if viewModel.name.isEmpty {
                                Text("-").foregroundColor(.gray)
                            } else {
                                Text(viewModel.name).fontWeight(.bold)
                            }
                        }
                    }
                    
                    infoView(title: UserInfo.age.title) {
                        if isEditMode {
                            TextField("나이를 입력해주세요",
                                      value: $viewModel.age,
                                      formatter: NumberFormatter())
                                .keyboardType(.asciiCapableNumberPad)
                        } else {
                            if let age = viewModel.age, age > 0 {
                                Text("\(age)세").fontWeight(.bold)
                            } else {
                                Text("-").foregroundColor(.gray)
                            }
                        }
                    }
                    
                    infoView(title: UserInfo.wakeUpTime.title) {
                        if isEditMode {
                            DatePicker("", selection: $viewModel.wakeUpTime,
                                       in: ...viewModel.breakfastTime,
                                       displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        } else {
                            Text(viewModel.wakeUpTime.timeString).fontWeight(.bold)
                        }
                    }
                    
                    infoView(title: UserInfo.breakfastTime.title) {
                        if isEditMode {
                            DatePicker("", selection: $viewModel.breakfastTime,
                                       displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        } else {
                            Text(viewModel.breakfastTime.timeString).fontWeight(.bold)
                        }
                    }
                    
                    infoView(title: UserInfo.lunchTime.title) {
                        if isEditMode {
                            DatePicker("", selection: $viewModel.lunchTime,
                                       displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        } else {
                            Text(viewModel.lunchTime.timeString).fontWeight(.bold)
                        }
                    }
                    
                    infoView(title: UserInfo.dinnerTime.title) {
                        if isEditMode {
                            DatePicker("", selection: $viewModel.dinnerTime,
                                       displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        } else {
                            Text(viewModel.dinnerTime.timeString).fontWeight(.bold)
                        }
                    }
                    
                    infoView(title: UserInfo.sleepTime.title) {
                        if isEditMode {
                            DatePicker("", selection: $viewModel.sleepTime,
                                       displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        } else {
                            Text(viewModel.sleepTime.timeString).fontWeight(.bold)
                        }
                    }
                }.padding()
            }
        }.onAppear {
            UISegmentedControl.appearance().tintColor = .white
        }
    }
    
    private func infoView<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.mainColor)
        .cornerRadius(5)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .background(Color.backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

class SettingViewModel: ObservableObject {
    @Published var name: String = UserInfoManager.shared.name
    @Published var age: Int = UserInfoManager.shared.age ?? 0
    @Published var wakeUpTime: Date = UserInfoManager.shared.wakeUpTime.time
    @Published var breakfastTime: Date = UserInfoManager.shared.breakfastTime.time
    @Published var lunchTime: Date = UserInfoManager.shared.lunchTime.time
    @Published var dinnerTime: Date = UserInfoManager.shared.dinnerTime.time
    @Published var sleepTime: Date = UserInfoManager.shared.sleepTime.time
    
    var isEdited: Bool {
        self.name == UserInfoManager.shared.name &&
        self.age == UserInfoManager.shared.age &&
        self.wakeUpTime.timeString == UserInfoManager.shared.wakeUpTime &&
        self.breakfastTime.timeString == UserInfoManager.shared.breakfastTime &&
        self.lunchTime.timeString == UserInfoManager.shared.lunchTime &&
        self.dinnerTime.timeString == UserInfoManager.shared.dinnerTime &&
        self.sleepTime.timeString == UserInfoManager.shared.sleepTime
    }
    
    var bag = Set<AnyCancellable>()
    
    var title: String {
        "사용자 설정"
    }
    
    func save() {
        UserInfoManager.shared.save(name: name,
                                    age: age,
                                    wakeUpTime: wakeUpTime.timeString,
                                    breakfastTime: breakfastTime.timeString,
                                    lunchTime: lunchTime.timeString,
                                    dinnerTime: dinnerTime.timeString,
                                    sleepTime: sleepTime.timeString)
    }
}
