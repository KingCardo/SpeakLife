//
//  WarriorView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 12/24/23.
//

import SwiftUI

import FirebaseAnalytics

struct WarriorView: View {
    @Environment(\.presentationMode) var presentationMode
    let psalm91NLT = """
    Psalm 91 (NLT)

    1 Those who live in the shelter of the Most High
        will find rest in the shadow of the Almighty.
    2 This I declare about the Lord:
        He alone is my refuge, my place of safety;
        he is my God, and I trust him.
    3 For he will rescue you from every trap
        and protect you from deadly disease.
    4 He will cover you with his feathers.
        He will shelter you with his wings.
        His faithful promises are your armor and protection.
    5 Do not be afraid of the terrors of the night,
        nor the arrow that flies in the day.
    6 Do not dread the disease that stalks in darkness,
        nor the disaster that strikes at midday.
    7 Though a thousand fall at your side,
        though ten thousand are dying around you,
        these evils will not touch you.
    8 Just open your eyes,
        and see how the wicked are punished.

    9 If you make the Lord your refuge,
        if you make the Most High your shelter,
    10 no evil will conquer you;
        no plague will come near your home.
    11 For he will order his angels
        to protect you wherever you go.
    12 They will hold you up with their hands
        so you won't even hurt your foot on a stone.
    13 You will trample upon lions and cobras;
        you will crush fierce lions and serpents under your feet!

    14 The Lord says, "I will rescue those who love me.
        I will protect those who trust in my name.
    15 When they call on me, I will answer;
        I will be with them in trouble.
        I will rescue and honor them.
    16 I will reward them with a long life
        and give them my salvation."

    """

    
    var body: some View {
        ZStack {
            Gradients().cyanGold
            ScrollView {
                PrayerDetailView(prayer: psalm91NLT) {
                    Gradients().cyanGold
                    
                }
            }
      }
        
        .onAppear {
            
            Analytics.logEvent(Event.ninetyOnePsalmTapped, parameters: nil)
        }
        
    }
}
