//
//  BottomSheet.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 3/16/24.
//

import SwiftUI

struct StreakInfoBottomSheet: View {
    @Binding var isShown: Bool
    
    var body: some View {
        VStack {
            Image("declarationsIllustration")
                .resizable()
                .frame(width: 90, height: 90)
            
            Text("Speak Life Daily")
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 26, relativeTo: .title))
                .padding()
                .foregroundColor(.black)
            Text("Practice speaking life, meditating, using your imagination for 5-10 minutes a day to build a habit. Preferably free of distractions. It will significantly improve your life!")
                .lineLimit(nil)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
                .padding([.leading,.trailing])
                .foregroundColor(.black)
            
            Button(action: {
                self.isShown = false
            }) {
                Text("Got it!")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Constants.DAMidBlue)
                    .cornerRadius(10)
                    .padding()
            }
        }
       
    }
}
