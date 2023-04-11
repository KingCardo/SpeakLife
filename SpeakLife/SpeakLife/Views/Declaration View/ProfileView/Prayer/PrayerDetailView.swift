//
//  PrayerDetailView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import SwiftUI

struct PrayerDetailView: View {
    let prayer: String

    var body: some View {
        VStack {
            Text(prayer)
                .font(.largeTitle)
                .padding()
            
            Spacer()
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerDetailView(prayer: "Apple")
    }
}
