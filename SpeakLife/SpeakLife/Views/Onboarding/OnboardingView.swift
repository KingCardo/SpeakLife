//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics
import StoreKit

let onboardingBGImage2 = "pinkHueMountain"

import SwiftUI

struct OnboardingView: View  {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: DeclarationViewModel
    @EnvironmentObject var streakViewModel: StreakViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: Tab = .transformedLife
    @State var showLastChanceAlert = false
    @State var isDonePersonalization = false
    @StateObject var improvementViewModel = ImprovementViewModel()
    @AppStorage("onboardingTab") var onboardingTab = Tab.transformedLife.rawValue
    @State private var isTextVisible = false
    @State var valueProps: [Feature] = []
   
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    @ViewBuilder
    func loadingView(geometry: GeometryProxy) -> some View {
        if isDonePersonalization {
            
        } else {
            PersonalizationLoadingView(size: geometry.size, callBack: advance)
                .tag(Tab.loading)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selection) {
                
                IntroTipScene(
                    title: "You Are Like Jesus",
                    bodyText:  """
            “As He is, so are we in this world.” – 1 John 4:17

            Jesus isn’t just your Savior—He’s your example. You were designed to walk in His wisdom, peace, and power. As you speak life daily, you’re renewing your mind and becoming more like Him.
            """,
                   /* As He is, so are we in this world. – 1 John 4:17. Jesus isn’t just your Savior—He’s your example. You were designed to walk in His wisdom, peace, and power.",*/
                    subtext: "",
                    ctaText: "Step Into Your Jesus Identity",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size
                ) {
                
                    advance()
                }
                    .tag(Tab.transformedLife)
                
                IntroTipScene(
                    title: "Jesus Wants to Speak to You Daily",
                    bodyText: """
            “Draw near to God, and He will draw near to you.” – James 4:8

            Jesus is speaking—are you listening? Declaring His Word tunes your heart to His voice and strengthens your relationship with Him.
            """,
                    subtext: "",
                    ctaText: "Speak With Jesus",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size)
                {
                        advance()
                }
                    .tag(Tab.mindset)
                
               
                
                IntroTipScene(
                    title: "Victory is Already Yours",
                    bodyText: """
            “It is finished.” – John 19:30

            You don’t fight for victory—you fight from it! Jesus already won your healing, peace, and breakthrough. Declare it and walk in it.
            """,
                    subtext: "",
                    ctaText: "Declare Your Victory",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size)
                {
                        advance()
                }
                    .tag(Tab.likeJesus)
                
                IntroTipScene(
                    title: "Your Words Have Power",
                    bodyText: """
            “The words that I speak to you are spirit, and they are life.” – John 6:63

            When Jesus spoke, storms stopped, sickness left, and the impossible became possible. That same power is in YOU. Your words shape your future.

            Every time you declare God’s promises, you align with Heaven’s reality.
            """,
                    subtext: "",
                    ctaText: "Start Speaking Life!",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size)
                {
                        advance()
                }
                    .tag(Tab.liveVictorious)
                
                ImprovementScene(size: geometry.size, viewModel: improvementViewModel) {
                    withAnimation {
                        advance()
                    }
                }
                .tag(Tab.improvement)
                
                FeatureShowcaseScreen(size: geometry.size) {
                    advance()
                }
                .tag(Tab.useCase)
                
                TestimonialScreen(size: geometry.size) {
                    advance()
                }
                .tag(Tab.unshakeableFaith)
                
                RatingView(size: geometry.size) {
                    withAnimation {
                        advance()
                    }
                }.tag(Tab.review)
                
                NotificationOnboarding(size: geometry.size) {
                    withAnimation {
                        askNotificationPermission()
                    }
                }
                .tag(Tab.notification)
                
                if subscriptionStore.showSubscriptionFirst {
                    subscriptionScene(size: geometry.size)
                        .tag(Tab.subscription)
                    OfferPageView() {
                        withAnimation {
                            advance()
                        }
                    }
                    .tag(Tab.discount)
                } else {
                    OfferPageView() {
                        withAnimation {
                            advance()
                        }
                    }
                    .tag(Tab.discount)
                    subscriptionScene(size: geometry.size)
                        .tag(Tab.subscription)
                }
                
               
                
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))
            .font(.headline)
        }
        .preferredColorScheme(.light)
      
        .onAppear {
            setSelection()
            UIScrollView.appearance().isScrollEnabled = false
            setupAppearance()
            Analytics.logEvent(Event.freshInstall, parameters: nil)
        }
    }

    
    private var foregroundColor: Color {
        colorScheme == .dark ? .white : Constants.DEABlack
    }
    
    private func setSelection() {
        guard let tab = Tab(rawValue: onboardingTab) else { return }
        selection = tab
    }
    
    // MARK: - Private Views
    
    
    private func categoryScene() -> some View {
        Text("category")
    }
    
    private func subscriptionScene(size: CGSize) -> some View  {
        
        ZStack {
            SubscriptionView(size: size) {
                //withAnimation {
                    advance()
              //  }
            }
            
            VStack  {
                HStack  {
                    Button(action:  advance) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .opacity(isTextVisible ? 1 : 0)
                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            revealText()
        }
    }
   
    
    func revealText() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation {
                isTextVisible = true
            }
        }
    }
    
    
    func showAlertIfNeededAndDismissOnboarding() {
        if !subscriptionStore.isPremium {
            showLastChanceAlert = true
        } else {
            dismissOnboarding()
        }
    }
    
    // MARK: - Private methods
    
    private func advance() {
       // DispatchQueue.main.async {
           
           // withAnimation {
                switch selection {
                case .personalization:
                    impactMed.impactOccurred()
                    selection = .name
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("WelcomeScreenDone", parameters: nil)
                case .name:
                    impactMed.impactOccurred()
                    selection = .improvement//appState.onBoardingTest ? .age : .habit
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("NameScreenDone", parameters: nil)
                case .age:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("AgeScreenDone", parameters: nil)
                case .gender:
                    impactMed.impactOccurred()
                    selection = appState.onBoardingTest ? .improvement : .habit
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("GenderScreenDone", parameters: nil)
                case .habit:
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("HabitScreenDone", parameters: nil)
                case .improvement:
                    impactMed.impactOccurred()
                    selection = .useCase//.intro
                    onboardingTab = selection.rawValue
                    
                    decodeCategories(improvementViewModel.selectedExperiences)
                   // valueProps = createValueProps(categories: improvementViewModel.selectedExperiences)
                    Analytics.logEvent("ImprovementScreenDone", parameters: nil)
                case .intro:
                    impactMed.impactOccurred()
                    selection = .foe
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("IntroScreenDone", parameters: nil)
                    
                case .foe:
                    impactMed.impactOccurred()
                    selection = .life
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("IntroFoeDone", parameters: nil)
                    
                case .life:
                    impactMed.impactOccurred()
                    selection = .tip
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("IntroLifeDone", parameters: nil)
                case .tip:
                    impactMed.impactOccurred()
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("IntroTipScreenDone", parameters: nil)
                case .mindset:
                    impactMed.impactOccurred()
                    selection = .likeJesus
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("IntroMindsetScreenDone", parameters: nil)
                case .benefits:
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("BenefitScreenDone", parameters: nil)
                case .notification:
                    impactMed.impactOccurred()
                    if subscriptionStore.showSubscription {
                        selection = .subscription
                        onboardingTab = selection.rawValue
                    } else if subscriptionStore.showOneTimeSubscription {
                        selection = .discount
                        onboardingTab = selection.rawValue
                    } else {
                        dismissOnboarding()
                    }
                    Analytics.logEvent("NotificationScreenDone", parameters: nil)
                case .useCase:
                    selection = .unshakeableFaith
                    onboardingTab = selection.rawValue
                    
                case .helpGrow:
                    selection = .subscription
                    onboardingTab = selection.rawValue
                case .subscription:
                    Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
                    if subscriptionStore.isPremium || !subscriptionStore.showOneTimeSubscription {
                        viewModel.choose(.general) { _ in }
                        dismissOnboarding()
                    } else {
                        selection = .discount
                        //dismissOnboarding()
                        //selection = .discount
                    }
                case .scholarship:
                    dismissOnboarding()
                case .widgets:
                    impactMed.impactOccurred()
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("WidgetsScreenDone", parameters: nil)
    
                case .loading:
                    Analytics.logEvent("LoadingScreenDone", parameters: nil)
                    selection = .subscription
                    isDonePersonalization = true
                case .discount:
                    Analytics.logEvent("Discount", parameters: nil)
                    if subscriptionStore.showSubscription && !subscriptionStore.showSubscriptionFirst {
                        selection = .subscription
                        onboardingTab = selection.rawValue
                    } else {
                        dismissOnboarding()
                    }
                case .transformedLife:
                    impactMed.impactOccurred()
                    selection = .mindset
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("TransformedLifeScreenDone", parameters: nil)
                case .likeJesus:
                    impactMed.impactOccurred()
                    selection = .liveVictorious
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LikeJesusScreenDone", parameters: nil)
                case .liveVictorious:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LiveVictoriousScreenDone", parameters: nil)
                case .unshakeableFaith:
                    impactMed.impactOccurred()
                    selection = .review
                    Analytics.logEvent("UnshakeableFaithScreenDone", parameters: nil)
                case .confidence:
                    impactMed.impactOccurred()
                    selection = .transformedLife
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("ConfidenceScreenDone", parameters: nil)
                   
                case .review:
                    impactMed.impactOccurred()
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("ReviewScreenDone", parameters: nil)
                    DispatchQueue.main.async {
                        if let scene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive })
                            as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                    appState.lastReviewRequestSetDate = Date()
                   
                }
       // }
    }
    
    private func decodeCategories(_ categories: [DeclarationCategory]) {
        var temp = Set<DeclarationCategory>()
        for category in categories {
                temp.insert(category)
        }

        print(temp, "RWRW temp categories")
        let categories = temp.map { $0.rawValue }.joined(separator: ",")
        appState.selectedNotificationCategories = categories
        print(appState.selectedNotificationCategories, "RWRW notification categories")
        viewModel.save(temp)

    }
    
    
    private func askNotificationPermission()  {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    DispatchQueue.main.async {
                        if let _ = error {
                            appState.notificationEnabled = false
                            //return
                            // Handle the error here.
                        }
                        
                        if granted {
                            appState.notificationEnabled = true
                            registerNotifications()
                           // NotificationManager.shared.prepareDailyStreakNotification(with: appState.userName, streak: streakViewModel.currentStreak, hasCurrentStreak: streakViewModel.hasCurrentStreak)
                            
                        } else {
                            appState.notificationEnabled = false
                            // return
                        }
                        withAnimation {
                            advance()
                        }
                    }
                }
                return
            }
        }
    }
    
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Constants.DALightBlue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Constants.DALightBlue).withAlphaComponent(0.2)
    }
    
    private func moveToDiscount() {
        dismissOnboarding()
    }
    
    private func dismissOnboarding() {
        withAnimation {
            appState.isOnboarded = true
            Analytics.logEvent(Event.onBoardingFinished, parameters: nil)
        }
        
    }
    
    private func registerNotifications() {
        if appState.notificationEnabled {
            let categories = Set(appState.selectedNotificationCategories.components(separatedBy: ",").compactMap({ DeclarationCategory($0) }))
            NotificationManager.shared.registerNotifications(count: appState.notificationCount,
                                                             startTime: appState.startTimeIndex,
                                                             endTime: appState.endTimeIndex,
                                                             categories: categories)
            appState.lastNotificationSetDate = Date()
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

