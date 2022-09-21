//
//  IntroScene.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/29/22.
//

import SwiftUI

struct IntroScene: View {
    
    let size: CGSize
    let callBack: (() -> Void)
    
    var body: some  View {
        introSceneAlt(size: size)
    }
    
    private func introSceneAlt(size: CGSize) -> some View  {
        VStack {
            Spacer().frame(height: 90)
            
            Image("declarationsIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 235, height: size.height * 0.25)
            
            Spacer().frame(height: 40)
            VStack {
                Text("DECLARATIONS", comment: "Intro scene title label")
                    .font(Font.custom("Roboto-SemiBold", size: 40, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.DEABlack)
                
                Spacer().frame(height: 16)
                
                VStack {
                    Text("Read_and_repeat" , comment: "Intro scene instructions")
                        .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
                        .foregroundColor(Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .lineLimit(nil)
                    
                    Spacer().frame(height: 24)
                    
                    Text("The_power_of_declarations", comment: "Intro scene extra tip")
                        .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
                        .foregroundColor(Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .foregroundColor(Color(red: 119, green: 142, blue: 180, opacity: 1))
                        .lineLimit(nil)
                }
                .frame(width: size.width * 0.8)
            }
            Spacer()
            
            Button(action: callBack) {
                HStack {
                    Text("Begin_transformation", comment: "Intro scene start label")
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: size.width * 0.91 ,height: 50)
                }.padding()
            }
            .frame(width: size.width * 0.87 ,height: 50)
            .background(Constants.DAMidBlue)
            
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
