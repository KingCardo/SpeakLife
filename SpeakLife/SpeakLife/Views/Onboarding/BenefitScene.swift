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

let onboardingTips = [Tip(title:"Rewiring Thought Patterns: ", tip: "Meditating on Jesus and right thoughts is ONLY way to replace bad thoughts."),
                      Tip(title: "Cultivating Optimism: ", tip:"Regularly speaking Bible affirmations transforms your mindset, which transform your life."),
                      Tip(title: "Enhanced Decision-Making: ",tip:"By reprogramming your thoughts with biblical values through daily affirmations, you step into God's grace and take action to your destiny."),
                      Tip(title: "Inner Peace: ",tip: "Biblical affirmations calm the mind, replacing anxiety and fear with tranquility and Jesus's love for you."),
                      Tip(title: "Speaking Bible affirmations ", tip: "every day nurtures a personal and intimate relationship with Jesus, so you can experience a profound sense of guidance, comfort and trust in your spiritual journey.")]

struct BenefitScene: View {
    
    
    let size: CGSize
    let tips: [Tip]
    var callBack: (() -> Void)
    @State private var isVisible = [Bool](repeating: false, count: 5)
    @State private var isButtonDisabled = true

    
    var body: some View {
        
        ZStack {
            Gradients().cyan
            VStack {
                
                Spacer().frame(height: 90)
                
                Text("SpeakLife Benefits")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 40, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer().frame(height: 45)
                
                ForEach(Array(tips.enumerated()), id: \.element.id) { index, tip in
                        HStack {
                            Image(systemName: "bolt.shield.fill")
                                .resizable()
                                .frame(width: 25, height: 30)
                                .foregroundColor(.white)
                                .scaledToFill()
    
                                Text(tip.title)
                                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 22, relativeTo: .body))
                                    .foregroundColor(.white)
                                    
                                + Text(tip.tip)
                                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                            Spacer()
                        }.padding(.horizontal)
                        .opacity(isVisible[index] ? 1 : 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(index) * 2.0) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    isVisible[index] = true
                                    if isVisible[4] {
                                        isButtonDisabled = false
                                    }
                                }
                            }
                        }
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
                .disabled(isButtonDisabled)
                .frame(width: size.width * 0.87 ,height: 50)
                .background(isButtonDisabled ? Constants.DAMidBlue.opacity(0.3) : Constants.DAMidBlue)
                
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
                
                Spacer()
                    .frame(width: 5, height: size.height * 0.07)
                
            }
        }
    }
}
