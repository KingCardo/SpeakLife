//
//  PrayerDetailView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import SwiftUI

struct PrayerDetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let prayer: String

    var body: some View {
        VStack {
            Text(prayer)
                .font(.title)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .foregroundColor(colorScheme  == .dark ? .white : Constants.DAMidBlue)
               
            Spacer()
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerDetailView(prayer: "Apple")
    }
}
