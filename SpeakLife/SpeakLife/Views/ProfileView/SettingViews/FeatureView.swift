//
//  FeatureView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/12/24.
//

import SwiftUI
import StoreKit

struct Feature: Codable, Identifiable {
    var id = UUID()
    var name: String
    var subtitle: String
    var imageName: String = "checkmark"
    
    init(id: UUID = UUID(), name: String, subtitle: String, imageName: String) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.imageName = imageName
    }
    
    init(subtitle: String) {
        self.id = UUID()
        self.name = ""
        self.subtitle = subtitle
    }

}



struct FeatureRow: View {
    @EnvironmentObject var appState: AppState
    var feature: Feature

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
                .frame(width: 4)
            Image(systemName: feature.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 10, height: 10)
                .padding(.trailing, 8)
                .foregroundColor(Constants.traditionalGold)
            VStack(alignment: .leading) {
                
                Text(feature.subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                
            }
            Spacer()

        }
    }
}

// Main subscription view
struct FeatureView: View {

    var valueProps: [Feature] {
        return allFeatures
    }
    
    
    let allPremiumFeatures = [
        Feature(subtitle: "Everything from Pro"),
        Feature(subtitle: "Audio declarations to claim victory"),
        Feature(subtitle: "Bible Bedtime Stories for peaceful rest"),
        ]
    
    let allFeatures = [

        Feature(subtitle: "Speak God’s Word over your life daily"),
        Feature(subtitle: "Renew your mind with truth-filled devotionals"),
        Feature(subtitle: "Hear faith-building declarations spoken over you"),
        Feature(subtitle: "Meditate offline — no distractions, no ads"),
        
        ]
    
    let features: [Feature] = [

        Feature(name: "Prosperity", subtitle: "Those who delight in the Lord and meditate day and night prosper in everything they do! Psalm 1:2-3", imageName: "infinity"),
        Feature(name: "Inner Peace & Joy", subtitle: "Unlimited affirmations, Guided Prayers, and more to declare and activate a life of prosperity, peace, and health for yourself and your loved ones."/* Start declaring your blessings today!**Declare and fulfill a long, prosperous, peaceful life for you and your family."*/, imageName: "sparkles"),
        Feature(name: "Guidance & Wisdom", subtitle: "365+ Daily Devotionals to grow with Jesus"/*Receive Jesus's love and be victorious from guilt, anxiety, and fear."*/, imageName: "book.fill"),
     
    ]

    var body: some View {
        VStack {
            ForEach(valueProps) { feature in
                FeatureRow(feature: feature)
                Spacer().frame(height: 15)
                
            }
        }
            .padding()
        }
}
