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
    @EnvironmentObject var streakViewModel: StreakViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: Tab = .transformedLife
    @State var showLastChanceAlert = false
    @State var isDonePersonalization = false
    @StateObject var improvementViewModel = ImprovementViewModel()
    @AppStorage("onboardingTab") var onboardingTab = Tab.transformedLife.rawValue
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
               
//                PersonalizationScene(size: geometry.size, callBack: advance)
//                    .tag(Tab.personalization)
//                
//        
//                NameScene(size: geometry.size, callBack: advance)
//                        .tag(Tab.name)
//                
//                AgeCollectionView(size: geometry.size, callBack: advance)
//                        .tag(Tab.age)
//                
//                GenderCollectionView(size: geometry.size, callBack: advance)
//                        .tag(Tab.gender)
                IntroTipScene(title: "Daily Declarations for a Transformed Life",
                              bodyText: "Embrace Your New Identity in Christ by Speaking Life Every Day",
                              subtext: "As believers, we are called to renew our minds daily (Romans 12:2) and walk in the new identity Christ has given us. Speaking life isn’t just a one-time act; it’s a daily discipline that aligns us with God’s will and activates His promises. You are in charge of the process—declaring God’s truth over your life, your family, and your future. Jesus is responsible for the results, ensuring that every word you speak in faith bears fruit (John 15:7-8).",
                              ctaText: "Let's go",
                              showTestimonials: false,
                              isScholarship: false, size: geometry.size, callBack: advance)
                    .tag(Tab.transformedLife)
                IntroTipScene(title: "Empowered to Speak Life Like Jesus",
                              bodyText: "Overcome Life’s Trials by Declaring God’s Word Daily",
                              subtext: "Just as Jesus spoke peace into the storm (Mark 4:39), you too can speak life into every challenge you face. The Word of God is a powerful weapon, sharper than any double-edged sword (Hebrews 4:12). Speak life into your day and experience the transformative power of God’s promises.",
                              ctaText: "Continue",
                              showTestimonials: false,
                              isScholarship: false, size: geometry.size, callBack: advance)
                    .tag(Tab.likeJesus)
                IntroTipScene(title: "Speak Life, Live Victorious",
                              bodyText: "Daily Habits for Success: Declare Your Faith and Watch Victory Unfold",
                              subtext: "Consistency is key to unlocking the power of speaking life. Just as Daniel prayed three times a day (Daniel 6:10), setting aside a specific time each day to declare God’s promises can transform your life. Practice speaking these affirmations not just in quiet moments, but in real-life situations—when anxiety creeps in, when challenges arise, or when doubts whisper. By simply speaking your faith, you’re activating the victory that Jesus has already secured for you (Mark 11:23).",
                              ctaText: "Continue",
                              showTestimonials: false,
                              isScholarship: false, size: geometry.size, callBack: advance)
                    .tag(Tab.liveVictorious)
                IntroTipScene(title: "Daily Affirmations for Unshakeable Faith",
                              bodyText: "Conquer Your Fears and Doubts with the Power of God’s Word",
                              subtext: "Jesus reminded us, 'If you have faith as small as a mustard seed... nothing will be impossible for you' (Matthew 17:20). Life’s challenges can shake your faith, but declaring God’s truth over your life can restore your confidence and peace.",
                              ctaText: "Continue",
                              showTestimonials: false,
                              isScholarship: false, size: geometry.size, callBack: advance)
                    .tag(Tab.unshakeableFaith)
               
                
                if !appState.onBoardingTest {
                    HabitScene(size: geometry.size, callBack: advance)
                        .tag(Tab.habit)
                }
                
                ImprovementScene(size: geometry.size, callBack: advance, viewModel: improvementViewModel)
                    .tag(Tab.improvement)
                
//                IntroTipScene(title: "Daily Transformation",
//                              bodyText: "Welcome to your new daily routine",
//                              subtext: "It's a simple thing, a few minutes every day speaking life and God's promises, but over time it will transform your life.",
//                              ctaText: "Let's go",
//                              showTestimonials: false,
//                              isScholarship: false, size: geometry.size, callBack: advance)
//                    .tag(Tab.tip)
                
//                IntroTipScene(title: "Speak Life",
//                              bodyText: "Be like Jesus and Speak to your problems (mountains)",
//                              subtext: "Have faith in God. Truly I tell you, if anyone says to this mountain, ‘Go, throw yourself into the sea,’ and does not doubt in their heart but believes that what they say will happen, it will be done for them. Therefore I tell you, whatever you ask for in prayer, believe that you have received it, and it will be yours. Mark 11:22-24",//"Romans 12:2 Don’t copy the behavior and customs of this world, but let God transform you into a new person by changing the way you think. Then you will learn to know God’s will for you, which is good and pleasing and perfect.",
//                              ctaText: "Transform me",
//                              showTestimonials: false,
//                              isScholarship: false, size: geometry.size, callBack: advance)
//                    .tag(Tab.mindset)
                
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
                
//                scholarshipScene(size: geometry.size, advance: advance)
//                    .tag(Tab.scholarship)
                
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
                    selection = .notification//.intro
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
                    selection = .widgets
                    onboardingTab = selection.rawValue
                    
                case .helpGrow:
                    selection = .subscription
                    onboardingTab = selection.rawValue
//                    
                case .subscription:
                    Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
                    viewModel.choose(.general) { _ in }
                  //  if subscriptionStore.isPremium {
                        dismissOnboarding()
//                    } else {
//                        selection = .scholarship
//                    }
                   
                    // selection = .widgets
                case .scholarship:
                    dismissOnboarding()
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
                case .transformedLife:
                    impactMed.impactOccurred()
                    selection = .likeJesus
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("TransformedLifeScreenDone", parameters: nil)
                case .likeJesus:
                    impactMed.impactOccurred()
                    selection = .liveVictorious
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LikeJesusScreenDone", parameters: nil)
                case .liveVictorious:
                    impactMed.impactOccurred()
                    selection = .unshakeableFaith
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LiveVictoriousScreenDone", parameters: nil)
                case .unshakeableFaith:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("UnshakeableFaithScreenDone", parameters: nil)
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
                           // NotificationManager.shared.prepareDailyStreakNotification(with: appState.userName, streak: streakViewModel.currentStreak, hasCurrentStreak: streakViewModel.hasCurrentStreak)
                            
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

