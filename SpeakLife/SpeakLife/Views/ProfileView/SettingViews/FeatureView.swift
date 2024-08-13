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
    @EnvironmentObject var appState: AppState
    var feature: Feature

    var body: some View {
        HStack(alignment: .top) {
            Spacer()
                .frame(width: 16)
            Image(systemName: "checkmark.seal.fill")
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(feature.name)
                    .font(Font.custom("AppleSDGothicNeo-Regular-Bold", size: 16, relativeTo: .body))
               // if !appState.subscriptionTestnineteen {
                    Spacer()
                        .frame(height: 4)
                    Text(feature.subtitle)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14, relativeTo: .body))
              //  }
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
//                    Image(systemName: "checkmark.seal.fill")
//                        .padding(.trailing, 8)
              //  }
           //}
        }
    }
}

// Main subscription view
struct FeatureView: View {
    @EnvironmentObject var appState: AppState
    var freeText: String {
        appState.subscriptionTestnineteen ? "3 days free, then" : "7 days free, then"
    }
    
   // Renew your mind thru right believing
    // This could be fetched from a ViewModel in a real-world app
    let features: [Feature] = [
       // Feature(name:  appState.subscriptionTestnineteen ? "3 days free, then" : "7 days free, then", subtitle: "Cancel anytime before trial ends."/* Start declaring your blessings today!**Declare and manifest a long, prosperous, peaceful life for you and your family."*/, isAvailableInFree: false, isAvailableInPro: true),
       
        Feature(name: "Prosperity", subtitle: "Those who delight in the Lord and meditate day and night prosper in everything they do! Psalm 1:2-3", isAvailableInFree: false, isAvailableInPro: false),
        Feature(name: "Life & Health", subtitle: "Let my words penetrate deep into your heart, they bring life to those who find them, and healing to their whole body. Proverbs 4:21,22", isAvailableInFree: false, isAvailableInPro: false),
        Feature(name: "Inner Peace & Joy", subtitle: "3000+ affirmations to declare and activate a life of prosperity, peace, and health for yourself and your loved ones."/* Start declaring your blessings today!**Declare and manifest a long, prosperous, peaceful life for you and your family."*/, isAvailableInFree: false, isAvailableInPro: true),
        Feature(name: "Guidance & Wisdom", subtitle: "Daily Devotionals to receive Jesus' grace and love for you and be victorious."/*Receive Jesus's love and be victorious from guilt, anxiety, and fear."*/, isAvailableInFree: false, isAvailableInPro: true),
        
     //   Feature(name: "30+ categories to choose from", subtitle: ""/* Engage with scripture in an environment that inspires and uplifts.Only the finest"*/, isAvailableInFree: false, isAvailableInPro: true),
      //  Feature(name: "3000* library of affirmations", subtitle: "Access every category and unleash the power to manifest a life of prosperity, peace, and health for yourself and your loved ones."/* Start declaring your blessings today!**Declare and manifest a long, prosperous, peaceful life for you and your family."*/, isAvailableInFree: false, isAvailableInPro: true),
        //Feature(name: "Destiny", subtitle: "Create your own affirmations to achieve your God given destiny."/*Declare and fulfill your God given dreams & destiny"*/, isAvailableInFree: true, isAvailableInPro: true),
      //  Feature(name: "Spiritual Growth", subtitle: "If anyone says to this mountain, ‘Go, throw yourself into the sea,’ and does not doubt in their heart but believes that what they say will happen, it will be done for them. Mark 11:23", isAvailableInFree: false, isAvailableInPro: true)
  //      Feature(name: "Unlimited reminders", subtitle: "Stay spiritually connected and inspired throughout your day."/*
//*Receive scripture & God's promises thruout the day"*/, isAvailableInFree: false, isAvailableInPro: true),
//        Feature(name: "Grow in faith", subtitle: "Those who delight in the Lord and meditate day and night prosper in everything they do! Psalm 1:2-3", isAvailableInFree: false, isAvailableInPro: false),
//        Feature(name: "Life & Health", subtitle: "Let my words penetrate deep into your heart, they bring life to those who find them, and healing to their whole body. Proverbs 4:21,22", isAvailableInFree: false, isAvailableInPro: false)
      //  Feature(name: "40+ background themes", subtitle: "Stay motivated and inspired to meditate"/*Elevate your spiritual journey with an array of exclusive, beautifully designed themes that enhance your daily devotional experience. Engage with scripture in an environment that inspires and uplifts.Only the finest*/, isAvailableInFree: false, isAvailableInPro: true),
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
                Spacer().frame(height: 10)
            }
            
        }
        .padding()
    }
}
