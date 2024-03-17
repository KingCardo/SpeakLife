//
//  BottomSheet.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 3/16/24.
//

import SwiftUI

struct BottomSheet: View {
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
            Text("Practice speaking life and meditating for 10 minutes a day to build a habit. It will significantly improve your life!")
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


struct StreakSheet: View {
    @Binding var isShown: Bool
    
    @AppStorage("currentStreak") var currentStreak = 0
    @AppStorage("longestStreak") var longestStreak = 0
    
    let titleFont = Font.custom("AppleSDGothicNeo-Regular", size: 26, relativeTo: .title)
    let bodyFont = Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body)
    var body: some View {
        ZStack{
            Gradients().purple
            VStack {
                
                Image("thingsToSay")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                Text("Current Streak 🔥")
                    .font(titleFont)
                
                Text("\(currentStreak) days")
                    .font(bodyFont)
                   Spacer()
                    .frame(height: 8)
                
                Text("Longest Streak 🎊")
                    .font(titleFont)
                
                Text("\(longestStreak) days")
                    .font(bodyFont)
            }
        }
        .foregroundColor(.white)
       
    }
}
