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
//import GoogleMobileAds
import Combine

enum SelectedView {
    case first, second, third
}


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
    @State private var isPresentingBottomSheet = false
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var showMenu = false
    @State private var selectedView: SelectedView?
   /// @State private var timeRemaining: Int = 0
    
    @State var isPresenting: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
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
      //  NavigationView {
        GeometryReader { geometry in
           
            ZStack {
                declarationContent(geometry)
                if appState.showIntentBar {
                     
                    if !appState.showScreenshotLabel {
                       
                        VStack() {
                           
                            HStack {

                                Spacer()
                                if !timerViewModel.checkIfCompletedToday() {
                                    CountdownTimerView(viewModel: timerViewModel) {
                                        presentTimerBottomSheet()
                                    }
                                    .sheet(isPresented: $isPresentingBottomSheet) {
                                        StreakInfoBottomSheet(isShown: $isPresentingBottomSheet)
                                            
                                            .presentationDetents([.fraction(0.55)])
                                          //  .background(Gradients().cyanWhite.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/))
                                            .preferredColorScheme(.light)
                                    }
                                } else {
                                    GoldBadgeView()
                                }
                                if !subscriptionStore.isPremium {
                                    Spacer()
                                        .frame(width: 8)
                                    
                                    CapsuleImageButton(title: "crown.fill") {
                                        premiumView()
                                        Selection.shared.selectionFeedback()
                                    }.foregroundStyle(Constants.gold)
                                        .sheet(isPresented: $isPresentingPremiumView) {
                                            self.isPresentingPremiumView = false
                                            Analytics.logEvent(Event.tryPremiumAbandoned, parameters: nil)
                                            timerViewModel.loadRemainingTime()
                                        } content: {
                                            PremiumView()
                                        }
                                    
                                    
                                }
                                
                            } .padding(.trailing)
                            
                            Spacer()
                           if appState.showIntentBar {
                                 IntentsBarView(viewModel: viewModel, themeViewModel: themeViewModel)
                               .frame(height: geometry.size.height * 0.10)

                        }
                    }
                    }
                }
           // .navigationBarHidden(true)
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
                        .fill(Color.black.opacity(themeViewModel.selectedTheme.blurEffect ? 0.38 : 0))
                        .edgesIgnoringSafeArea(.all)
//                    
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
                timerViewModel.loadRemainingTime()
//                if !subscriptionStore.isPremium {
//                    viewModel.showDiscountView.toggle()
//                }
            }
            
            .alert("Know anyone that can benefit from SpeakLife?", isPresented: $share) {
                Button("Yes, I'll share with friends!") {
                    shareSpeakLife()
                }
                Button("No thanks") {
                }
            }
            .sheet(isPresented: $viewModel.showDiscountView) {
                    GeometryReader { geometry in
                        SubscriptionView(size: geometry.size)
                }
            }
            .onDisappear {
                timerViewModel.saveRemainingTime()
            }
            
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: $isShowingMailView, result: self.$result, origin: .review)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                timerViewModel.saveRemainingTime()
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                timerViewModel.loadRemainingTime()
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                timerViewModel.saveRemainingTime()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                timerViewModel.saveRemainingTime()
            }
        
    }
    
    private func presentTimerBottomSheet()  {
        self.isPresentingBottomSheet = true
    }
    
    
    private func premiumView()  {
        timerViewModel.saveRemainingTime()
        self.isPresentingPremiumView = true
        Analytics.logEvent(Event.tryPremiumTapped, parameters: nil)
    }
    
    
    private func shareApp() {
        let currentDate = Date()
        if shareCounter > 3 && shared < 2 && currentDate.timeIntervalSince(appState.lastSharedAttemptDate) >= 12 * 60 * 60 {
            share = true
            appState.lastSharedAttemptDate = currentDate
        }
    }
    
    
    
    private func shareSpeakLife()  {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene {
                let url = URL(string: "\(APP.Product.urlID)")!
                
                let activityVC = UIActivityViewController(activityItems: ["Check out Speak Life - Bible Meditation app that'll transform your life!", url], applicationActivities: nil)
                let window = scene.windows.first
                window?.rootViewController?.present(activityVC, animated: true)
                shared += 1
            }
        }
    }
    
    func requestReview() {
        showReview()
    }
    
    private func showReview() {
     
        let currentDate = Date()
        if reviewTry <= 3 && appState.lastReviewRequestSetDate == nil {
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
        } else if reviewTry <= 2, let lastReviewSetDate = appState.lastReviewRequestSetDate {
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
            else if let lastReviewSetDate = appState.lastReviewRequestSetDate,
                  currentDate.timeIntervalSince(lastReviewSetDate) >= 5 * 60,
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
}
