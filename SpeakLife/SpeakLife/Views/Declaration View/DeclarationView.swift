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
    
    
    @State private var timeElapsed = 0
       
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func declarationContent(_ geometry: GeometryProxy) -> some View {
        DeclarationContentView(themeViewModel: themeViewModel, viewModel: viewModel)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onReceive(viewModel.$requestReview) { request in
                if request {
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
                                //                                GoogleAdBannerView()
                                //                                    .frame(width: geometry.size.width * 0.9, height: 50)
                                //                            }
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
                    title: Text("Error", comment: "Error title message") +  Text(viewModel.errorMessage ?? ""),
                    message: Text("Select a category", comment: "OK alert message")
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
                if appState.discountOfferedTries > 1 {
                    DiscountSubscriptionView(size: UIScreen.main.bounds.size, currentSelection: .speakLife1YR19, percentOffText: "50% Off Yearly")
                } else {
                    SubscriptionView(size: UIScreen.main.bounds.size)
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
        if shareCounter > 5 && shared < 3 {
            share = true
            shareCounter = 0
        }
#endif
    }
    
    private func shareSpeakLife()  {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene {
                let url = URL(string: "\(APP.Product.urlID)")!
                
                let activityVC = UIActivityViewController(activityItems: ["Check out Speak Life - Bible Verses app that'll transform your life!", url], applicationActivities: nil)
                let window = scene.windows.first
                window?.rootViewController?.present(activityVC, animated: true)
                shared += 1
            }
        }
    }
    
    private func showReview() {
        if reviewCounter > 1 && reviewTry <= 3 {
            
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive })
                    as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    reviewTry += 1
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
