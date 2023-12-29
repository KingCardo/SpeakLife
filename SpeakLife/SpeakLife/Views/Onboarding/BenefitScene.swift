//
//  BenefitScene.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/15/23.
//

import SwiftUI

struct Tip: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let tip: String
}

let onboardingTips = [
    Tip(title: "Speaking Bible affirmations ", tip: "Every day nurtures a personal and intimate relationship with Jesus with a devotional experience.")
    
    /*Tip(title:"Rewiring Thought Patterns: ", tip: "Meditating on Jesus and right thoughts is ONLY way to replace bad thoughts."),
     Tip(title: "Cultivating Optimism: ", tip:"Regularly speaking Bible affirmations transforms your mindset, which transform your life."),
     Tip(title: "Enhanced Decision-Making: ",tip:"By reprogramming your thoughts with biblical values through daily affirmations, you step into God's grace and take action to your destiny."),
     Tip(title: "Inner Peace: ",tip: "Biblical affirmations calm the mind, replacing anxiety and fear with tranquility and Jesus's love for you."),
     Tip(title: "Speaking Bible affirmations ", tip: "every day nurtures a personal and intimate relationship with Jesus, so you can experience a profound sense of guidance, comfort and trust in your spiritual journey.")*/]

struct BenefitScene: View {
    
    
    let size: CGSize
    let tips: [Tip]
    var callBack: (() -> Void)
    
    
    var body: some View {
        
        ZStack {
            Image("declarationBackground")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            
            VStack {
                
                Image("bible")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                
                Text("Grow with Jesus")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 40, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer().frame(height: 45)
                
                ForEach(Array(tips.enumerated()), id: \.element.id) { index, tip in
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: "bolt.shield.fill")
                            .resizable()
                            .frame(width: 25, height: 30)
                            .foregroundColor(Constants.DAMidBlue)
                            .scaledToFill()
                        
                        Text(tip.tip)
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }.padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: callBack) {
                    HStack {
                        Text("Let's go!")
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
        }
    }
}
