//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics

let onboardingBGImage = "desertSky"//"desertSky"

struct OnboardingView: View  {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: DeclarationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: Tab = .personalization
    @State var showLastChanceAlert = false
    @State var isDonePersonalization = false
    @StateObject var improvementViewModel = ImprovementViewModel()
    @AppStorage("onboardingTab") var onboardingTab = Tab.personalization.rawValue
   
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
               
                PersonalizationScene(size: geometry.size, callBack: advance)
                    .tag(Tab.personalization)
                
        
                NameScene(size: geometry.size, callBack: advance)
                        .tag(Tab.name)
                
                AgeCollectionView(size: geometry.size, callBack: advance)
                        .tag(Tab.age)
                
                GenderCollectionView(size: geometry.size, callBack: advance)
                        .tag(Tab.gender)
                
                if !appState.onBoardingTest {
                    HabitScene(size: geometry.size, callBack: advance)
                        .tag(Tab.habit)
                }
                
                ImprovementScene(size: geometry.size, callBack: advance, viewModel: improvementViewModel)
                    .tag(Tab.improvement)
                
                
//                IntroScene(headerText: appState.onBoardingTest ? "SpeakLife" : "DECLARATIONS", bodyText: "Favorite, create your own, and Speak affirmations out loud at least 3 times but as many times as you need to a day to begin transforming your mind and life.", footerText: "The power comes from speaking and meditating so you believe and watch the Lord bring it to pass.", buttonTitle: "Begin transformation", size: geometry.size, callBack: advance)
//                    .tag(Tab.intro)
//                
//                IntroScene(headerText: "The enemy", bodyText: "satan comes to steal, kill, and destroy. He wants to steal the truth, word of God from your heart, your health, joy, peace and much more!", footerText: "But we have weapons to take offense. Jesus gave us authority over all power of the enemy! Luke 10:19", buttonTitle: "Fight back", size: geometry.size, callBack: advance)
//                    .tag(Tab.foe)
//                
//                IntroScene(headerText: "Your Savior", bodyText: "Jesus, came so you can have life abundantly, prosper and be in great health. So as God's children we must fight the enemy", footerText: "and not let him steal from us. Time to declare victory everyday by speaking life. Jesus already conquered for us, we have to keep it.", buttonTitle: "Claim what's mine!", size: geometry.size, callBack: advance)
//                    .tag(Tab.life)
                
                IntroTipScene(title: "Daily Transformation",
                              bodyText: "Are You Ready to Speak Life?",
                              subtext: "Enter a realm where your voice is your greatest weapon. Master the art of speaking and activating the promises of God, full of blessings, health and reshaping your destiny.",
                              ctaText: "Let's go",
                              showTestimonials: true,
                              size: geometry.size, callBack: advance)
                    .tag(Tab.tip)
                
                IntroTipScene(title: "Meditation",
                              bodyText: "involves deep reflection on specific spiritual truths, scriptures",
                              subtext: "Those who delight in the Lord and meditate day and night prosper in everything they do! Psalm 1:2-3*",
                              ctaText: "Transform me",
                              showTestimonials: false,
                              size: geometry.size, callBack: advance)
                    .tag(Tab.mindset)
                
                NotificationOnboarding(size: geometry.size) {
                    advance()
                }
                .tag(Tab.notification)

                
                if !appState.onBoardingTest {
                    WidgetScene(size: geometry.size) {
                        advance()
                    }
                    .tag(Tab.widgets)
                }
                
//                loadingView(geometry: geometry)
//                    .tag(Tab.loading)
                
                
                subscriptionScene(size: geometry.size)
                    .tag(Tab.subscription)
                
//                discountScene(size: geometry.size)
//                    .tag(Tab.discount)
                
                
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))
            .font(.headline)
        }
        .preferredColorScheme(.light)
        .alert(isPresented: $showLastChanceAlert) {
            Alert(
                           title: Text("Last chance to save 50%"),
                           message: Text("Are you sure you want to pass?"),
                           primaryButton: .default(Text("Yes I'm sure")) {
                               dismissOnboarding()
                           },
                           secondaryButton: .cancel(Text("Cancel")) {
                               
                           }
                       )
        }
        
        .onAppear {
            setSelection()
            if viewModel.backgroundMusicEnabled {
                AudioPlayerService.shared.playSound(files: resources)
            }
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
                advance()
            }
            
            VStack  {
                HStack  {
                    Button(action:  advance) {
                        Text("CANCEL",  comment: "Cancel text for label")
                            .font(.callout)
                            .frame(height: 35)
                            .foregroundColor(.black)
                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    private func discountScene(size: CGSize) -> some View  {
        
        ZStack {
            DiscountSubscriptionView(size: size) {
                advance()
            }
            
            VStack  {
                HStack  {
                    Button(action:  showAlertIfNeededAndDismissOnboarding) {
                        Text("CANCEL",  comment: "Cancel text for label")
                            .font(.callout)
                            .frame(height: 35)
                            .foregroundColor(.black)
                        
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
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
           
            withAnimation {
                switch selection {
                case .personalization:
                    impactMed.impactOccurred()
                    selection = .name
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("WelcomeScreenDone", parameters: nil)
                case .name:
                    impactMed.impactOccurred()
                    selection = appState.onBoardingTest ? .age : .habit
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("NameScreenDone", parameters: nil)
                case .age:
                    impactMed.impactOccurred()
                    selection = appState.onBoardingTest ? .gender : .habit
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
                    selection = .tip//.intro
                    onboardingTab = selection.rawValue
                    appState.selectedNotificationCategories = improvementViewModel.selectedCategories
                    decodeCategories(improvementViewModel.selectedExperiences)
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
                    selection = .mindset
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
                    selection = .widgets
                    onboardingTab = selection.rawValue
                    
                case .subscription:
                    viewModel.choose(.general) { _ in }
                    moveToDiscount()
                    //dismissOnboarding()
                    Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
                    // selection = .widgets
                case .widgets:
                    if isDonePersonalization {
                        selection = .subscription
                    } else {
                        selection = .loading
                    }
                    
                case .loading:
                    Analytics.logEvent("LoadingScreenDone", parameters: nil)
                    selection = .subscription
                    isDonePersonalization = true
                    //    dismissOnboarding()
                case .discount:
                    dismissOnboarding()
                }
        //    }
        }
    }
    
    private func decodeCategories(_ categories: [Improvements]) {
        var temp = Set<DeclarationCategory>()
        for category in categories {
            if let decCategory = DeclarationCategory(category.selectedCategory) {
                temp.insert(decCategory)
            }
        }
        
        if !temp.contains(.destiny) {
            temp.insert(.destiny)
        }
        print(temp, "RWRW temp categories")
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
                            
                        } else {
                            appState.notificationEnabled = false
                            // return
                        }
                        
                        withAnimation {
                           // advance()
                            if appState.onBoardingTest {
                               // if isDonePersonalization {
                                    selection = .subscription
                                    onboardingTab = selection.rawValue
//                                } else {
//                                    selection = .loading
//                                }
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
                   // if isDonePersonalization {
                        selection = .subscription
                    onboardingTab = selection.rawValue
//                    } else {
//                        selection = .loading
//                    }
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
//        if subscriptionStore.isPremium {
//            dismissOnboarding()
//        } else {
//            withAnimation {
//                selection = .discount
//            }
//        }
    }
    
    private func dismissOnboarding() {
        withAnimation {
            appState.isOnboarded = true
            Analytics.logEvent(Event.onBoardingFinished, parameters: nil)
           // viewModel.helpUsGrowAlert = true
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

