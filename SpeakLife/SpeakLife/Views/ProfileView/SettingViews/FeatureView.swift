//
//  FeatureView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/12/24.
//

import SwiftUI

struct Feature {
    var name: String
    var subtitle: String
    var isAvailableInFree: Bool
    var isAvailableInPro: Bool
}

struct FeatureRow: View {
    var feature: Feature

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(feature.name)
                    .font(Font.custom("AppleSDGothicNeo-Regular-Bold", size: 18, relativeTo: .body))
                Spacer()
                        .frame(height: 2)
                Text(feature.subtitle)
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 14, relativeTo: .body))
            }
            Spacer()
          //  HStack {
           // if feature.isAvailableInFree {
           //     Image(systemName: "checkmark.seal.fill")
//            } else {
//                Image(systemName: "lock")
//            }
         //   Spacer()
            //        .frame(width: 24)
            //    if feature.isAvailableInPro {
                    Image(systemName: "checkmark.seal.fill")
                        .padding(.trailing, 8)
              //  }
           //}
        }
    }
}

// Main subscription view
struct FeatureView: View {
    
   // Renew your mind thru right believing
    // This could be fetched from a ViewModel in a real-world app
    let features: [Feature] = [
        Feature(name: "Daily devotional's", subtitle: "Receive Jesus's love and be victorious from guilt, anxiety, and fear.", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Unlock all categories", subtitle: "Declare and manifest a long, prosperous, peaceful life for you and your family.", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Create your own", subtitle: "Declare and fulfill your God given dreams & destiny", isAvailableInFree: true, isAvailableInPro: true),
        Feature(name: "Unlimited reminders", subtitle: "Receive scripture & God's promises thruout the day", isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Unlimited themes", subtitle: "Only the finest", isAvailableInFree: false, isAvailableInPro: true),
       // Feature(name: "Unlock all prayers",  subtitle: "Quiet the lies", isAvailableInFree: false, isAvailableInPro: true),
    ]

    var body: some View {
        VStack {
//            HStack {
//                Spacer()
//                Text("Free")
//                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
//                Spacer()
//                    .frame(width: 16)
//                Text("Pro")
//                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
//
//            }
//            .padding()
            
            ForEach(features, id: \.name) { feature in
                FeatureRow(feature: feature)
                Spacer().frame(width: 4)
            }
            
        }
        .padding()
    }
}
