//
//  BottomSheet.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 3/16/24.
//

import SwiftUI

struct StreakInfoBottomSheet: View {
    @EnvironmentObject var streakViewModel: StreakViewModel
    @Binding var isShown: Bool
    let titleFont = Font.custom("AppleSDGothicNeo-Regular", size: 26, relativeTo: .title)
    let bodyFont = Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body)
    
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
            Spacer()
                .frame(height: 12)
            VStack {
                Text("Current streak 🔥")
                    .font(bodyFont)
                
                HStack {
                    Text(streakViewModel.titleText)
                        .font(bodyFont)
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
            }
            
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
