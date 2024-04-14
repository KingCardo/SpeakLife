//
//  FeatureView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/12/24.
//

import SwiftUI

struct Feature {
    var name: String
    var isAvailableInFree: Bool
    var isAvailableInPro: Bool
}

struct FeatureRow: View {
    var feature: Feature

    var body: some View {
        HStack {
            Text(feature.name)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
            Spacer()
            HStack {
            if feature.isAvailableInFree {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "lock")
            }
            Spacer()
                    .frame(width: 24)
                if feature.isAvailableInPro {
                    Image(systemName: "checkmark")
                        .padding(.trailing, 8)
                }
            }
        }
    }
}

// Main subscription view
struct FeatureView: View {
    // This could be fetched from a ViewModel in a real-world app
    let features: [Feature] = [
        Feature(name: "Daily devotional's", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Unlock all categories", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Create your own", isAvailableInFree: true, isAvailableInPro: true),
        Feature(name: "Unlimited reminders", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Unlimited themes", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Unlock all prayers", isAvailableInFree: false, isAvailableInPro: true),
    ]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Free")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
                Spacer()
                    .frame(width: 16)
                Text("Pro")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))

            }
            .padding()
            
            ForEach(features, id: \.name) { feature in
                FeatureRow(feature: feature)
                Spacer().frame(width: 4)
            }
            
        }
        .padding()
    }
}
