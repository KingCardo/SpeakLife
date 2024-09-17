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
    var imageName: String = "checkmark.seal.fill"
}

struct FeatureRow: View {
    @EnvironmentObject var appState: AppState
    var feature: Feature

    var body: some View {
        HStack(alignment: .top) {
            Spacer()
                .frame(width: 16)
            Image(systemName: feature.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(feature.name)
                    .font(Font.custom("AppleSDGothicNeo-Regular-Bold", size: 16, relativeTo: .body))
                    Spacer()
                        .frame(height: 4)
                    Text(feature.subtitle)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14, relativeTo: .body))
            }
            Spacer()

        }
    }
}

// Main subscription view
struct FeatureView: View {

    @AppStorageCodable(key: "valueProps", defaultValue: [])
    var userValueProps: [Feature]
    var valueProps: [Feature] = []
    
    init(_ userValueProps: [Feature]) {
        if self.userValueProps.count > 2 {
            let count = self.userValueProps.count
            let maximum = min(count, 4)
            let firstNElements = Array(self.userValueProps.prefix(maximum))
            valueProps = firstNElements
            valueProps.append(Feature(name: "Spiritual Growth", subtitle: "365+ Daily Devotionals to grow with Jesus", imageName: "book.fill"))
        } else if userValueProps.count > 2 {
            self.userValueProps = userValueProps
            let count = userValueProps.count
            let maximum = min(count, 4)
            let firstNElements = Array(userValueProps.prefix(maximum))
            valueProps = firstNElements
            valueProps.append(Feature(name: "Spiritual Growth", subtitle: "365+ Daily Devotionals to grow with Jesus", imageName: "book.fill"))
        } else {
            valueProps = features
        }
    }
    
    let features: [Feature] = [

        Feature(name: "Prosperity", subtitle: "Those who delight in the Lord and meditate day and night prosper in everything they do! Psalm 1:2-3", imageName: "infinity"),
        Feature(name: "Inner Peace & Joy", subtitle: "Unlimited affirmations, Guided Prayers, and more to declare and activate a life of prosperity, peace, and health for yourself and your loved ones."/* Start declaring your blessings today!**Declare and manifest a long, prosperous, peaceful life for you and your family."*/, imageName: "sparkles"),
        Feature(name: "Guidance & Wisdom", subtitle: "365+ Daily Devotionals to grow with Jesus"/*Receive Jesus's love and be victorious from guilt, anxiety, and fear."*/, imageName: "book.fill"),
     
    ]

    var body: some View {
        VStack {
            ForEach(valueProps, id: \.name) { feature in
                FeatureRow(feature: feature)
                Spacer().frame(height: 10)
            }
            
        }
        .padding()
    }
}
