//
//  OnboardingView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/7/22.
//

import SwiftUI
import FirebaseAnalytics


struct OnboardingView: View  {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: DeclarationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: Tab = .personalization
    @State var showLastChanceAlert = false
    @State var isDonePersonalization = false
    @StateObject var improvementViewModel = ImprovementViewModel()
    
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
                
                HabitScene(size: geometry.size, callBack: advance)
                    .tag(Tab.habit)
                
                ImprovementScene(size: geometry.size, callBack: advance, viewModel: improvementViewModel)
                    .tag(Tab.improvement)
                
                IntroScene(size: geometry.size, callBack: advance)
                    .tag(Tab.intro)
                
//                BenefitScene(size: geometry.size, tips: onboardingTips) {
//                    advance()
//                }.tag(Tab.benefits)
                
                
                NotificationOnboarding(size: geometry.size) {
                    advance()
                }
                .tag(Tab.notification)
                
//                UseCaseScene(size: geometry.size) {
//                    advance()
//                }.tag(Tab.useCase)
                
               
                
                WidgetScene(size: geometry.size) {
                    advance()
                }
                .tag(Tab.widgets)
                
                loadingView(geometry: geometry)
                    .tag(Tab.loading)
                
                
                subscriptionScene(size: geometry.size)
                    .tag(Tab.subscription)
                
              
                //                categoryScene()
                //                    .tag(Tab.category)
                
                
                
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
            setupAppearance()
            Analytics.logEvent(Event.freshInstall, parameters: nil)
        }
    }
    
    private var foregroundColor: Color {
        colorScheme == .dark ? .white : Constants.DEABlack
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
        withAnimation {
            switch selection {
            case .personalization:
                selection = .habit
                Analytics.logEvent("WelcomeScreenDone", parameters: nil)
            case .habit:
                selection = .improvement
                Analytics.logEvent("HabitScreenDone", parameters: nil)
            case .improvement:
                appState.selectedNotificationCategories = improvementViewModel.selectedCategories
                selection = .intro
                Analytics.logEvent("ImprovementScreenDone", parameters: nil)
            case .intro:
                selection = .notification
                Analytics.logEvent("IntroScreenDone", parameters: nil)
            case .benefits:
                selection = .notification
                Analytics.logEvent("BenefitScreenDone", parameters: nil)
            case .notification:
                askNotificationPermission()
                Analytics.logEvent("NotificationScreenDone", parameters: nil)
            case .useCase:
                selection = .widgets
              
            case .subscription:
                let categoryString = appState.selectedNotificationCategories.components(separatedBy: ",").first ?? "destiny"
                if let category = DeclarationCategory(categoryString) {
                    viewModel.choose(category) { _ in }
                }
                dismissOnboarding()
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
        }
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
                            selection = .widgets
                        }
                    }
                }
                return
            }
            
            
            withAnimation {
                selection = .widgets
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
        if subscriptionStore.isPremium {
            withAnimation {
                appState.isOnboarded = true
                Analytics.logEvent(Event.onBoardingFinished, parameters: nil)
            }
            
        } else {
            selection = .discount
        }
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


struct CustomSpinnerView: View {
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(Color.green)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 2), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.white)
        }
        .frame(width: 200, height: 200)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                withAnimation {
                    self.progress += 0.01
                    if self.progress >= 1.0 {
                        timer.invalidate()
                    }
                }
            }
        }
    }
}



struct PersonalizationLoadingView: View {
    let size: CGSize
    let callBack: (() -> Void)
 
    @State private var checkedFirst = false
    @State private var checkedSecond = false
    @State private var checkedThird = false
    let delay: Double = Double.random(in: 8...10)

    var body: some View {
        ZStack {
            Gradients().purple
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    CustomSpinnerView()
                    Spacer()
                        .frame(height: 16)
                    
                    Text("Hang tight, while we build your speak life plan")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedFirst = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedSecond = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            checkedThird = true
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    BulletPointView(text: "Analyzing answers", isHighlighted: $checkedFirst, delay: 0.5)
                    BulletPointView(text: "Matching your goals", isHighlighted: $checkedSecond, delay: 1.0)
                    BulletPointView(text: "Creating affirmation notifications", isHighlighted: $checkedThird, delay: 1.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation {
                        callBack()
                    }
                }
            }
        }
    }
}

struct BulletPointView: View {
    let text: String
    @Binding var isHighlighted: Bool
    let delay: Double // delay for the animation

    var body: some View {
        HStack {
            Image(systemName: isHighlighted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isHighlighted ? .green : .white)
                .scaleEffect(isHighlighted ? 1.1 : 1.0)
            Text(text)
                .foregroundColor(.white)
        }
        .opacity(!isHighlighted ? 0 : 1)
        .animation(.easeInOut, value: !isHighlighted)
        .onChange(of: isHighlighted) { newValue in
            if newValue {
                withAnimation(Animation.easeInOut(duration: 1.0).delay(delay)) {
                    isHighlighted = newValue
                }
            }
        }
    }
}
