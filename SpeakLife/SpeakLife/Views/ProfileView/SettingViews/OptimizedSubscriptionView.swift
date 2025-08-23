//
//  OptimizedSubscriptionView.swift
//  SpeakLife
//
//  Optimized for maximum trial conversion and sales
//

import SwiftUI
import StoreKit
import FirebaseAnalytics

// MARK: - View Models
struct PricingOption {
    let product: Product?
    let isSelected: Bool
    let isYearly: Bool
    let displayPrice: String
    let monthlyEquivalent: String?
    let savingsPercentage: String?
    let isMostPopular: Bool
}

// MARK: - Subcomponents
struct ValueProposition: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.7, green: 0.3, blue: 1.0),  // Bright violet
                                    Color(red: 0.85, green: 0.6, blue: 1.0), // Lavender
                                    Color(red: 0.5, green: 0.2, blue: 0.9)   // Deep purple
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color(red: 1.0, green: 0.85, blue: 0.4),   // Gold
//                                    Color(red: 1.0, green: 0.95, blue: 0.7),   // Soft highlight
//                                    Color(red: 0.95, green: 0.7, blue: 0.2)    // Rich amber
//                                ]),
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                )
//                .background(
//                    Circle()
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color(red: 0.7, green: 0.4, blue: 1.0),
//                                    Color(red: 0.9, green: 0.9, blue: 1.0),
//                                    Color(red: 0.3, green: 0.6, blue: 1.0)
//                                ]),
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .shadow(color: Color.purple.opacity(0.3), radius: 4, x: 0, y: 2)
//                )
            
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PricingOptionView: View {
    let option: PricingOption
    let action: () -> Void
    let showingWeeklyMonthly: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: 16) {
                    // Selection indicator
                    ZStack {
                        Circle()
                            .fill(option.isSelected ? 
                                  (option.isYearly ? Color.black : Color.white) : 
                                  Color.white.opacity(0.2))
                            .frame(width: 24, height: 24)
                        
                        if option.isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(option.isYearly ? .white : .black)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(getSubscriptionTypeText(for: option, showingWeeklyMonthly: showingWeeklyMonthly))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(textColor)
                            
//                            if let savings = option.savingsPercentage {
//                                Text(savings)
//                                    .font(.system(size: 11, weight: .bold, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 3)
//                                    .background(
//                                        Capsule()
//                                            .fill(badgeBackgroundColor)
//                                    )
//                            }
                        }
                        
//                        Text(option.monthlyEquivalent ?? "Cancel anytime")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(subtextColor)
                    }
                    
                    Spacer()
                    
                    Text(option.displayPrice)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(backgroundGradient)
                .scaleEffect(option.isSelected ? 1.02 : 1.0)
                .shadow(
                    color: option.isSelected ? shadowColor : Color.clear,
                    radius: option.isSelected ? (option.isYearly ? 12 : 8) : 0,
                    y: option.isSelected ? (option.isYearly ? 6 : 4) : 0
                )
                
                // Most Popular badge
                if option.isMostPopular {
                    VStack {
                        HStack {
                            Spacer()
                            Text("MOST POPULAR")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.9, green: 0.3, blue: 0.3),
                                                    Color(red: 1.0, green: 0.4, blue: 0.4)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: Color.red.opacity(0.4), radius: 6, y: 2)
                                .offset(x: -12, y: -12)
                        }
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getSubscriptionTypeText(for option: PricingOption, showingWeeklyMonthly: Bool) -> String {
        guard let product = option.product else {
            return "Monthly"
        }
        
        if product.id.contains("Weekly") || product.id.contains("1WK") || product.id.lowercased().contains("week") {
            return "Weekly"
        } else if product.id.contains("1YR") || product.id.contains("Yearly") || product.id.lowercased().contains("year") {
            return "Yearly - \(option.monthlyEquivalent ?? "")"
        } else if product.id.contains("Monthly") || product.id.contains("1MO") || product.id.lowercased().contains("month") {
            return "Monthly"
        } else {
            // Fallback based on the isYearly flag in the option
            if option.isYearly {
                return "Yearly"
            } else if showingWeeklyMonthly && option.isMostPopular {
                return "Weekly"
            } else {
                return "Monthly"
            }
        }
    }
    
    private var textColor: Color {
        if option.isSelected && option.isYearly {
            return .black
        }
        return .white
    }
    
    private var subtextColor: Color {
        if option.isSelected && option.isYearly {
            return .black.opacity(0.7)
        }
        return .white.opacity(0.7)
    }
    
    private var badgeBackgroundColor: Color {
        if option.isSelected && option.isYearly {
            return Color.black.opacity(0.7)
        }
        return Color.white.opacity(0.3)
    }
    
    private var shadowColor: Color {
        if option.isYearly {
            return Color.orange.opacity(0.2)
        }
        return Color.white.opacity(0.1)
    }
    
    private var backgroundGradient: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                option.isSelected ? 
                (option.isYearly ? yearlySelectedGradient : monthlySelectedGradient) :
                unselectedGradient
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        option.isSelected ?
                        (option.isYearly ? Color.orange.opacity(0.4) : Color.white.opacity(0.4)) :
                        Color.white.opacity(0.15),
                        lineWidth: 1
                    )
            )
    }
    
    private var yearlySelectedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.88, blue: 0.2),
                Color(red: 1.0, green: 0.8, blue: 0.0),
                Color(red: 0.9, green: 0.7, blue: 0.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var monthlySelectedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.2),
                Color.white.opacity(0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var unselectedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.08),
                Color.white.opacity(0.04)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct FloatingCTAButton: View {
    let isYearlyPlan: Bool
    let displayPrice: String
    let action: () -> Void
    @Binding var animateCTA: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(ctaTitle)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(ctaSubtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white, location: 0.0),
                                .init(color: Color(red: 0.95, green: 0.95, blue: 0.95), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.white.opacity(0.4), radius: 25, x: 0, y: 10)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(animateCTA ? 1.015 : 1.0)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateCTA)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var ctaTitle: String {
        isYearlyPlan ? "Begin My Breakthrough • Free 7 Days" : "Start Your Transformation"
    }
    
    private var ctaSubtitle: String {
        let priceText = isYearlyPlan ? "Then \(displayPrice)" : displayPrice
        return "\(priceText) • Cancel anytime"
    }
 }

// MARK: - Main View
struct OptimizedSubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    
    @State private var isShowingError = false
    @State private var errorMessage = ""
    @State private var currentSelection: Product?
    @State private var hasInitialized = false
    @State private var animateCTA = false
    @State private var isInitialLoad = true
    @State private var testimonialIndex = 0
    @State private var timeRemaining: TimeInterval = 600
    
    let size: CGSize
    var callback: (() -> Void)?
    
    // Always show monthly and yearly options
    
//    private let transformationStories = [
//        "Anxiety gone in 21 days - Sarah M.",
//        "Saved my marriage in 30 days - Marcus T.",
//        "Broke 10-year depression cycle - Rachel D.",
//        "Miraculous healing declared into reality - James K.",
//        "From suicidal to purposeful daily - Ashley R."
//    ]
    
    private let valueProps = [
       // ValueProposition(icon: "shield.fill", text: "Trade Fear for Faith"),
        ValueProposition(icon: "leaf.fill", text: "Speak God’s Word with Power"),
        ValueProposition(icon: "sparkles", text: "Live in Peace, Protection & Purpose"),
        ValueProposition(icon: "brain.head.profile", text: "Renew Your Mind Daily in 5 Minutes")
    ]
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                   // socialProofBanner
                    mainOfferSection
                    Spacer().frame(height: 40)
                  //  transformationSection
                    pricingSection
                    Spacer().frame(height: 20)
                    trustSection
                    Spacer().frame(height: 140)
                }
            }
            
            VStack {
                Spacer()
                floatingCTASection
            }
            
            if declarationStore.isPurchasing {
                RotatingLoadingImageView()
            }
        }
        .onAppear(perform: setupView)
//        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
//            updateCountdown()
//        }
        .alert("", isPresented: $isShowingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Computed Properties
    private var isYearlyPlan: Bool {
        // Default to yearly on initial load to prevent CTA flicker
        guard let currentSelection = currentSelection else { return true }
        return currentSelection.id == subscriptionStore.currentOfferedPremium?.id ||
               currentSelection.id.contains("1YR") || currentSelection.id.contains("Yearly")
    }
    
    private var currentDisplayPrice: String {
        currentSelection?.displayPrice ?? 
        subscriptionStore.currentOfferedPremiumMonthly?.displayPrice ?? 
        "$9.99"
    }
    
    
    private var monthlyPrice: String {
        subscriptionStore.currentOfferedPremiumMonthly?.displayPrice ?? "$9.99"
    }
    
    private var yearlyPrice: String {
        subscriptionStore.currentOfferedPremium?.displayPrice ?? "$39.99"
    }
    
    private var yearlyEquivalentPrice: String {
        guard let yearlyProduct = subscriptionStore.currentOfferedPremium else {
            return "$3.33/mo"
        }
        let monthlyEquiv = yearlyProduct.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearlyProduct.priceFormatStyle.locale
        return "\(formatter.string(from: NSNumber(value: Double(truncating: monthlyEquiv as NSNumber))) ?? "$3.33")/mo"
    }
    
    
    private var yearlySavingsFromMonthly: String? {
        guard let monthlyProduct = subscriptionStore.currentOfferedPremiumMonthly,
              let yearlyProduct = subscriptionStore.currentOfferedPremium else {
            return nil
        }
        
        // Calculate what 12 months would cost at monthly rate
        let monthlyYearlyEquivalent = monthlyProduct.price * 12
        let yearlyCost = yearlyProduct.price
        
        // Only show savings if yearly is actually cheaper
        if yearlyCost < monthlyYearlyEquivalent {
            let savings = ((monthlyYearlyEquivalent - yearlyCost) / monthlyYearlyEquivalent) * 100
            let roundedSavings = Int(Double(truncating: savings as NSNumber).rounded())
            return "SAVE \(roundedSavings)%"
        }
        return nil
    }
    
    // MARK: - View Components
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.2, blue: 0.4),
                Color(red: 0.3, green: 0.1, blue: 0.4),
                Color(red: 0.2, green: 0.1, blue: 0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        Spacer().frame(height: 60)
    }
    
    private var socialProofBanner: some View {
        HStack {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.green)
            Text("Join 50,000+ believers transforming fear into faith in just 5 minutes.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.green)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        )
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
    
    private var mainOfferSection: some View {
        VStack(spacing: 20) {
            appIconSection
            headlineSection
            valuePropsSection
        }
    }
    
    private var appIconSection: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
            
            Image("appIconDisplay")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .white.opacity(0.2), radius: 30, x: 0, y: 10)
        }
    }
    
    private var headlineSection: some View {
        VStack(spacing: 8) {
            Text("Experience God’s")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            
            Text("Promises Every Day")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Join thousands becoming who Jesus called them to be.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .multilineTextAlignment(.center)
    }
    
    private var valuePropsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(valueProps, id: \.text) { prop in
                prop
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
//        .background(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color.purple.opacity(0.35),
//                            Color.blue.opacity(0.25)
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
//                )
//        )
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.03)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
       // .padding(.horizontal, 20)
    }
    
//    private var transformationSection: some View {
//        VStack(spacing: 16) {
//            Text("\"\(transformationStories[testimonialIndex])\"")
//                .font(.system(size: 17, weight: .medium, design: .rounded))
//                .foregroundColor(.white.opacity(0.9))
//                .multilineTextAlignment(.center)
//                .transition(.asymmetric(
//                    insertion: .move(edge: .trailing).combined(with: .opacity),
//                    removal: .move(edge: .leading).combined(with: .opacity)
//                ))
//                .id(testimonialIndex)
//                .animation(.easeInOut(duration: 0.5), value: testimonialIndex)
//                .padding(.horizontal, 30)
//        }
//        .padding(.vertical, 20)
//    }
    
    private var pricingSection: some View {
        VStack(spacing: 12) {
            // Yearly option with Most Popular badge and free trial
            PricingOptionView(
                option: PricingOption(
                    product: subscriptionStore.currentOfferedPremium,
                    isSelected: currentSelection == subscriptionStore.currentOfferedPremium,
                    isYearly: true,
                    displayPrice: yearlyPrice,
                    monthlyEquivalent: "\(yearlyEquivalentPrice)",
                    savingsPercentage: yearlySavingsFromMonthly,
                    isMostPopular: true
                ),
                action: selectYearly,
                showingWeeklyMonthly: false
            )
            .padding(.horizontal, 20)
            // Monthly option
            PricingOptionView(
                option: PricingOption(
                    product: subscriptionStore.currentOfferedPremiumMonthly,
                    isSelected: currentSelection == subscriptionStore.currentOfferedPremiumMonthly,
                    isYearly: false,
                    displayPrice: monthlyPrice,
                    monthlyEquivalent: "Cancel anytime",
                    savingsPercentage: nil,
                    isMostPopular: false
                ),
                action: selectMonthly,
                showingWeeklyMonthly: false
            )
            .padding(.horizontal, 20)
            
            
            
        }
    }
    
    private var floatingCTASection: some View {
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color(red: 0.2, green: 0.1, blue: 0.3).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            VStack(spacing: 16) {
                FloatingCTAButton(
                    isYearlyPlan: isYearlyPlan,
                    displayPrice: currentDisplayPrice,
                    action: makePurchase,
                    animateCTA: $animateCTA
                )
                
                trustIndicators
                
                Button(action: dismiss.callAsFunction) {
                    Text("No thanks")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Color(red: 0.2, green: 0.1, blue: 0.3).opacity(0.95)
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .blur(radius: 1)
                    )
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var trustIndicators: some View {
        HStack(spacing: 24) {
            if isYearlyPlan {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                    Text("7-day free trial")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                    Text("Instant access")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                Text("Cancel anytime")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var trustSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                    }
                }
                Text("4.9")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 20) {
                Button("Restore", action: restore)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Link("Privacy", destination: URL(string: "https://speaklife.io/privacy")!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Actions
    private func selectMonthly() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentSelection = subscriptionStore.currentOfferedPremiumMonthly
        }
    }
    
    private func selectYearly() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentSelection = subscriptionStore.currentOfferedPremium
        }
    }
    
    private func setupView() {
        if currentSelection == nil {
            // Default to yearly as most popular - no animation on initial load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                currentSelection = subscriptionStore.currentOfferedPremium
            }
        }
        
//        if !hasInitialized {
//            hasInitialized = true
//            // Delay CTA animation to avoid initial flicker
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                animateCTA = true
//            }
//        } else {
//            animateCTA = true
//        }
        
       // startTestimonialRotation()
    }
    
    private func updateCountdown() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
    }
    
//    private func startTestimonialRotation() {
//        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
//            withAnimation {
//                testimonialIndex = (testimonialIndex + 1) % transformationStories.count
//            }
//        }
//    }
    
    private func makePurchase() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        Task {
            declarationStore.isPurchasing = true
            defer {
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    declarationStore.isPurchasing = false
                }
            }
            
            do {
                let selectedProduct = currentSelection ?? 
                                    subscriptionStore.currentOfferedWeekly ?? 
                                    subscriptionStore.currentOfferedPremiumMonthly
                
                if let selectedProduct = selectedProduct,
                   let _ = try await subscriptionStore.purchaseWithID([selectedProduct.id]) {
                    Analytics.logEvent("subscription_started", parameters: [
                        "product_id": selectedProduct.id,
                        "price": selectedProduct.price,
                        "duration": selectedProduct.subscription?.subscriptionPeriod.debugDescription ?? "unknown"
                    ])
                    callback?()
                }
            } catch {
                errorMessage = "Unable to start your subscription. Please try again."
                isShowingError = true
            }
        }
    }
    
    private func restore() {
        Task {
            declarationStore.isPurchasing = true
            try? await AppStore.sync()
            declarationStore.isPurchasing = false
            errorMessage = "Purchases restored successfully"
            isShowingError = true
        }
    }
}
