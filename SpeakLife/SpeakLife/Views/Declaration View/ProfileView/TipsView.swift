//
//  TipsView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/30/23.
//

import SwiftUI

let tips = [
    "We all go through war in this life, whether it's mental, physical, emotional or spiritual! The best thing you can do when going through your circumstance is to fight back!",
    "Whatever situation your going through, find a collection of 3-5 scriptures that you can meditate on day and night!",
    "Favorite them, and create your own affirmations of how you want the circumstance to turn out, and SAY THEM OUT LOUD!",
    "Not one day here and there, but ATLEAST 3 times a day, everyday until you WIN!",
    "Your spiritual muscles need exercise just like your body, don't expect a six pack after one workout.",
    "Give all your cares to the Lord and He will give you strength. He will never let those who are right with Him be shaken. Psalm 55:22 NLV",
    "God is always developing the fruit of the spirit in us! Love, joy, peace, patience, kindness, goodness, gentleness, faithfulness, and self-control.",
    "Once you understand where your being developed you can start to see the situation from God's point of view and choose to respond how he would want you to!"
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
