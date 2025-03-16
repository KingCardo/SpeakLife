//
//  SubscriptionView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/8/22.
//

import SwiftUI
import StoreKit
import FirebaseAnalytics

//let subscriptionImage = "moonlight2"

import SwiftUI

// ViewModel to manage data for the view
class OfferViewModel: ObservableObject {
    @Published var originalPrice: String = "$49.99/year"
    @Published var monthlyPrice: String = "$4.16/month"
}

struct OfferPageView: View {
    @ObservedObject var viewModel = OfferViewModel()
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    let callBack: (() -> Void)
    
    @State var currentSelection: Product?
    
    var body: some View {
            ZStack {
                VStack(spacing: 20) {
                    Image("gift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .padding(.top, 30)
                        .shadow(color: Color.purple.opacity(0.5), radius: 20, x: 10, y: 10)
                        .cornerRadius(6)
                    
                    Text("Exclusive Offer!")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 22, relativeTo: .caption))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .leading, endPoint: .trailing))
                        )
                    VStack {
                        Text("\(currentSelection?.percentageOff ?? "") off")
                            .font(Font.custom("AppleSDGothicNeo-Bold", size: 52, relativeTo: .title))
                            .foregroundColor(.white)
                        
                        Text("SpeakLife Premium")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 30, relativeTo: .title))
                            .foregroundColor(.white)
                    }
                    
                    if declarationStore.isPurchasing {
                        RotatingLoadingImageView()
                    }
                    
                    if !subscriptionStore.showSubscriptionFirst {
                        FeatureView()
                            .foregroundStyle(.white)
                    }
                    HStack(spacing: 10) {
                        VStack {
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.gray, lineWidth: 1)
                                .frame(height: 90)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Text("Original price")
                                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 22, relativeTo: .body))
                                            .foregroundColor(.gray)
                                        Text(viewModel.originalPrice)
                                            .font(Font.custom("AppleSDGothicNeo-Bold", size: 22, relativeTo: .body))
                                            .strikethrough()
                                            .foregroundColor(.gray)
                                        Text(viewModel.monthlyPrice)
                                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 20)
                               // .strokeBorder(.purple, lineWidth: 1)
                                .fill(Color.black.opacity(0.3))
                                
                                .frame(height: 90)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Text("Your price now")
                                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                                            .foregroundColor(.white)
                                        Text(currentSelection?.discountedPrice ?? "")
                                            .font(Font.custom("AppleSDGothicNeo-Bold", size: 20, relativeTo: .body))
                                            .foregroundColor(.white)
                                        Text(currentSelection?.discountedMonthlyPrice ?? "")
                                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 14, relativeTo: .body))
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Claim button
                    Button(action: {
                        makePurchase(iap: subscriptionStore.discountSubscription)
                    }) {
                        Text("Claim My \(currentSelection?.percentageOff ?? "") Off Now")
                            .font(.system(size: 18, weight: .bold))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        callBack()
                    }) {
                        Text("No thanks")
                            .font(Font.custom("AppleSDGothicNeo-Bold", size: 14, relativeTo: .body))
                            .padding()
                            .foregroundColor(.white)
                    }
                    
//                    Button(action: restore) {
//                        Text("Restore", comment: "restore iap")
//                            .font(.caption)
//                            .underline()
//                            .foregroundColor(Color.blue)
//                    }
                    
                    Spacer()
                }
                .padding()
                .background(.black)
                .alert(isPresented: $isShowingError, content: {
                    Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
                })
               
                
                
            }
            .onAppear() {
                self.currentSelection = subscriptionStore.currentOfferedDiscount
            }
    }
    
    func buy(_ iap: String) async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([iap]) {
                Analytics.logEvent(iap, parameters: nil)
                callBack()
            }
        } catch StoreError.failedVerification {
            print("error RWRW")
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(iap): \(error)")
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    private func makePurchase(iap: String) {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy(iap)
            withAnimation {
                declarationStore.isPurchasing = false
            }
        }
    }
    
    private func restore() {
        Task {
            declarationStore.isPurchasing = true
            try? await AppStore.sync()
            declarationStore.isPurchasing = false
            errorTitle = "All purchases restored"
            isShowingError = true
        }
    }
}


struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State private var currentTestimonialIndex: Int = 0
    
    @State var freeTrialEnabled = false
    
    
    @State private var textOpacity: Double = 0
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, .cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom)// Adjust time as needed
    

    @State var currentSelection: Product?
    @State var firstSelection: Product?
    @State var secondSelection: Product?
    @State var thirdSelection: Product?
    @State var weeklySelection: Product?

    @State var chooseDifferentAmount = false
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    let valueProps: [Feature]
    let size: CGSize
    var callback: (() -> Void)?
    var isDiscount = false
    
    
    init(valueProps: [Feature] = [], size: CGSize, ctaText: String = "3 days free, then", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
        self.valueProps = valueProps
        self.size = size
        // self.ctaText = ctaText
        self.isDiscount = isDiscount
        self.callback = callback
    }
    
    var body: some View {
        goPremiumView(size: size)
            .foregroundColor(.white)
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
            })
            .onAppear() {
                self.firstSelection = subscriptionStore.currentOfferedPremium
                self.currentSelection = subscriptionStore.currentOfferedPremium
                self.secondSelection = subscriptionStore.currentOfferedPremiumMonthly
                self.thirdSelection = subscriptionStore.currentOfferedLifetime
                self.weeklySelection = subscriptionStore.currentOfferedWeekly
//                self.monthlyPremiumSelection = subscriptionStore.currentOfferedPremiumMonthly
//                self.monthlyProSelection = subscriptionStore.currentOfferedMonthly
            }
    }
    
    
    private func goPremiumView(size: CGSize) -> some View  {
        // ScrollView {
        ZStack {
            
//            GeometryReader { geometry in
                if subscriptionStore.testGroup == 0 {
                    LinearGradient(gradient: Gradient(colors: [Color.black]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                }
//            else {
//                    LinearGradient(gradient: Gradient(colors: [Constants.DADarkBlue, Color.black.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
//                        .edgesIgnoringSafeArea(.all)
//                }
               
                
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {

                    ZStack {
                        Image("headerSubscription")
                            .resizable()
                           
                        VStack(alignment: .center) {
                        
                            Image("appIconDisplay")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .offset(x: 0, y: 0)
                                .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
                            
                            Text("SpeakLife")
                                .font(Font.custom("AppleSDGothicNeo-Bold", size: 30, relativeTo: .title))
                                .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
                            
                        }
                    } .frame(height: size.height * 0.25)
                    
                 
                    Spacer()
                        .frame(height: 20)
                    VStack {
                        Text("Join 50,000+ SpeakLifers Today!")
                            .font(Font.custom("AppleSDGothicNeo-Bold", size: 24, relativeTo: .title))
                            .foregroundStyle(Color.white)
//                        Text("Giving is the key to abundance! 🌱✨ The Word says, 'Give, and it will be given to you—a good measure, pressed down, shaken together, and running over!' (Luke 6:38)")
//                            .font(Font.custom("AppleSDGothicNeo", size: 12, relativeTo: .caption))
//                            .foregroundStyle(Color.white)
//                            .padding()
                    }
                    FeatureView()
                        .foregroundColor(.white)
                    Spacer()
                                            
                    VStack {
                        
                        if subscriptionStore.onlyShowYearly {
                            Button {
                                currentSelection = firstSelection
                            } label: {
                                firstSelectionBox()
                            }
        
                        } else {
                            
                            if subscriptionStore.showYearlyOption {
                                Button {
                                    currentSelection = firstSelection
                                } label: {
                                    firstSelectionBox()
                                }
                            } else {
                                Button {
                                    currentSelection = weeklySelection
                                } label: {
                                    weeklySelectionBox()
                                }
                            }
                            Spacer()
                                .frame(height: 8)
                            Button {
                                currentSelection = secondSelection
                            } label: {
                                secondSelectionBox()
                            }
//                            if !subscriptionStore.showYearlyOption {
//                                Button {
//                                    currentSelection = firstSelection
//                                } label: {
//                                    firstSelectionBox()
//                                }
//                            } else {
//                                Button {
//                                    currentSelection = thirdSelection
//                                } label: {
//                                    thirdSelectionBox()
//                                }
//                            }
                            
                        }
                        
                    }
        
                    Spacer()
                
                    
                    goPremiumStack()
                    
                    
             //   }
            }
            .onAppear {
                currentSelection = firstSelection
            }
            
            
            if declarationStore.isPurchasing {
                RotatingLoadingImageView()
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                VStack  {
                    HStack  {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                            
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $chooseDifferentAmount) {
            patronView
        }
    }
    
    @ViewBuilder
    private var patronView: some View {
        GeometryReader { reader in
            ZStack {
                // Main content
                VStack {
                    IntroTipScene(
                        title: "Pay What Feels Right",
                        bodyText: "",
                        subtext: "Please support our mission of delivering Jesus, daily peace, love, and transformation to a world in need. Unlocks all features.",
                        ctaText: "Continue",
                        showTestimonials: false,
                        isScholarship: true,
                        size: reader.size,
                        callBack: {},
                        buyCallBack: { subscription in
                            makePurchase(iap: subscription)
                        }
                    )
                }
                
                // ProgressView centered in the middle
                if declarationStore.isPurchasing {
                    RotatingLoadingImageView()
                }
            }
        }
    }
    
    var subscriptionStack: some View {
        VStack {
            
            Button {
                makePurchase()
            } label: {
                Text("Try Free & Subscribe")
                    .font(Font.custom("AppleSDGothicNeo-Bold", size: 20))
                    .foregroundColor(Constants.DAMidBlue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            
            Text(firstSelection?.displayName ?? "")
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 12, relativeTo: .callout))
                .foregroundColor(.white)
                .padding(.top, 4)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemBackground).opacity(0.2))
        .cornerRadius(10)
        .padding()
    }
    
    
    @ViewBuilder
    var costDescription: some View {
        VStack(spacing: 4) {
            Text(currentSelection?.costDescription ?? "")
                .multilineTextAlignment(.center)
            
        }
        .font(Font.custom("AppleSDGothicNeo-Regular", size: 12))
        .foregroundColor(.white)
    }
    
    
    private func goPremiumStack() -> some View  {
        return VStack {
            continueButton(gradient:  LinearGradient(gradient: Gradient(colors: [.cyan, .black]), startPoint: .top, endPoint: .bottom))
                .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 6)
            Spacer()
                .frame(height: 10)
            costDescription
            Spacer()
                .frame(height: 8)
            
            
            HStack {
                Button(action: restore) {
                    Text("Restore", comment: "restore iap")
                        .font(.caption)
                        .underline()
                        .foregroundColor(Color.blue)
                }
                
                Spacer()
                    .frame(width: 16)
                
                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Text("Terms & Conditions")
                        .font(.caption)
                        .underline()
                        .foregroundColor(Color.blue)
                }
//                if appState.isOnboarded {
//                    Spacer()
//                        .frame(width: 16)
//                    Button(action: presentDifferentAmount) {
//                        Text("Pick your price", comment: "different iap")
//                            .font(.caption2)
//                            .foregroundColor(Color.blue)
//                    }
//                }
            }
        }
        .padding([.leading, .trailing], 20)
    }
    
    func presentDifferentAmount() {
        chooseDifferentAmount.toggle()
    }
    
    func buy() async {
        do {
            guard let currentSelection = currentSelection else { return }
            if let transaction = try await subscriptionStore.purchaseWithID([currentSelection.id]) {
                print(currentSelection, transaction.id, transaction.jsonRepresentation, transaction.productType, "RWRW")
              //  NotificationManager.shared.scheduleTrialEndingReminder(subscriptionDate: Date())
                Analytics.logEvent(currentSelection.id, parameters: ["backgroundImage": subscriptionStore.testGroup == 0 ? subscriptionStore.onboardingBGImage : onboardingBGImage2])
               // callback?()
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    private func makePurchase() {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy()
            withAnimation {
                declarationStore.isPurchasing = false
                callback?()
                
            }
        }
    }
    
    func buy(_ iap: Product) async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([iap.id]) {
               // NotificationManager.shared.scheduleTrialEndingReminder(subscriptionDate: Date())
                Analytics.logEvent(iap.id, parameters: ["backgroundImage": subscriptionStore.testGroup == 0 ? subscriptionStore.onboardingBGImage : onboardingBGImage2])
            }
        } catch StoreError.failedVerification {
            print("error RWRW")
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(iap.id): \(error)")
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    func makePurchase(iap: Product) {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy(iap)
            withAnimation {
                declarationStore.isPurchasing = false
                callback?()
            }
        }
    }
    
    func buy(_ iap: InAppId.Subscription) async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([iap.rawValue]) {
               // NotificationManager.shared.scheduleTrialEndingReminder(subscriptionDate: Date())
                Analytics.logEvent(iap.rawValue, parameters: ["backgroundImage": subscriptionStore.testGroup == 0 ? subscriptionStore.onboardingBGImage : onboardingBGImage2])
                //callback?()
            }
        } catch StoreError.failedVerification {
            print("error RWRW")
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(iap.rawValue): \(error)")
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    private func makePurchase(iap: InAppId.Subscription) {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy(iap)
            withAnimation {
                declarationStore.isPurchasing = false
                callback?()
            }
        }
    }
    private func continueButton(gradient: LinearGradient) -> some View {
        return ShimmerButton(colors: [.white], buttonTitle: currentSelection?.ctaButtonTitle ?? "Subscribe", action: makePurchase, textColor: .black)
            .opacity(currentSelection != nil ? 1 : 0.5)
    }
    // currentSelection == firstSelection ? "Try Free & Subscribe" : "Subscribe"
    private func restore() {
        Task {
            declarationStore.isPurchasing = true
            try? await AppStore.sync()
            declarationStore.isPurchasing = false
            errorTitle = "All purchases restored"
            isShowingError = true
        }
    }
    
    
    func firstSelectionBox() -> some View {
        ZStack() {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(currentSelection == firstSelection ? Constants.gold : Color.gray, lineWidth: 1)
                .background(.clear)
                .shadow(color: currentSelection == firstSelection ? Color.yellow.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 60)
            
            if subscriptionStore.showMostPopularBadge {
                
                HStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Constants.traditionalGold)
                            .frame(width: 100, height: 30)
                            .cornerRadius(15)
                        
                        Text("Most Popular")
                            .font(.caption2)
                            .foregroundColor(.black)
                    }
                    //  .padding(.trailing)
                    .offset(x: -10, y: -36)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(firstSelection?.ctaDurationTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14))
                        .bold()
                    Text(firstSelection?.subTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 12))
                    
                }
                Spacer()
            }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
                
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    
    func weeklySelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(currentSelection == weeklySelection ? Constants.gold : Color.gray, lineWidth: 1)
                .background(.clear)
                .shadow(color: currentSelection == weeklySelection ? Color.yellow.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 50)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weeklySelection?.ctaDurationTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14))
                        .bold()
                    Text(weeklySelection?.subTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 12))
                    
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding([.leading, .trailing])
            
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    
    
    func secondSelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(currentSelection == secondSelection ? Constants.gold : Color.gray, lineWidth: 1)
                .background(.clear)
                .shadow(color: currentSelection == secondSelection ? Color.yellow.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 50)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(secondSelection?.ctaDurationTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14))
                        .bold()
                    Text(secondSelection?.subTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 12))
                    
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding([.leading, .trailing])
            
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    func thirdSelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(currentSelection == thirdSelection ? Constants.gold : Color.gray, lineWidth: 1)
                .background(.clear)
                .shadow(color: currentSelection == thirdSelection ? Color.yellow.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 50)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(thirdSelection?.ctaDurationTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        .bold()
                    Text(thirdSelection?.subTitle ?? "")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14))
                    
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding([.leading, .trailing])
            
        }
        
        .padding([.leading, .trailing], 20)
    }
    
}


struct StarRatingView: View {
    @EnvironmentObject var appState: AppState
    let rating: Double // Assuming the rating is out of 5
    @State private var starAnimations: [Bool] = Array(repeating: false, count: 5)
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(self.starColor(for: index))
                        .opacity(self.starAnimations[index] ? 0.7 : 1.0)
                        .scaleEffect(self.starAnimations[index] ? 1.2 : 1.0)
                        .onAppear {
                            self.animateStar(at: index)
                        }
                }
            }
            Spacer()
                .frame(height: 2)
            Text(String(format: "%.1f stars", rating))
                .foregroundStyle(Color.white)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .caption))
        }
    }
    
    func starColor(for index: Int) -> Color {
        return Constants.gold
    }
    
    func animateStar(at index: Int) {
        // Change the duration and delay to adjust the twinkling effect
        let animationDuration: Double = 0.5
        let animationDelay: Double = Double.random(in: 0...1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                self.starAnimations[index].toggle()
            }
        }
    }
}

struct TestimonialView: View {
    var testimonial: Testimonial
    @Namespace private var animationNamespace
    let size: CGSize
    
    @State private var currentTextOpacity: Double = 1.0
    @State private var textKey: UUID = UUID()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("🌟 Testimonial's 🌟")
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .headline))
                .padding(.top)
                .frame(maxWidth: .infinity)
            
            TestimonialTextView(text: testimonial.text)
                .id(textKey)
                .frame(height: 110)
                .matchedGeometryEffect(id: "text", in: animationNamespace)
        }
        .foregroundColor(.white)
        .padding()
        .frame(width: size.width * 0.90, height: size.height * 0.2)
        .background(Constants.DAMidBlue.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding()
        .onChange(of: testimonial.text) { _ in
            textKey = UUID()
        }
    }
}

struct TestimonialTextView: View {
    var text: String
    
    var body: some View {
        Text("\"\(text)\"")
            .font(.custom("AppleSDGothicNeo-Regular", size: 16))
        //.font(.body)
            .fontWeight(.light)
            .italic()
            .padding()
            .transition(.opacity) // Apply a fade transition
            .animation(.easeInOut(duration: 3.0), value: text) // Animate the opacity transition
    }
}

struct Testimonial: Identifiable {
    var id: Int
    var text: String
    var author: String
    var details: String
}


struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Custom shape drawing logic
        // This example creates an arc-like shape
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}


struct RotatingLoadingImageView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background or other views here, if needed
            
            // Circular Image with rotation animation
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage()) // Replace this with your image
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150) // Set your desired size
                .clipShape(Circle())
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.8 : 1.0) // Opacity transition
                .shadow(color: isAnimating ? Color.blue.opacity(0.7) : Color.purple.opacity(0.7), radius: 20, x: 0, y: 0) // Change the scale
                .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true // Start the animation when the view appears
                }
        }
        .padding()
    }
}

struct RotatingLoadingImageView_Previews: PreviewProvider {
    static var previews: some View {
        RotatingLoadingImageView() // Display a live preview of ContentView in Xcode
    }
}


import SwiftUI

struct SubscriptionPricingView: View {
    @State private var selectedPlan: String = "Yearly Pro"

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Choose Your Plan")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Plan Options
            VStack(spacing: 15) {
                // Pro Plan (Yearly)
                PlanOptionView(
                    title: "Pro Yearly",
                    subtitle: "Save 50% - $24.99/year",
                    isBestValue: true,
                    isSelected: selectedPlan == "Yearly Pro"
                ) {
                    selectedPlan = "Yearly Pro"
                }

                // Premium Plan (Yearly)
                PlanOptionView(
                    title: "Premium Yearly",
                    subtitle: "Save 50% - $49.99/year",
                    isBestValue: true,
                    isSelected: selectedPlan == "Yearly Premium"
                ) {
                    selectedPlan = "Yearly Premium"
                }

                // Divider
                Divider()
                    .padding(.horizontal, 30)

                // Pro Plan (Monthly)
                PlanOptionView(
                    title: "Pro Monthly",
                    subtitle: "$3.99/month",
                    isBestValue: false,
                    isSelected: selectedPlan == "Monthly Pro"
                ) {
                    selectedPlan = "Monthly Pro"
                }

                // Premium Plan (Monthly)
                PlanOptionView(
                    title: "Premium Monthly",
                    subtitle: "$7.99/month",
                    isBestValue: false,
                    isSelected: selectedPlan == "Monthly Premium"
                ) {
                    selectedPlan = "Monthly Premium"
                }
            }
            .padding(.horizontal)

            Spacer()

            // Continue Button
            Button(action: {
                print("Selected Plan: \(selectedPlan)")
            }) {
                Text("Continue with \(selectedPlan)")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - PlanOptionView
struct PlanOptionView: View {
    var title: String
    var subtitle: String
    var isBestValue: Bool
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(isSelected ? .blue : .primary)
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.orange)
                                .cornerRadius(5)
                        }
                    }
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubscriptionPricingView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionPricingView()
    }
}


