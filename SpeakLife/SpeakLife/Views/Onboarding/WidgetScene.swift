//
//  WidgetScene.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 6/18/22.
//

import SwiftUI

struct WidgetScene: View {
    let size: CGSize
    let callBack: (() -> Void)
    
    var body: some View {
        widgetScene(size: size)
    }
    
    private func widgetScene(size: CGSize)  -> some View {
        
        VStack {
            Spacer().frame(height: 90)
            
            Image("widget")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 235, height: size.height * 0.25)
            
            Spacer().frame(height: 40)
            VStack {
                Text("Add a widget to your home screen", comment: "Widget scene add widget text")
                    .font(Font.custom("Roboto-SemiBold", size: 22, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.DEABlack)
                
                Spacer().frame(height: 16)
                
                VStack {
                    Text("From the Home Screen, press down on an empty area until the apps wiggle.", comment: "widget scene add instructions")
                        .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
                        .foregroundColor(Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .lineLimit(nil)
                    
                    Spacer().frame(height: 24)
                    
                    Text("Then tap the + button in upper corner to add a widget.", comment: "widget scene additional instructions")
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
                    Text("Got it!", comment: "Widget scene confirmation")
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
