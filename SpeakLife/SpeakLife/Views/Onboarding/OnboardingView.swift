//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics
import StoreKit
//"moonlight2"

let onboardingBGImage2 = "pinkHueMountain"

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
                    title: "Welcome, Warrior of the Kingdom",
                    bodyText: "Faith comes by hearing, and what you speak shapes your reality.",
                    subtext: "SpeakLife helps you declare God’s Word over your life, transforming fear into faith, doubt into confidence, and obstacles into victories!",
                    ctaText: "Activate My Faith",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size
                ) {
                
                    advance()
                }
                    .tag(Tab.transformedLife)
                
                ImprovementScene(size: geometry.size, viewModel: improvementViewModel) {
                    withAnimation {
                        advance()
                    }
                }
                .tag(Tab.improvement)
                
                IntroTipScene(
                    title: "Life can be overwhelming",
                    bodyText: "but God has already provided promises of peace, protection, and purpose. With SpeakLife, you can",
                    subtext: "\n- Hear God’s promises every day\n- Pray powerful, effective prayers\n- Find peace in moments of stress.",
                    ctaText: "Discover My Daily Promises",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size)
                {
                        advance()
                }
                    .tag(Tab.likeJesus)
                
                IntroTipScene(
                    title: "Truth sets you free",
                    bodyText: "The enemy’s only weapon is deception. He plants false thoughts, making them seem like your own.",
                    subtext: "\n- That’s why renewing your mind daily is essential—because the truth sets you free.",
                    ctaText: "Renew My Mind",
                    showTestimonials: false,
                    isScholarship: false,
                    size: geometry.size)
                {
                        advance()
                }
                    .tag(Tab.liveVictorious)
                
                FeatureShowcaseScreen(size: geometry.size) {
                    advance()
                }
                .tag(Tab.useCase)
                
                RatingView(size: geometry.size) {
                    withAnimation {
                        advance()
                    }
                }.tag(Tab.review)
                
                NotificationOnboarding(size: geometry.size) {
                    withAnimation {
                        advance()
                    }
                }
                .tag(Tab.notification)
                
                TestimonialScreen(size: geometry.size) {
                    advance()
                }
                .tag(Tab.unshakeableFaith)
//                IntroTipScene(
//                    title: "Begin Your Day with Devotionals",
//                    bodyText: "Grow spiritually every day by starting with devotionals that inspire and draw you closer to God.",
//                    subtext: "Each day is an opportunity to strengthen your faith and walk with Jesus through practical and encouraging devotionals.",
//                    ctaText: "Receive Daily Wisdom",
//                    showTestimonials: false,
//                    isScholarship: false,
//                    size: geometry.size)
//                {
//                        advance()
//                }
//                    .tag(Tab.liveVictorious)
//                IntroTipScene(title: "Prayers that Move Mountains",
//                              bodyText: "Speak Life Over Your Day with Powerful audio declarations to activate God’s promises and shift your mindset.",
//                              subtext: "Your words carry power. Listen to and declare faith-filled promises that replace doubt with truth, fear with peace, and lack with abundance.",
//                              ctaText: "Activate God’s Promises",
//                              showTestimonials: false,
//                              isScholarship: false, size: geometry.size)
//                {
//                        advance()
//                }
//                    .tag(Tab.unshakeableFaith)
                
//                IntroTipScene(title: "End Your Day with Peaceful Rest in God",
//                              bodyText: "Rest Peacefully in God’s Word, relax and unwind with calming audio Bible bedtime stories designed to bring peace to your nights.",
//                              subtext: "Let go of stress and fall asleep in God’s presence. Listen to peaceful Bible stories that soothe your mind, restore your heart, and bring deep, restful sleep.",
//                              ctaText: "End Your Day with Peace",
//                              showTestimonials: false,
//                              isScholarship: false, size: geometry.size)
//                {
//                        advance()
//                }
//                    .tag(Tab.confidence)
                
               
            
                
               
//                
//                RatingView(size: geometry.size) {
//                    withAnimation {
//                        advance()
//                    }
//                }.tag(Tab.review)
//            
                
               
                

                subscriptionScene(size: geometry.size)
                    .tag(Tab.subscription)
                
                OfferPageView() {
                    withAnimation {
                        advance()
                    }
                }
                .tag(Tab.discount)
                
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
   
    private func scholarshipScene(size: CGSize, advance: @escaping () -> Void) -> some View  {
        
        ZStack {
            VStack {
                Spacer().frame(height: 15)
                IntroTipScene(title: "Scholarships Available!",
                              bodyText: "",
                              subtext: "SpeakLife is available to everyone regardless of financial circumstance. Pay what feels right or apply for a full scholarship. Each yearly subscription includes a one-week free trial, giving you the chance to fully experience SpeakLife and receive delight and victory.",
                              ctaText: "Continue",
                              showTestimonials: false,
                              isScholarship: true, size: size, callBack: nil)
            }
            
            VStack  {
                HStack  {
                    Button(action:  advance) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            if viewModel.isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }
        }
        .background {
            Image(subscriptionImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height * 1.2)
                .edgesIgnoringSafeArea([.top])
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
                    selection = .likeJesus//.intro
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
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("IntroMindsetScreenDone", parameters: nil)
                case .benefits:
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("BenefitScreenDone", parameters: nil)
                case .notification:
                    impactMed.impactOccurred()
                    askNotificationPermission()
                    Analytics.logEvent("NotificationScreenDone", parameters: nil)
                case .useCase:
                    selection = .review
                    onboardingTab = selection.rawValue
                    
                case .helpGrow:
                    selection = .subscription
                    onboardingTab = selection.rawValue
                case .subscription:
                    Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
//                    viewModel.choose(.general) { _ in
//                        dismissOnboarding()
//                    }
                   
                    if subscriptionStore.isPremium || !subscriptionStore.showOneTimeSubscription {
                        viewModel.choose(.general) { _ in }
                        dismissOnboarding()
                    } else {
                        selection = .discount
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
                    dismissOnboarding()
                case .transformedLife:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("TransformedLifeScreenDone", parameters: nil)
                case .likeJesus:
                    impactMed.impactOccurred()
                    selection = .liveVictorious
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LikeJesusScreenDone", parameters: nil)
                case .liveVictorious:
                    impactMed.impactOccurred()
                    selection = .useCase
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LiveVictoriousScreenDone", parameters: nil)
                case .unshakeableFaith:
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
    
    private func decodeCategories(_ categories: [Improvements]) {
        var temp = Set<DeclarationCategory>()
        for category in categories {
            if let decCategory = DeclarationCategory(category.selectedCategory) {
                temp.insert(decCategory)
            }
        }
        
        if categories.contains(.oldTestament) {
            temp.insert(DeclarationCategory.genesis)
            temp.insert(DeclarationCategory.exodus)
            temp.insert(DeclarationCategory.leviticus)
            temp.insert(DeclarationCategory.numbers)
            temp.insert(DeclarationCategory.deuteronomy)
            temp.insert(DeclarationCategory.joshua)
        }
        
        if categories.contains(.gospel) {
            temp.insert(DeclarationCategory.matthew)
            temp.insert(DeclarationCategory.mark)
            temp.insert(DeclarationCategory.luke)
            temp.insert(DeclarationCategory.john)
        }
        
        if categories.contains(.psalms) {
            temp.insert(DeclarationCategory.psalms)
            temp.insert(DeclarationCategory.proverbs)
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
                           // advance()
                            if appState.onBoardingTest {
                                    selection = .unshakeableFaith
                                    onboardingTab = selection.rawValue
                            } else {
                                selection = .widgets
                            }
                        }
                    }
                }
                return
            }
            
            
            withAnimation {
                if appState.onBoardingTest {
                        selection = .unshakeableFaith
                    onboardingTab = selection.rawValue
                } else {
                    selection = .widgets
                }
            }
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            } else {
                // Schedule a notification with a badge and sound.
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

