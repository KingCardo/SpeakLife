//
//  PrayerDetailView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 4/10/23.
//

import SwiftUI

struct PrayerDetailView<InjectedView: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    let prayer: String
    var gradient: InjectedView

    init(prayer: String, @ViewBuilder content: () -> InjectedView) {
        self.prayer = prayer
        self.gradient = content()
    }
    
    var body: some View {
        ZStack {
            gradient
            VStack {
                Text(prayer)
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
    }
}
