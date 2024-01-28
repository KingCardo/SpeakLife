//
//  NameScene.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 1/26/24.
//

import SwiftUI

struct NameScene: View {
    
    let size: CGSize
    let callBack: (() -> Void)
    @AppStorage("userName") private var userName = ""
    
    
    var body: some  View {
        nameView(size: size)
    }
    
    private func nameView(size: CGSize) -> some View  {
        VStack {
            Spacer().frame(height: 90)
            
            VStack {
                
                VStack {
                    Text("What do your friends call you?" , comment: "collect user name")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                        .foregroundColor(Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .lineLimit(nil)
                    
                    Spacer().frame(height: 24)
                    
                    TextField("Enter your name", text: $userName)
                        .padding()  // Adds padding inside the TextField
                        .frame(width: size.width * 0.87, height: 50)  // Sets the frame for the TextField
                        .background(
                            RoundedRectangle(cornerRadius: 8)  // Applies the corner radius to the background
                                .stroke(Constants.DALightBlue, lineWidth: 1)  // Adds a border to the RoundedRectangle
                        )
                        .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
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
        .frame(width: size.width, height: size.height)
        .background(
            Image("declarationBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
    }
}
