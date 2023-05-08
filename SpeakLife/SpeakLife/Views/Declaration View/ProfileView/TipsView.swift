//
//  TipsView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/30/23.
//

import SwiftUI

let tips = [
    "We all go through war in this life, whether it's mental, physical, emotional or spiritual! The best thing you can do when going through your circumstance is to fight back!",
    "Your spiritual muscles need exercise just like your body, don't expect a six pack after one workout.",
    "Favorite them, and create your own affirmations of how you want the circumstance to turn out, and SAY THEM OUT LOUD!",
    "Not one day here and there, but ATLEAST 3 times a day, everyday until you WIN!",
    "Give all your cares to the Lord and He will give you strength. He will never let those who are right with Him be shaken. Psalm 55:22 NLV",
    "Renewed Mindset: Regularly meditating on Bible affirmations can help reduce stress, anxiety, and negative emotions. This practice can contribute to better mental health, leading to a more balanced and contented life.",
    "Heightened Sense of Purpose: As you immerse yourself in Bible affirmations, you'll gain insight into your God-given purpose and talents. This clarity can guide you towards a more purpose-driven life, aligning your actions with your values and aspirations.",
    "Enhanced Resilience: By focusing on the promises and truths found in scripture, you'll cultivate emotional resilience and the ability to conquer life's trials. The practice of Bible affirmations can serve as a powerful reminder of God's unwavering support in times of difficulty.",
    "Deeper Spiritual Connection: As you internalize the affirmations rooted in God's Word, you'll start recognizing your true worth and potential. This newfound confidence can lead to improved relationships, career growth, and the courage to pursue your dreams.",
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
                Text("How to use Speaklife to your advantage!🛡🗡")
                    .font(.title)
                    .foregroundColor(.black)
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
