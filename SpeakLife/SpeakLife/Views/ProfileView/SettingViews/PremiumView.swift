//
//  PremiumView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/16/22.
//

import SwiftUI

struct PremiumView: View {
    
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var presentDevotionalSubscriptionView = false
    @State private var countdown: TimeInterval = 0
        
    
    var body: some View {
        GeometryReader { geometry in
            if !subscriptionStore.isPremium {
                if appState.offerDiscount {
                OfferPageView(countdown: $countdown) { }
                } else {
                    SubscriptionView(size: geometry.size)
                }
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
        .onAppear {
            if appState.discountEndTime == nil {
                appState.discountEndTime = Date().addingTimeInterval(1 * 60 * 15)
            }
            initializeTimer()
        }
        .onReceive(timer) { timer in
            updateTimer()
        }
    }
    
    private func updateTimer() {
        guard appState.timeRemainingForDiscount != 0 else { return }
        if let endTime = appState.discountEndTime, Date() < endTime {
            appState.timeRemainingForDiscount = Int(endTime.timeIntervalSinceNow)
            countdown = endTime.timeIntervalSinceNow
           } else {
               appState.offerDiscount = false
               appState.timeRemainingForDiscount = 0
               countdown = 0
               timer.upstream.connect().cancel()
               // Stop the timer
           }
       }
    
    private func initializeTimer() {
        if let endTime = appState.discountEndTime, Date() < endTime, !subscriptionStore.isPremium {
            appState.offerDiscount = true
            appState.timeRemainingForDiscount = Int(endTime.timeIntervalSinceNow)
            countdown = endTime.timeIntervalSinceNow
        } else {
            appState.offerDiscount = false
        }
    }
}
