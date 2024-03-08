//
//  DeclarationView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import SwiftUI
import MessageUI
import StoreKit
import UIKit
import FirebaseAnalytics
import GoogleMobileAds


struct DeclarationView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var viewModel: DeclarationViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var devotionalViewModel: DevotionalViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("review.counter") private var reviewCounter = 0
    @AppStorage("share.counter") private var shareCounter = 0
    @AppStorage("review.try") private var reviewTry = 0
    @AppStorage("shared.count") private var shared = 0
    @AppStorage("premium.count") private var premiumCount = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State private var share = false
    @State private var goPremium = false
    @State var isShowingMailView = false
    @State var showDailyDevotion = false
    @State private var isPresentingPremiumView = false
    @State private var isPresentingDiscountView = false
    
    @State private var timeRemaining: Int = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @State private var timeElapsed = 0
    
    func declarationContent(_ geometry: GeometryProxy) -> some View {
        DeclarationContentView(themeViewModel: themeViewModel, viewModel: viewModel)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onReceive(viewModel.$requestReview) { value in
                if value {
                    showReview()
                }
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                declarationContent(geometry)
                if appState.showIntentBar {
                    if !appState.showScreenshotLabel {
                        VStack() {
                            if !subscriptionStore.isPremium {
                              
                                HStack {
                                    Spacer()
                                    
                                    CapsuleImageButton(title: "crown.fill") {
                                        premiumView()
                                        Selection.shared.selectionFeedback()
                                    }.sheet(isPresented: $isPresentingPremiumView) {
                                        self.isPresentingPremiumView = false
                                        Analytics.logEvent(Event.tryPremiumAbandoned, parameters: nil)
                                    } content: {
                                        PremiumView()
                                    }
                                     .padding(.trailing)
                                    
                                }
                                
                            }
 
                                Spacer()
                                if appState.showIntentBar {
                                    IntentsBarView(viewModel: viewModel, themeViewModel: themeViewModel)
                                        .frame(height: geometry.size.height * 0.10)
                                    
                                }
                        }
                    }
                }
            }
        }
            
            .background(
                ZStack {
                    
                    if themeViewModel.showUserSelectedImage {
                        Image(uiImage: themeViewModel.selectedImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    } else {
                        Image(themeViewModel.selectedTheme.backgroundImageString)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    }
                    
                    Rectangle()
                        .fill(Color.black.opacity(themeViewModel.selectedTheme.blurEffect ? 0.5 : 0))
                        .edgesIgnoringSafeArea(.all)
                    
                }
            )
            
            
            .alert(isPresented: $viewModel.showErrorMessage) {
                Alert(
                    title: Text("Error", comment: "Error title message") + Text(viewModel.errorMessage ?? ""),
                    message: Text("Select a category", comment: "OK alert message")
                )
            }
        
            .alert(isPresented: $viewModel.helpUsGrowAlert) {
                Alert(
                    title: Text("Help us grow?"),
                    message: Text("Leave us a 5 star review 🌟"),
                    primaryButton: .default(Text("Yes")) {
                        requestReview()
                    },
                    secondaryButton: .cancel()
                )
            }
        
            
            .onAppear {
                reviewCounter += 1
                shareCounter += 1
                premiumCount += 1
                shareApp()
            }
            
            .alert("Help us spread SpeakLife?", isPresented: $share) {
                Button("Yes, I'll share with friends!") {
                    shareSpeakLife()
                }
                Button("No thanks") {
                }
            }
            .sheet(isPresented: $viewModel.showDiscountView) {
                if appState.offerDiscount {
                    DiscountSubscriptionView(size: UIScreen.main.bounds.size)
                } else {
                    GeometryReader { geometry in
                        SubscriptionView(size: geometry.size)
                                }
                }
            }
            
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: $isShowingMailView, result: self.$result, origin: .review)
            }
        
    }
    
        
        private func premiumView()  {
            self.isPresentingPremiumView = true
            Analytics.logEvent(Event.tryPremiumTapped, parameters: nil)
        }
    
    
    private func shareApp() {
#if !DEBUG
        if shareCounter > 3 && shared < 3 {
            share = true
            shareCounter = 0
        }
#endif
    }
    
    
    var discountLabel: some View {
        VStack {
            if appState.offerDiscount && !subscriptionStore.isPremium {
                Text("Special gift for you! 👉")
                    .font(.callout)
                Text("\(timeString(from: timeRemaining)) left")
                    .font(.caption)
            }
        }
        .onAppear {
            if appState.discountEndTime == nil {
                appState.discountEndTime = Date().addingTimeInterval(4 * 60 * 60)
            }
            initializeTimer()
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
    }
    
    private func initializeTimer() {
        if let endTime = appState.discountEndTime, Date() < endTime, !subscriptionStore.isPremium {
            appState.offerDiscount = true
            timeRemaining = Int(endTime.timeIntervalSinceNow)
        } else {
            appState.offerDiscount = false
        }
    }
    
    private func updateTimer() {
        guard timeRemaining != 0 else { return }
        if let endTime = appState.discountEndTime, Date() < endTime {
               timeRemaining = Int(endTime.timeIntervalSinceNow)
           } else {
               appState.offerDiscount = false
               timeRemaining = 0
               timer.upstream.connect().cancel() // Stop the timer
           }
       }
    
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    
    private func shareSpeakLife()  {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene {
                let url = URL(string: "\(APP.Product.urlID)")!
                
                let activityVC = UIActivityViewController(activityItems: ["Check out Speak Life - Bible Affirmations app that'll transform your life!", url], applicationActivities: nil)
                let window = scene.windows.first
                window?.rootViewController?.present(activityVC, animated: true)
                shared += 1
            }
        }
    }
    
    func requestReview() {
        if appState.helpUsGrowCount == 0 {
            showReview()
            appState.helpUsGrowCount += 1
        }
    }
    
    private func showReview() {
        
        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            print("Build number: \(buildNumber)")
        }
        let currentDate = Date()
        if reviewTry < 3 && appState.lastReviewRequestSetDate == nil {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive })
                    as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                   
                    reviewTry += 1
                    appState.lastReviewRequestSetDate = Date()
                    Analytics.logEvent(Event.leaveReviewShown, parameters: nil)
                    
//                    if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
//                        appState.lastRequestedRatingVersion = "\(appVersion)\(buildNumber)"
//                    }
                }
            }
        } else if let lastReviewSetDate = appState.lastReviewRequestSetDate,
                  currentDate.timeIntervalSince(lastReviewSetDate) >= 2 * 7 * 24 * 60 * 60,
                  reviewTry < 3 {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive })
                    as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    reviewTry += 1
                    appState.lastReviewRequestSetDate = Date()
                    Analytics.logEvent(Event.leaveReviewShown, parameters: nil)
                }
            }
        }
    }
    
    private func sendEmail() {
        reviewTry += 3
        if MFMailComposeViewController.canSendMail() {
            isShowingMailView = true
        }
    }
}

//struct MusicButtonView: View {
//    @State private var lastButtonTap = Date()
//    @State private var opacity = 0.0
//    
//    @EnvironmentObject var themeStore: ThemeViewModel
//    @EnvironmentObject var viewModel: DeclarationViewModel
//    
//    let resources: [String]
//    let ofType: String
//    
//    @State var isPlaying = true
//    
//    var body: some View {
//        
//        Button(action: buttonTapped) {
//                   Image(systemName: isPlaying ? "pause.circle" : "play.circle")
//                       .resizable()
//                       .frame(width: 50, height: 50)
//                       .background(themeStore.selectedTheme.mode == .dark ? Constants.backgroundColor : Constants.backgroundColorLight)
//                       .clipShape(Circle())
//                       .overlay(Circle().fill(Color.black.opacity(opacity)))
//                       .shadow(color: .gray, radius: 10, x: 0, y: 0)
//        }
//        .onAppear {
//            AudioPlayerService.shared.playSound(files: resources, type: ofType)
//            resetOverlayTimer()
//        }
//    }
    
    
//    private func buttonTapped() {
//        lastButtonTap = Date()
//        withAnimation {
//            isPlaying.toggle()
//            opacity = 0.0 // Reset opacity to full
//        }
//        resetOverlayTimer()
//        
//        if isPlaying {
//            AudioPlayerService.shared.playSound(files: resources, type: ofType)
//            
//        } else {
//            AudioPlayerService.shared.pauseMusic()
//        }
//        
//    }
    
//    private func resetOverlayTimer() {
//           DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//               if -lastButtonTap.timeIntervalSinceNow >= 3 {
//                   withAnimation {
//                       opacity = 0.3
//                   }
//               }
//           }
//       }
//}
