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
    @Published var originalPrice: String = "$39.99/year"
    @Published var monthlyPrice: String = "$3.33/month"
}

extension AnyTransition {
    static var slideFadeFromRight: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

struct OfferPageView: View {
    @ObservedObject var viewModel = OfferViewModel()
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    @Binding var countdown: TimeInterval
    let callBack: (() -> Void)
    @State private var animateCTA = false
    @Environment(\.dismiss) var dismiss
    @State var currentSelection: Product?
    
    @State private var testimonialIndex = 0
    private let testimonials = [
        "It brings peace to my mornings and hope to my day.",
        "Holy Spirit designed",
        "God used this app to restore my confidence.",
        "Scriptures now speak directly to my heart thanks to SpeakLife.",
        "This is my favorite way to start the day!",
        "I speak life over myself every morning now — it’s changed everything.",
        "My mind feels renewed and at peace after every session.",
        "This app taught me how to fight fear with God’s Word.",
        "It helps me hear God's voice clearer every day.",
        "I finally feel confident speaking truth over my life.",
    ]

    var body: some View {
        GeometryReader { reader in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.2, green: 0.4, blue: 0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image("gift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: reader.size.width * 0.6, height: reader.size.width * 0.6)
                        .padding(.top, 30)
                        .shadow(color: Color.purple.opacity(0.5), radius: 20, x: 10, y: 10)
                        .cornerRadius(6)
                    
                    Text("Limited Time Offer!")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .leading, endPoint: .trailing))
                        )
                    // Countdown Timer
                    Text("Ends in: \(formatTime(countdown))")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 4)
                    
                    VStack(spacing: 4) {
                        Text("\(currentSelection?.percentageOff ?? "") off")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("SpeakLife Premium")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    if declarationStore.isPurchasing {
                        RotatingLoadingImageView()
                    }
                    
                    
                    HStack(spacing: 10) {
                        VStack {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.gray, lineWidth: 1)
                                .frame(height: 90)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Text("Original price")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(.gray)
                                        Text(viewModel.originalPrice)
                                            .font(.system(size: 20, weight: .bold))
                                            .strikethrough()
                                            .foregroundColor(.gray)
                                        Text(viewModel.monthlyPrice)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 90)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Text("Your price now")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(.white.opacity(0.9))
                                        Text(currentSelection?.discountedPrice ?? "")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                        Text(currentSelection?.discountedMonthlyPrice ?? "")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                )
                        }
                    }
                    .padding(.top, 10)
                    
                    Group {
                        Text("\"\(testimonials[testimonialIndex])\"")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.slideFadeFromRight)
                            .id(testimonialIndex)
                    }
                    .animation(.easeInOut(duration: 0.5), value: testimonialIndex)

                    Button(action: {
                        makePurchase(iap: subscriptionStore.discountSubscription)
                    }) {
                        Text("Claim My \(currentSelection?.percentageOff ?? "") Off Now")
                            .font(.system(size: 18, weight: .bold))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.pink, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .scaleEffect(animateCTA ? 1.03 : 1.0)
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("No thanks")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding()
                .alert(isPresented: $isShowingError, content: {
                    Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
                })
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                       animateCTA = true
                                   }
                                   startTestimonialRotation()
                self.currentSelection = subscriptionStore.currentOfferedDiscount
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
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
    
    private func startTestimonialRotation() {
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                withAnimation {
                    testimonialIndex = (testimonialIndex + 1) % testimonials.count
                }
            }
        }
}

//        "I speak life over myself every morning now \nit’s changed everything.",
//        "My mind feels renewed and at peace\n after every session.",
//        "This app taught me how to fight fear \n with God’s Word.",


struct SubscriptionView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore

    @State private var isShowingError = false
    @State private var testimonialIndex = 0
    @State private var currentSelection: Product?
    @State private var pulse = false

    let size: CGSize
    var callback: (() -> Void)?

    private let testimonials = [
        "Holy Spirit designed",
        "I feel God's presence every time I open this app.",
            "It helps me hear God's voice clearer every day.",
            "Scriptures now speak directly to my heart.",
            "More than an app — it’s part of my walk with God.",
            "I finally feel confident speaking truth over my life.",
            "This is my favorite way to start the day!"
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                headerSection
                titleSection
                FeatureView()
                testimonialView
                selectionButtons
                goPremiumStack
                Spacer().frame(height: 4)
            }
            .foregroundColor(.white)
            .alert("", isPresented: $isShowingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("There was an error processing your purchase.")
            }
            .onAppear {
                currentSelection = subscriptionStore.currentOfferedPremium
                startTestimonialRotation()
            }

            if declarationStore.isPurchasing {
                RotatingLoadingImageView()
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadCloseButton
            }
        }
    }
    
    private var headerSection: some View {
        ZStack {
            AnimatedHeaderBackground()

            VStack {
                Spacer()
                    .frame(height: size.height * 0.06)
                Image("appIconDisplay")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)

                Text("SpeakLife")
                    .font(.system(size: 26, weight: .bold))
                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
            }
        }
        .frame(height: size.height * 0.23)
    }

    @ViewBuilder
    private var titleSection: some View {
        Spacer().frame(height: 12)
        VStack(spacing: 10) {
    
            Text("Speak life daily with affirmations, devotionals, & prayer")
                .font(Font.custom("AppleSDGothicNeo-Bold", size: 24, relativeTo: .title))
                .multilineTextAlignment(.center)
//            Text("to rewire your thoughts and experience God’s peace, healing, and purpose")
//                .font(Font.custom("AppleSDGothicNeo-Bold", size: 16, relativeTo: .subheadline))
//                .multilineTextAlignment(.center)
//                .foregroundStyle(.gray)
        }
    }

    private var testimonialView: some View {
        Text("\"\(testimonials[testimonialIndex])\"")
            .font(.system(size: 12, weight: .medium, design: .default))
            .italic()
            .foregroundColor(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .transition(.slideFadeFromRight)
            .id(testimonialIndex)
            .animation(.easeInOut(duration: 0.5), value: testimonialIndex)
    }

    private var selectionButtons: some View {
        VStack(spacing: 8) {
            if let annual = subscriptionStore.currentOfferedPremium {
                subscriptionOption(product: annual)
            }
            if let monthly = subscriptionStore.currentOfferedPremiumMonthly {
                subscriptionOption(product: monthly)
            }
        }
    }
    
    private func subscriptionOption(product: Product) -> some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                currentSelection = product
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.ctaDurationTitle)
                            .font(.system(size: 16))
                        Text(product.subTitle)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(currentSelection == product ? Color.yellow : Color.gray, lineWidth: 1)
                )
                .shadow(color: currentSelection == product ? Color.yellow.opacity(0.6) : .clear, radius: 4)
                .padding(.horizontal, 20)
            }

            if product.id == subscriptionStore.currentOfferedPremium?.id {
                HStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Constants.traditionalGold)
                            .frame(width: 90, height: 30)
                            .cornerRadius(15)
                        
                        Text("Most Popular")
                            .font(.caption2)
                            .foregroundColor(.black)
                    }
                    .offset(x: -25, y: -10)
    
                }
            }
        }
    }
    
    
    private var goPremiumStack: some View {
        VStack(spacing: 8) {
            Button(action: makePurchase) {
                Text(currentSelection?.ctaButtonTitle ?? "Subscribe")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .scaleEffect(pulse ? 1.05 : 1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            pulse = true
                        }
                    }
                    .padding(.horizontal)
            }
            .opacity(currentSelection != nil ? 1 : 0.5)

            Text(currentSelection?.costDescription ?? "")
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 10, relativeTo: .footnote))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            HStack {
                Button("Restore", action: restore)
                    .font(.caption)
                    .underline()
                    .foregroundColor(.blue)

                Spacer().frame(width: 16)

                Link("Terms & Conditions", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption)
                    .underline()
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
    }

    private var iPadCloseButton: some View {
        VStack {
            HStack {
                Button(action: dismiss.callAsFunction) {
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

    private func startTestimonialRotation() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation {
                testimonialIndex = (testimonialIndex + 1) % testimonials.count
            }
        }
    }

    private func makePurchase() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        Task {
           declarationStore.isPurchasing = true
            defer {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                        declarationStore.isPurchasing = false
                    }
                }
            do {
                if let currentSelection = currentSelection,
                   let _ = try await subscriptionStore.purchaseWithID([currentSelection.id]) {
                    Analytics.logEvent(currentSelection.id, parameters: nil)
                    callback?()
                }
            } catch {
                isShowingError = true
            }
        }
    }

    private func restore() {
        Task {
            declarationStore.isPurchasing = true
            try? await AppStore.sync()
            declarationStore.isPurchasing = false
            isShowingError = true
        }
    }

    private var patronView: some View {
        GeometryReader { reader in
            ZStack {
                IntroTipScene(
                    title: "Pay What Feels Right",
                    bodyText: "",
                    subtext: "Please support our mission of delivering Jesus, daily peace, love, and transformation to a world in need. Unlocks all features.",
                    ctaText: "Continue",
                    showTestimonials: false,
                    isScholarship: true,
                    size: reader.size,
                    callBack: {},
                    buyCallBack: { _ in makePurchase() }
                )
                if declarationStore.isPurchasing {
                    RotatingLoadingImageView()
                }
            }
        }
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

struct AnimatedHeaderBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Image("headerSubscription")
                .resizable()
                .scaledToFill()
                .scaleEffect(animate ? 1.03 : 1)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)

            // Optional overlay sparkle or glow
            RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.05), Color.clear]),
                           center: .top,
                           startRadius: 10,
                           endRadius: 300)
                .blendMode(.screen)
        }
        .onAppear {
            animate = true
        }
    }
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
    
