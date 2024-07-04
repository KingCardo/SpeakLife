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

struct AgeCollectionView: View {
    let size: CGSize
    let callBack: (() -> Void)
    
    let ageRanges = ["18 - 25", "26 - 35", "36 - 45", "46 - 55", "56 - 65", "66 and above"]
    
    // State to track the selected age range
    @State private var selectedAgeRange: String = ""
    
    
    var body: some View {
        ZStack {
            Image(onboardingBGImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                
                VStack {
                    Spacer().frame(height: size.height / 4)
                    VStack {
                        Text("Please select your age range:" , comment: "collect age range")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .lineLimit(nil)
                        
                        Spacer().frame(height: 24)
                        
                            ForEach(ageRanges, id: \.self) { ageRange in
                               
                                Button(action: {
                                    // Set the selected age range
                                    self.selectedAgeRange = ageRange
                                }) {
                                        HStack {
                                            Text(ageRange)
                                                .foregroundColor(.white)
                                                .padding()
                                            Spacer()
                                        }
                                        .background(self.selectedAgeRange == ageRange ? Constants.DAMidBlue.opacity(0.8) : Constants.DAMidBlue.opacity(0.3))
                                       // .background(self.selectedAgeRange == ageRange ? Color.blue : Color.white.opacity(0.3))
                                        .cornerRadius(10)
                                    }
                                .padding(.horizontal)
                            }
                            .frame(width: size.width * 0.9)
                        
                    }
                }
                
                Spacer()
                
                Button("Skip") {
                    callBack()
                }
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .caption))
                .fontWeight(.medium)
                .frame(width: size.width * 0.30 ,height: 25)
                Button("Continue") {
                    if selectedAgeRange.count > 2 {
                        Analytics.logEvent(selectedAgeRange, parameters: nil)
                    }
                    //Analytics.logEvent("UserAge", parameters: ["age":selectedAgeRange])
                    callBack()
                }
                .disabled(selectedAgeRange.isEmpty)
                .frame(width: size.width * 0.87 ,height: 50)
                .background(selectedAgeRange.isEmpty ? Constants.DAMidBlue.opacity(0.5): Constants.DAMidBlue)
                
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


struct GenderCollectionView: View {
    let size: CGSize
    let callBack: (() -> Void)
    
    let genders = ["Male", "Female"]
    
    // State to track the selected gender
    @State private var selectedGender: String = ""
    
    
    var body: some View {
        ZStack {
            Image(onboardingBGImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                
                VStack {
                    Spacer().frame(height: size.height / 4)
                    
                    VStack {
                        Text("Please select your gender:" , comment: "collect gender")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .lineLimit(nil)
                        
                        Spacer().frame(height: 24)
                        
                        ForEach(genders, id: \.self) { gender in
                            Button(action: {
                                self.selectedGender = gender
                            }) {
                                HStack {
                                    Text(gender)
                                        .foregroundColor(.white)
                                        .padding()
                                    Spacer()
                                }
                                .background(self.selectedGender == gender ? Color.blue : Color.clear)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .frame(width: size.width * 0.9)
                    }
                }
                
                
                Spacer()
                Button("Skip") {
                    callBack()
                }
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .caption))
                .fontWeight(.medium)
                .frame(width: size.width * 0.30 ,height: 25)
                
                Button("Continue") {
                    if selectedGender.count > 2 {
                        Analytics.logEvent(selectedGender, parameters: nil)
                    }//"UserGender", parameters: ["gender":])
                    callBack()
                }
                .disabled(selectedGender.isEmpty)
                .frame(width: size.width * 0.87 ,height: 50)
                .background(selectedGender.isEmpty ? Constants.DAMidBlue.opacity(0.5): Constants.DAMidBlue)
                // .background(Constants.DAMidBlue)
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
