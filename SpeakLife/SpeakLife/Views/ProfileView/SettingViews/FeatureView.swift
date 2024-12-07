//
//  FeatureView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/12/24.
//

import SwiftUI

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
                .frame(width: 16)
            Image(systemName: feature.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                
                Text(feature.subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
            }
            Spacer()

        }
    }
}

// Main subscription view
struct FeatureView: View {

   // @AppStorageCodable(key: "valueProps", defaultValue: [])
   // var userValueProps: [Feature]
    var valueProps: [Feature] = []
    
    init(defaultProps: [Feature]) {
        valueProps = defaultProps
    }
    
//    init(_ userValueProps: [Feature]) {
//        if self.userValueProps.count > 1 {
//            let count = self.userValueProps.count
//            let maximum = min(count, 4)
//            let firstNElements = Array(self.userValueProps.prefix(maximum))
//            valueProps = firstNElements
//            valueProps.append(Feature(name: "Spiritual Growth", subtitle: "365+ Daily Devotionals to grow with Jesus", imageName: "book.fill"))
//        } else if userValueProps.count > 1 {
//            self.userValueProps = userValueProps
//            let count = userValueProps.count
//            let maximum = min(count, 4)
//            let firstNElements = Array(userValueProps.prefix(maximum))
//            valueProps = firstNElements
//            valueProps.append(Feature(name: "Spiritual Growth", subtitle: "365+ Daily Devotionals to grow with Jesus", imageName: "book.fill"))
//        } else {
//            valueProps = features
//        }
//    }
    
    let allFeatures = [
       // Feature(subtitle: "Unlock everything"),
//        Feature(subtitle: ""),
//        Feature(subtitle: "Start your day spiritually equipped with affirmations rooted in God’s Word—your shield against negativity."),
//        Feature(subtitle: "Speak peace into your life with daily affirmations that calm your mind and align your heart with God’s promises."),
//        Feature(subtitle: "Strengthen your faith daily with affirmations that remind you of God’s unchanging love and power."),
//        Feature(subtitle: "Unlock your potential by declaring the truth of God’s Word over your dreams, goals, and future."),
        Feature(subtitle: "10,000+ library of God's promises and affirmations"),
        Feature(subtitle: "Audio declarations and prayers"),
        Feature(subtitle: "Bible Bedtime Stories"),
        Feature(subtitle: "New devotional everyday"),
        Feature(subtitle: "Unlimited scripture reminders"),
        Feature(subtitle: "30+ customizable themes")
        ]
    
    let features: [Feature] = [

        Feature(name: "Prosperity", subtitle: "Those who delight in the Lord and meditate day and night prosper in everything they do! Psalm 1:2-3", imageName: "infinity"),
        Feature(name: "Inner Peace & Joy", subtitle: "Unlimited affirmations, Guided Prayers, and more to declare and activate a life of prosperity, peace, and health for yourself and your loved ones."/* Start declaring your blessings today!**Declare and fulfill a long, prosperous, peaceful life for you and your family."*/, imageName: "sparkles"),
        Feature(name: "Guidance & Wisdom", subtitle: "365+ Daily Devotionals to grow with Jesus"/*Receive Jesus's love and be victorious from guilt, anxiety, and fear."*/, imageName: "book.fill"),
     
    ]

    var body: some View {
        VStack {
            ForEach(allFeatures) { feature in
                FeatureRow(feature: feature)
                Spacer().frame(height: 15)
            }
            
        }
        .padding()
    }
}
