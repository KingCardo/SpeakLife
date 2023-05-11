//
//  TipsView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/30/23.
//

import SwiftUI

let tips = [
    "We all go through war in this life because we are in a battle. Yes, Jesus has won the war for us, but we must know how to stand our ground and fight through the trials that may come whether it's mental, physical, emotional or spiritual!",
    "Whatever trial you face, God's word will turn it in your favor! Look up 3 to 5 Bible verses that speaks to your trial. Meditate on them until they fill your heart, and speak them several times a day.",
    "Add the scriptures to your favorites so they will be readily accessible for any time of day. Even schedule to have them sent to you daily!",
    "SpeakLife categorizes the wonderful Bible promises so you have the right weapon at your finger tips.",
    "Renewed Mindset: Regularly meditating on Bible affirmations will upgrade your way of thinking and expectation!",
    "Warrior Resilience: By focusing on the promises and truths found in scripture, you'll cultivate emotional resilience and the ability to conquer life's trials. The practice of Bible affirmations can serve as a powerful reminder of God's unwavering support in times of difficulty.",
    "Deeper Spiritual Connection: As you internalize the affirmations rooted in God's Word, you'll start recognizing your true worth and potential.",
    "Empowered Decision-Making: The wisdom and guidance found in scripture-based affirmations can help you make informed, faith-aligned decisions. By integrating God's Word into your daily life, you'll be better equipped to face challenges and opportunities with confidence and grace."
    
]

struct TipsView: View {
    @EnvironmentObject var appState: AppState
    let tips: [String]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.cyan, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                Text("How to use Speaklife to manifest your victory!🛡🗡")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
                BulletList(items: tips)
                Spacer()
            }
        }
        .onAppear() {
            appState.newSettingsAdded = false
        }
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView(tips: tips)
    }
}
