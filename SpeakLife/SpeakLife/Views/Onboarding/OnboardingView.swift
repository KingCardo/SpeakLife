//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics

let onboardingBGImage = "moonlight2"

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

                IntroTipScene(title: "Daily Affirmations for a Transformed Life",
                              bodyText: "",//"Embrace Your New Identity in Christ by Speaking Life Every Day",
                              subtext: "Speaking life isn’t just a one-time act; it’s a daily discipline that aligns us with God’s will and activates His promises. You are in charge of the process—declaring God’s truth over your life, your family, and your future. Jesus is responsible for the results, ensuring that every word you speak in faith bears fruit (John 15:7-8).",
                              ctaText: "Let's go",
                              showTestimonials: false,
                              isScholarship: false, size: geometry.size, callBack: advance)
                    .tag(Tab.transformedLife)
//                IntroTipScene(title: "Speak Life Like Jesus",
//                              bodyText: "Overcome Life’s Trials by Declaring God’s Word Daily",
//                              subtext: "Just as Jesus spoke peace into the storm (Mark 4:39), you too can speak life into every challenge you face. The Word of God is a powerful weapon, sharper than any double-edged sword (Hebrews 4:12). Speak life into your day and experience the transformative power of God’s promises.",
//                              ctaText: "Continue",
//                              showTestimonials: false,
//                              isScholarship: false, size: geometry.size, callBack: advance)
//                    .tag(Tab.likeJesus)
     
                if !appState.onBoardingTest {
                    HabitScene(size: geometry.size, callBack: advance)
                        .tag(Tab.habit)
                }
                
                ImprovementScene(size: geometry.size, callBack: advance, viewModel: improvementViewModel)
                    .tag(Tab.improvement)
                
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
                subscriptionScene(size: geometry.size)
                    .tag(Tab.subscription)
            
                
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
            SubscriptionView(valueProps: valueProps, size: size) {
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
                    valueProps = createValueProps(categories: improvementViewModel.selectedExperiences)
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
                case .subscription:
                    Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
                    viewModel.choose(.general) { _ in }
                        dismissOnboarding()
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
                case .discount:
                    dismissOnboarding()
                case .transformedLife:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("TransformedLifeScreenDone", parameters: nil)
                case .likeJesus:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LikeJesusScreenDone", parameters: nil)
                case .liveVictorious:
                    impactMed.impactOccurred()
                    selection = .unshakeableFaith
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LiveVictoriousScreenDone", parameters: nil)
                case .unshakeableFaith:
                    impactMed.impactOccurred()
                    selection = .confidence
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("UnshakeableFaithScreenDone", parameters: nil)
                case .confidence:
                    impactMed.impactOccurred()
                    selection = .improvement
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("ConfidenceScreenDone", parameters: nil)
                }
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
        
        if categories.contains(.oldTestament) {
            temp.insert(DeclarationCategory("genesis")!)
            temp.insert(DeclarationCategory("exodus")!)
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
    
    func createValueProps(categories: [Improvements]) -> [Feature]  {
        guard categories.count > 1 else { return [] }
        var props: [Feature] = []
        for category in categories {
            switch category {
            case .oldTestament: break
            case .gospel, .psalms: break
            case .gratitude:
                props.append(Feature(name: "Gratitude", subtitle: "Unlock more joy in your life by practicing daily gratitude through God's word.", imageName: "hands.sparkles.fill"))
            case .stress:
                props.append(Feature(name: "Inner Peace & Joy", subtitle: "Find peace and calm with affirmations that release stress and anchor you in God's promises.", imageName: "wind"))
            case .grace:
                props.append(Feature(name: "God's Grace", subtitle: "Embrace God's unending grace and live free from guilt.", imageName: "sparkles"))
            case .love:
                props.append(Feature(name: "Jesus Love", subtitle: "Feel the depth of Jesus' love and let it transform your heart every day.", imageName: "bird.fill"))
            case .health:
                props.append(Feature(name: "Health", subtitle: "Speak God's healing and vitality into your life with affirmations for health.", imageName: "heart.fill"))
            case .destiny:
                props.append(Feature(name: "Destiny", subtitle: "Align with God's purpose for you and step boldly into your destiny.", imageName: "star.fill"))
            case .safety:
                props.append(Feature(name: "God's Protection", subtitle: "Rest in the assurance of God's protection with daily reminders of His care.", imageName: "shield.fill"))
            case .loneliness:
                props.append(Feature(name: "Feeling Lonely", subtitle: "Combat loneliness with affirmations that remind you of God's constant presence.", imageName: "person.2.fill"))
            case .wealth:
                props.append(Feature(name: "Wealth", subtitle: "Invite God's abundance into your life with affirmations rooted in His promises.", imageName: "creditcard.fill"))
            case .peace:
                props.append(Feature(name: "Peace", subtitle: "Experience God's peace that calms your mind and guards your heart.", imageName: "leaf.fill"))
            }
        }
       
        return props
        
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
                                    selection = .subscription
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
                        selection = .subscription
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

