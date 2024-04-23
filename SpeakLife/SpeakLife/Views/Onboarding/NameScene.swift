//
//  NameScene.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/26/24.
//

import SwiftUI
import Firebase

struct NameScene: View {
    @EnvironmentObject var appState: AppState
    
    let size: CGSize
    let callBack: (() -> Void)
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedAge = 25
    private let ageRange = 12...100
   // @State private var isTextFieldFocused: Bool = false
   
    
    var body: some  View {
        nameView(size: size)
    }
    
    private func nameView(size: CGSize) -> some View  {
        ZStack {
            Image(appState.onBoardingTest ? onboardingBGImage : "declarationBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                
                VStack {
                    
                    if !appState.onBoardingTest {
                        Spacer().frame(height: 90)
                    } else {
                        Spacer()
                    }
                    
                    VStack {
                        
                        VStack {
                            Text("What do your friends call you?" , comment: "collect user name")
                                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                                .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .lineLimit(nil)
                            
                            Spacer().frame(height: 24)
                            
                            TextField("Enter your name", text: $appState.userName)
                                .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                              //  .textFieldStyle(CustomTextFieldStyle())
                                .padding()  // Adds padding inside the TextField
                                .frame(width: size.width * 0.87, height: 50)  // Sets the frame for the TextField
                                .background(
                                    RoundedRectangle(cornerRadius: 8)  // Applies the corner radius to the background
                                        .stroke(appState.onBoardingTest ? .white : Constants.DALightBlue, lineWidth: 1)  // Adds a border to the RoundedRectangle
                                )
                                .shadow(color: appState.onBoardingTest ? .white : Constants.DAMidBlue, radius: 8, x: 0, y: 10)
                            
                            Spacer().frame(height: 40)
                            
//                            NavigationView {
//                                Form {
//                                    Section(header: Text("Please select your age").foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)) {
//                                        List(ageRange, id: \.self) { age in
//                                            HStack {
//                                                Text("\(age)")
//                                                    .onTapGesture {
//                                                        self.selectedAge = age
//                                                        // self.showConfirmation = true  // Optional: trigger confirmation/alert here if needed
//                                                    }
//                                                Spacer()
//                                                if age == selectedAge {
//                                                    Image(systemName: "checkmark")
//                                                        .foregroundColor(.blue)
//                                                }
//                                            }
//                                            .contentShape(Rectangle())  // Makes the whole row tappable
//                                            .foregroundColor(appState.onBoardingTest ? .black : Constants.DALightBlue)
//                                        }
//                                    }.frame(height: size.width * 0.5)
//                            
//                                }
//                            }
                            
//                            Section(header: Text("Please select your age")) {
//                                               Picker("Age", selection: $selectedAge) {
//                                                   ForEach(ageRange, id: \.self) {
//                                                       Text("\($0)").tag($0)
//                                                   }
//                                               }
//                                               .pickerStyle(InlinePickerStyle())
//                                               .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)// You can choose other styles like Inline, Menu, etc.
//                                           }.foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                            
                        }
                        .frame(width: size.width * 0.9)
                    }
                    Spacer()
                    
                    Button("Skip") {
                      //  Analytics.logEvent("UserAge", parameters: ["age":selectedAge])
                        callBack()
                    }
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .caption))
                    .fontWeight(.medium)
                    .frame(width: size.width * 0.30 ,height: 25)
                    
                    Button(action: callBack) {
                        HStack {
                            Text("Continue", comment: "Intro scene start label")
                                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                                .fontWeight(.medium)
                                .frame(width: size.width * 0.91 ,height: 50)
                        }.padding()
                    }
                    .disabled(appState.userName.isEmpty)
                    .frame(width: size.width * 0.87 ,height: 50)
                    .background(appState.userName.isEmpty ? Constants.DAMidBlue.opacity(0.5): Constants.DAMidBlue)
                    
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
                    
                    Spacer()
                        .frame(width: 5, height: size.height * 0.07)
                }
            }

        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .foregroundColor(Color.white) // Change the text color
    }
}
