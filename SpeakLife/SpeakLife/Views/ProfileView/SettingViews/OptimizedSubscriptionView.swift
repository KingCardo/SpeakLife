//
//  OptimizedSubscriptionView.swift
//  SpeakLife
//
//  Optimized for maximum trial conversion and sales
//

import SwiftUI
import StoreKit
import FirebaseAnalytics

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
    @State private var showBadge = false
    @State private var testimonialIndex = 0
    @State private var usersOnline = 1247
    @State private var timeRemaining: TimeInterval = 600 // 10 minutes
    
    let size: CGSize
    var callback: (() -> Void)?
    
    // Computed property to determine if current selection is yearly plan
    private var isYearlyPlan: Bool {
        guard let currentSelection = currentSelection else {
            return true // Default to yearly if no selection
        }
        // Check if the selection matches yearly plan by ID or price comparison
        return currentSelection.id == subscriptionStore.currentOfferedPremium?.id ||
               currentSelection.id.contains("1YR") // Fallback check for yearly ID pattern
    }
    
    private let transformationStories = [
        "Anxiety gone in 21 days - Sarah M.",
        "Saved my marriage in 30 days - Marcus T.", 
        "Broke 10-year depression cycle - Rachel D.",
        "Miraculous healing declared into reality - James K.",
        "From suicidal to purposeful daily - Ashley R."
    ]
    
    var body: some View {
        ZStack {
            // Gradient background (warmer, more inviting)
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
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with urgency
                    urgencyHeader
                    
                    // Consolidated social proof banner
                    consolidatedSocialProofBanner
                    
                    // Main offer
                    mainOfferSection
                    
                    // Transformation stories
                    transformationSection
                    
                    // Pricing (simplified)
                    pricingSection
                    
                    // Spacer for better flow
                    Spacer()
                        .frame(height: 20)
                    
                    // Trust badges
                    trustSection
                    
                    // Bottom padding for floating CTA
                    Spacer()
                        .frame(height: 140)
                }
            }
            
            // Floating CTA at bottom
            VStack {
                Spacer()
                floatingCTASection
            }
            
            if declarationStore.isPurchasing {
                RotatingLoadingImageView()
            }
        }
        .onAppear {
            // Set initial selection immediately to prevent nil state
            if currentSelection == nil {
                currentSelection = subscriptionStore.currentOfferedPremium ?? subscriptionStore.currentOfferedPremiumMonthly
            }
            setupView()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateCountdown()
        }
        .alert("", isPresented: $isShowingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var urgencyHeader: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 60)
            
            // Countdown timer with premium styling
//            VStack(spacing: 8) {
//                Text("Your personalized breakthrough expires in:")
//                    .font(.system(size: 15, weight: .medium, design: .rounded))
//                    .foregroundColor(.white.opacity(0.8))
//                
//                Text(formatTime(timeRemaining))
//                    .font(.system(size: 32, weight: .bold, design: .monospaced))
//                    .foregroundColor(.white)
//                    .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 4)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12, style: .continuous)
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [
//                                        Color.white.opacity(0.15),
//                                        Color.white.opacity(0.05)
//                                    ]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                            )
//                    )
//            }
        }
        .padding(.bottom, 24)
    }
    
    private var consolidatedSocialProofBanner: some View {
        HStack {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.green)
            Text("Join \(String(usersOnline))+ believers transforming now")
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
            // App icon with premium treatment
            ZStack {
                // Glow background
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
            
            // Simplified main headline like Calm
            VStack(spacing: 8) {
                Text("Start Your")
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("7-Day Free Trial")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Then only $3.33/month")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .multilineTextAlignment(.center)
            
            // Value props with unified gradient like Calm
            VStack(alignment: .leading, spacing: 20) {
                valueItemWithUnifiedGradient(icon: "heart.text.square.fill", text: "Personalized Declarations")
                valueItemWithUnifiedGradient(icon: "headphones.circle.fill", text: "Audio Prayers")
                valueItemWithUnifiedGradient(icon: "pencil.tip.crop.circle.badge.plus.fill", text: "Journal / Create your own")
                valueItemWithUnifiedGradient(icon: "eye.slash.circle.fill", text: "Ad-Free Experience")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
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
            .padding(.horizontal, 20)
        }
    }
    
    private func valueItemWithUnifiedGradient(icon: String, text: String) -> some View {
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
                                    Color(red: 0.7, green: 0.4, blue: 1.0),  // Light purple
                                    Color(red: 0.9, green: 0.9, blue: 1.0),  // Almost white
                                    Color(red: 0.3, green: 0.6, blue: 1.0)   // Blue
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 4, x: 0, y: 2)
                )
            
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var transformationSection: some View {
        VStack(spacing: 16) {
            // Simplified single-line testimonial like Calm
            Text("\"\(transformationStories[testimonialIndex])\"")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(testimonialIndex)
                .animation(.easeInOut(duration: 0.5), value: testimonialIndex)
                .padding(.horizontal, 30)
        }
        .padding(.vertical, 20)
    }
    
    private var pricingSection: some View {
        VStack(spacing: 12) {
            // Monthly option
            Button(action: {
                if hasInitialized {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentSelection = subscriptionStore.currentOfferedPremiumMonthly
                    }
                } else {
                    currentSelection = subscriptionStore.currentOfferedPremiumMonthly
                }
            }) {
                HStack(spacing: 16) {
                    // Selection indicator
                    ZStack {
                        Circle()
                            .fill(currentSelection == subscriptionStore.currentOfferedPremiumMonthly ? 
                                  Color.white : Color.white.opacity(0.2))
                            .frame(width: 24, height: 24)
                        
                        if currentSelection == subscriptionStore.currentOfferedPremiumMonthly {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Cancel anytime")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(subscriptionStore.currentOfferedPremiumMonthly?.displayPrice ?? "$9.99")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            currentSelection == subscriptionStore.currentOfferedPremiumMonthly ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.04)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    currentSelection == subscriptionStore.currentOfferedPremiumMonthly ?
                                    Color.white.opacity(0.4) : Color.white.opacity(0.15),
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(currentSelection == subscriptionStore.currentOfferedPremiumMonthly ? 1.02 : 1.0)
                .shadow(
                    color: currentSelection == subscriptionStore.currentOfferedPremiumMonthly ? 
                    Color.white.opacity(0.1) : Color.clear,
                    radius: 8,
                    y: 4
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            
            // Yearly option (recommended)
            Button(action: {
                if hasInitialized {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentSelection = subscriptionStore.currentOfferedPremium
                    }
                } else {
                    currentSelection = subscriptionStore.currentOfferedPremium
                }
            }) {
                ZStack {
                    HStack(spacing: 16) {
                        // Selection indicator
                        ZStack {
                            Circle()
                                .fill(currentSelection == subscriptionStore.currentOfferedPremium ? 
                                      Color.black : Color.white.opacity(0.2))
                                .frame(width: 24, height: 24)
                            
                            if currentSelection == subscriptionStore.currentOfferedPremium {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("Yearly")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(currentSelection == subscriptionStore.currentOfferedPremium ? .black : .white)
                                
                                Text("SAVE 67%")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(
                                                currentSelection == subscriptionStore.currentOfferedPremium ?
                                                Color.black.opacity(0.7) :
                                                Color.white.opacity(0.3)
                                            )
                                    )
                            }
                            
                            Text("Just $3.33/mo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    currentSelection == subscriptionStore.currentOfferedPremium ? 
                                    .black.opacity(0.7) : .white.opacity(0.7)
                                )
                        }
                        
                        Spacer()
                        
                        Text(subscriptionStore.currentOfferedPremium?.displayPrice ?? "$39.99")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(currentSelection == subscriptionStore.currentOfferedPremium ? .black : .white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                currentSelection == subscriptionStore.currentOfferedPremium ?
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.88, blue: 0.2),  // Softer gold
                                        Color(red: 1.0, green: 0.8, blue: 0.0),   // Rich gold
                                        Color(red: 0.9, green: 0.7, blue: 0.0)    // Deep gold
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.04)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        currentSelection == subscriptionStore.currentOfferedPremium ?
                                        Color.orange.opacity(0.4) : Color.white.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .scaleEffect(currentSelection == subscriptionStore.currentOfferedPremium ? 1.02 : 1.0)
                    .shadow(
                        color: currentSelection == subscriptionStore.currentOfferedPremium ? 
                        Color.orange.opacity(0.2) : Color.clear,
                        radius: 12,
                        y: 6
                    )
                    
                    // Most Popular badge with sophisticated styling
                    if currentSelection == subscriptionStore.currentOfferedPremium {
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
                                                        Color(red: 0.6, green: 0.4, blue: 0.0),  // Dark gold
                                                        Color(red: 0.8, green: 0.5, blue: 0.0)   // Lighter gold
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .shadow(color: Color.orange.opacity(0.4), radius: 6, y: 2)
                                    .offset(x: -12, y: -12)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
        }
    }
    
    private var floatingCTASection: some View {
        VStack(spacing: 0) {
            // Gradient fade at top of floating section
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
                // Main CTA button (always visible)
                Button(action: makePurchase) {
                    VStack(spacing: 6) {
                        Text(isYearlyPlan ? 
                             "Start My Free 7-Day Trial" : 
                             "Get SpeakLife Premium")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(isYearlyPlan ? 
                             "Then \(currentSelection?.displayPrice ?? "$39.99") • Cancel anytime" :
                             "\(currentSelection?.displayPrice ?? "$9.99") • Cancel anytime")
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
                            .shadow(
                                color: Color.white.opacity(0.4),
                                radius: 25,
                                x: 0,
                                y: 10
                            )
                            .shadow(
                                color: Color.black.opacity(0.15),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                    )
                    .scaleEffect(animateCTA ? 1.015 : 1.0)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateCTA)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Quick trust indicators - dynamic based on selection
                HStack(spacing: 24) {
                    HStack(spacing: 4) {
                        Image(systemName: isYearlyPlan ? "checkmark.circle.fill" : "")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                        Text(isYearlyPlan ? "7-day free trial" : "")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
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
                
                // Skip option
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
    
    private var trustIndicatorsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
//                HStack(spacing: 6) {
//                    Image(systemName: currentSelection == subscriptionStore.currentOfferedPremium ? "checkmark.shield.fill" : "creditcard.and.123")
//                        .font(.system(size: 14))
//                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
//                    Text(currentSelection == subscriptionStore.currentOfferedPremium ? "7-day free trial" : "Instant access")
//                        .font(.system(size: 14, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.9))
//                }
                
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                    Text("Secure & private")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            Text(currentSelection == subscriptionStore.currentOfferedPremium ? 
                 "Free for 7 days, then cancel anytime • No commitments" :
                 "Cancel anytime in Settings • No commitments")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
    }
    
    private var trustSection: some View {
        VStack(spacing: 12) {
            // App Store rating
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
            
            // Links
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
    
    // MARK: - Helper Methods
    
    private func setupView() {
        // Set initial selection without animation to prevent text flickering
        if !hasInitialized {
            currentSelection = subscriptionStore.currentOfferedPremium ?? subscriptionStore.currentOfferedPremiumMonthly
            hasInitialized = true
        }
        
        animateCTA = true
        showBadge = true
        startTestimonialRotation()
        usersOnline = Int.random(in: 1200...1400)
        // Randomize online users
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation {
                usersOnline = Int.random(in: 1200...1400)
            }
        }
    }
    
    private func updateCountdown() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTestimonialRotation() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation {
                testimonialIndex = (testimonialIndex + 1) % transformationStories.count
            }
        }
    }
    
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
                // Ensure we have a selection, default to yearly if somehow nil
                let selectedProduct = currentSelection ?? subscriptionStore.currentOfferedPremium ?? subscriptionStore.currentOfferedPremiumMonthly
                
                if let selectedProduct = selectedProduct,
                   let _ = try await subscriptionStore.purchaseWithID([selectedProduct.id]) {
                    Analytics.logEvent("trial_started", parameters: [
                        "product_id": selectedProduct.id,
                        "price": selectedProduct.price,
                        "duration": selectedProduct.subscription?.subscriptionPeriod.debugDescription ?? "unknown"
                    ])
                    callback?()
                }
            } catch {
                errorMessage = "Unable to start your free trial. Please try again."
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
