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
            Text("Practice affirming, imagining, and meditating on a certain scripture, saying it 7x a day activating the Word! Then you will reap what you sow 🌱")
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
