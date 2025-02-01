//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics
import StoreKit
let onboardingBGImage = "moonlight2"

let onboardingBGImage2 = "pinkHueMountain"


import SwiftUI

struct RatingView: View {
    let size: CGSize
    let callBack: (() -> Void)
    @State private var showStars = [false, false, false, false, false]

    var body: some View {
        VStack {
            
            Text("SpeakLife")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.5), radius: 4, x: 0, y: 2)
                .padding(.top, 20)
            
            Spacer()

            ZStack {
                // Background circle layers
                Circle()
                    .strokeBorder(Constants.DAMidBlue.opacity(0.3), lineWidth: 4)
                    .frame(width: 260, height: 260)
                
                Circle()
                    .strokeBorder(Constants.DAMidBlue.opacity(0.2), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(Constants.DAMidBlue.opacity(0.3))
                    .frame(width: 140, height: 140)
                
                // Five-star rating with staggered fade-in animations
                               HStack(spacing: 10) {
                                   ForEach(0..<5) { index in
                                       Image(systemName: "star.fill")
                                           .resizable()
                                           .aspectRatio(contentMode: .fit)
                                           .frame(width: 30 + CGFloat(index % 3) * 10, height: 30 + CGFloat(index % 3) * 10)
                                           .foregroundColor(Color.yellow)
                                           .shadow(color: Color.yellow.opacity(0.5), radius: 5, x: 0, y: 0)
                                           .opacity(showStars[index] ? 1 : 0)
                                           .scaleEffect(showStars[index] ? 1 : 0.8)
                                           .animation(Animation.spring(response: 0.5, dampingFraction: 0.6)
                                                       .delay(0.1 * Double(index)), value: showStars[index])
                                   }
                               }
                               .onAppear {
                                   // Trigger the fade-in animation for each star
                                   for i in 0..<5 {
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(i)) {
                                           showStars[i] = true
                                       }
                                   }
                               }
                           }
                           .padding(.bottom, 40)
 
            
            Text("Help us make the world more like Jesus!")
                .font(Font.custom("AppleSDGothicNeo-Bold", size: 22, relativeTo: .body))
                .foregroundStyle(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(10)
            
            // Subtext about app review
            Text("Your app store review helps spread the word and grow the SpeakLife community!")
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            ShimmerButton(colors: [Constants.DAMidBlue, .yellow], buttonTitle: "Rate us", action: callBack)
            .frame(width: size.width * 0.87 ,height: 60)
            .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)

            .scaleEffect(showStars[4] ? 1 : 0.95) // Button appears last
                        .animation(Animation.spring(response: 0.4, dampingFraction: 0.5)
                                    .delay(0.5), value: showStars[4])
            .padding(.horizontal, 20)
        
            Spacer()
                .frame(width: 5, height: size.height * 0.07)
        }
        .background(
            ZStack {
                Image(onboardingBGImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                Color.black.opacity(0.05)
                    .edgesIgnoringSafeArea(.all)
            })
    }
       
}

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
                    title: "Weclome, We're Glad You Found Us",
                    bodyText: "Feeling overwhelmed or disconnected?",
                    subtext: "Let God’s Word transform your life. Start today with daily prayers and affirmations rooted in Scripture.",
                    ctaText: "Begin My Journey",
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
                
                FeatureShowcaseScreen(size: geometry.size) {
                    advance()
                }
                    .tag(Tab.liveVictorious)
                
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
//            if viewModel.backgroundMusicEnabled {
//                AudioPlayerService.shared.playSound(files: resources)
//            }
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
                    selection = .widgets
                    onboardingTab = selection.rawValue
                    
                case .helpGrow:
                    selection = .subscription
                    onboardingTab = selection.rawValue
                case .subscription:
                    Analytics.logEvent("SubscriptionScreenDone", parameters: nil)
//                    viewModel.choose(.general) { _ in
//                        dismissOnboarding()
//                    }
                   
                    if subscriptionStore.isPremium {
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
                    selection = .notification
                    onboardingTab = selection.rawValue
                    Analytics.logEvent("LiveVictoriousScreenDone", parameters: nil)
                case .unshakeableFaith:
                    impactMed.impactOccurred()
                    selection = .subscription
                    onboardingTab = selection.rawValue
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
    
//    func createValueProps(categories: [Improvements]) -> [Feature]  {
//        guard categories.count > 1 else { return [] }
//        var props: [Feature] = []
//        for category in categories {
//            switch category {
//            case .oldTestament: props.append(Feature(name: "God's identity", subtitle: "Learn more about God's true identity and faithfulness", imageName: "book.fill"))
//            case .gospel, .psalms: break
//            case .gratitude:
//                props.append(Feature(name: "Gratitude", subtitle: "Unlock more joy in your life by practicing daily gratitude through God's word.", imageName: "hands.sparkles.fill"))
//            case .stress:
//                props.append(Feature(name: "Peace & Joy", subtitle: "Find peace and calm with affirmations that release stress and anchor you in God's promises.", imageName: "wind"))
//            case .grace:
//                props.append(Feature(name: "God's Grace", subtitle: "Embrace God's unending grace and live free from guilt.", imageName: "sparkles"))
//            case .love:
//                props.append(Feature(name: "Jesus Love", subtitle: "Feel the depth of Jesus' love and let it transform your heart every day.", imageName: "bird.fill"))
//            case .health:
//                props.append(Feature(name: "Health", subtitle: "Speak God's healing and vitality into your life with affirmations for health.", imageName: "heart.fill"))
//            case .destiny:
//                props.append(Feature(name: "Destiny", subtitle: "Align with God's purpose for you and step boldly into your destiny.", imageName: "star.fill"))
//            case .safety:
//                props.append(Feature(name: "God's Protection", subtitle: "Rest in the assurance of God's protection with daily reminders of His care.", imageName: "shield.fill"))
//            case .loneliness:
//                props.append(Feature(name: "Feeling Lonely", subtitle: "Combat feeling lonely with promises that remind you of God's constant presence.", imageName: "person.2.fill"))
//            case .wealth:
//                props.append(Feature(name: "Wealth", subtitle: "Invite God's abundance into your life with affirmations rooted in His promises.", imageName: "creditcard.fill"))
//            case .peace:
//                props.append(Feature(name: "Peace", subtitle: "Experience God's peace that calms your mind and guards your heart.", imageName: "leaf.fill"))
//            }
//        }
//       
//        return props
//        
//    }
    
    
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

