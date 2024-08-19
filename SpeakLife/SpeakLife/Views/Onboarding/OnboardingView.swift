//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics

let onboardingBGImage = "moonlight2"//"desertSky"

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
    @State private var isTextVisible = false
   
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
                
//                AgeCollectionView(size: geometry.size, callBack: advance)
//                        .tag(Tab.age)
//                
//                GenderCollectionView(size: geometry.size, callBack: advance)
//                        .tag(Tab.gender)
                
                if !appState.onBoardingTest {
                    HabitScene(size: geometry.size, callBack: advance)
                        .tag(Tab.habit)
                }
                
                ImprovementScene(size: geometry.size, callBack: advance, viewModel: improvementViewModel)
                    .tag(Tab.improvement)
                
                IntroTipScene(title: "Daily Transformation",
                              bodyText: "Are You Ready to Speak Life?",
                              subtext: "Master the art of speaking and activating the promises of God, full of blessings, health and reshaping your destiny.",
                              ctaText: "Let's go",
                              showTestimonials: true,
                              size: geometry.size, callBack: advance)
                    .tag(Tab.tip)
                
                IntroTipScene(title: "Meditation",
                              bodyText: "A deeper revelation of Jesus love for you is the solution to ALL of your problems",
                              subtext: "As you meditate on how much you are already forgiven and blessed because of Jesus sacrifice for ALL your sins, begin to receive and develop an intimate relationship with him. He wants to be your best friend!",//"Romans 12:2 Don’t copy the behavior and customs of this world, but let God transform you into a new person by changing the way you think. Then you will learn to know God’s will for you, which is good and pleasing and perfect.",
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
                
//                HelpUsGrowView(viewModel: HelpUsGrowViewModel(model: HelpUsGrowModel(
//                           title: "Help Us Grow!",
//                           message: "Your feedback is invaluable to us. Ratings are vital to spreading the app to people in need.",
//                           buttonText: "Rate Us"
//                ))) {
//                    advance()
//                }
//                .tag(Tab.helpGrow)
                
                
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
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                isTextVisible = true
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
                            .foregroundColor(.white)
                        
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
                    selection = .improvement//appState.onBoardingTest ? .age : .habit
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
                    
                case .helpGrow:
                    selection = .subscription
                    onboardingTab = selection.rawValue
//                    
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
        
        if categories.contains(.gospel) {
            temp.insert(DeclarationCategory("matthew")!)
            temp.insert(DeclarationCategory("mark")!)
            temp.insert(DeclarationCategory("luke")!)
            temp.insert(DeclarationCategory("john")!)
        }
        
        if categories.contains(.psalms) {
            temp.insert(DeclarationCategory("psalms")!)
            temp.insert(DeclarationCategory("proverbs")!)
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
           // viewModel.requestReview.toggle()
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

