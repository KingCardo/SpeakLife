//
//  PremiumView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/16/22.
//

import SwiftUI

struct PremiumView: View {
    
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            if !appState.isPremium {
                SubscriptionView(size: geometry.size)
            } else {
                NavigationView {
                    VStack {
                        Text("You are currently a premium member", comment: "current member text")
                            .font(.title2)
                        Button(LocalizedStringKey("Manage Subscription")) {
                            openURL(URL(string: "itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/DirectAction/manageSubscriptions")!)
                        }
                        .foregroundColor(.blue)
                        .padding()
                    }
                    .navigationTitle(LocalizedStringKey("Manage Subscription"))
                }
            }
        }
    }
}
