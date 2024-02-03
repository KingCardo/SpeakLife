//
//  NameScene.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/26/24.
//

import SwiftUI

struct NameScene: View {
    @EnvironmentObject var appState: AppState
    
    let size: CGSize
    let callBack: (() -> Void)
    @AppStorage("userName") private var userName = ""
    @State private var keyboardHeight: CGFloat = 0
   // @State private var isTextFieldFocused: Bool = false
    
    var body: some  View {
        nameView(size: size)
    }
    
    private func nameView(size: CGSize) -> some View  {
        ZStack {
            Image(appState.onBoardingTest ? "lakeHills" : "declarationBackground")
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
                            
                            TextField("Enter your name", text: $userName)
                                .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                                .padding()  // Adds padding inside the TextField
                                .frame(width: size.width * 0.87, height: 50)  // Sets the frame for the TextField
                                .background(
                                    RoundedRectangle(cornerRadius: 8)  // Applies the corner radius to the background
                                        .stroke(appState.onBoardingTest ? .white : Constants.DALightBlue, lineWidth: 1)  // Adds a border to the RoundedRectangle
                                )
                                .shadow(color: appState.onBoardingTest ? .white : Constants.DAMidBlue, radius: 8, x: 0, y: 10)
                        }
                        .frame(width: size.width * 0.9)
                    }
                    Spacer()
                    
                    Button("Skip") {
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
                    .disabled(userName.isEmpty)
                    .frame(width: size.width * 0.87 ,height: 50)
                    .background(userName.isEmpty ? Constants.DAMidBlue.opacity(0.5): Constants.DAMidBlue)
                    
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
