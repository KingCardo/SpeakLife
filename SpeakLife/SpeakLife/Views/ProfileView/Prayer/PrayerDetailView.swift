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
        ZStack {
            Gradients().cyan
            VStack {
                Text(prayer)
                    .font(.body)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerDetailView(prayer: "Apple")
    }
}
