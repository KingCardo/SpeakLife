//
//  SubscriptionView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/8/22.
//

import SwiftUI
import StoreKit

struct Benefit: Identifiable  {
    
    var text: LocalizedStringKey = ""
    
    var id: String {
        "\(text)"
    }
    
    static var premiumBenefits: [Benefit] = [
//        Benefit(text: "Heightened Sense of Purpose: As you immerse yourself in Bible affirmations, you'll gain insight into your God-given purpose and talents. This clarity can guide you towards a more purpose-driven life, aligning your actions with your values and aspirations."),
//        Benefit(text: "Renewed Mindset: Regularly meditating on Bible affirmations can help reduce stress, anxiety, and negative emotions. This practice can contribute to better mental health, leading to a more balanced and contented life."),
//        Benefit(text: "Enhanced Resilience: By focusing on the promises and truths found in scripture, you'll cultivate emotional resilience and the ability to conquer life's trials. The practice of Bible affirmations can serve as a powerful reminder of God's unwavering support in times of difficulty."),
//        Benefit(text: "Deeper Spiritual Connection: Our app helps you develop a stronger relationship with God through daily reflection on scripture-based affirmations."),
//        Benefit(text: "Boosted Confidence and Self-Worth: As you internalize the affirmations rooted in God's Word, you'll start recognizing your true worth and potential. This newfound confidence can lead to improved relationships, career growth, and the courage to pursue your dreams."),
//        Benefit(text: "Empowered Decision-Making: The wisdom and guidance found in scripture-based affirmations can help you make informed, faith-aligned decisions. By integrating God's Word into your daily life, you'll be better equipped to face challenges and opportunities with confidence and grace."),
        Benefit(text: "Unlimited Access: With a premium subscription, get unlimited access to our extensive library of Bible affirmations, allowing you to find comfort, guidance, and inspiration anytime you need it."),
        Benefit(text: "Personalized Experience: Tailor your experience to your needs. Customize and create your own affirmations, and choose themes that resonate with your spiritual journey."),
        Benefit(text: "Ad-Free Experience: Enjoy an uninterrupted, ad-free experience. Focus on your affirmations without any distractions."),
       Benefit(text: "Daily Inspirations: Receive exclusive daily inspirational quotes and affirmations, curated just for you, to help start your day on a positive note."),
        Benefit(text: "Offline Access: Download your favorite affirmations and access them anytime, anywhere, even without internet connection."),
        Benefit(text: "Early Access: Get early access to new features and content. Be the first to explore new affirmations, themes, and tools."),
        Benefit(text: "Support the App: Your subscription helps us maintain the app, create new content, and continue providing you with a valuable resource for your spiritual journey."),
//        Benefit(text: "Renewed Mindset"),
//        Benefit(text: "Deeper Spiritual Connection"),
//        Benefit(text: "Warrior Resilience"),
//        Benefit(text: "Empowered Decision-Making"),
        Benefit(text: "Choose amount comfortable for you! Unlocks all premium features."),
//        Benefit(text: "Choose amount comfortable for you! Unlocks all premium features.")
    ]
}

struct SubscriptionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    @State var currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1YR29
    
    let size: CGSize
    var callback: (() -> Void)?

    var body: some View {
        goPremiumView(size: size)
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Ok")))
            })
    }
    
    private var benefitRows: some View {
        ForEach(Benefit.premiumBenefits)  { benefit in
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    .scaledToFit()
                Text(benefit.text, comment: "Benefit text")
                    .font(.caption)
                    .minimumScaleFactor(0.5)
                Spacer()
            }.padding(.horizontal)
        }
    }
    
    private func goPremiumView(size: CGSize) -> some View  {
        ZStack {
            Gradients().purple
            ScrollView {
                VStack  {
                    Spacer()
                        .frame(height: 12)
                    Text("Upgrade to", comment: "premium view title")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                        .frame(height: 36)
                    VStack {
                        Text("SpeakLife Premium", comment: "unlock everything premium view")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    benefitRows
                        .foregroundColor(.white)
                    
                                        
                    Spacer()
                        .frame(height: 40)
                    
                    goPremiumStack(size: size)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("Remember, your premium subscription will help to enrich your spiritual journey and allow us to continuously deliver high-quality, inspiring content. Subscribe today and experience the power of Bible affirmations like never before!")
                        .padding(.all)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
                
            }
            if declarationStore.isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }

            
        }
    }
    
    
    private func goPremiumStack(size: CGSize) -> some View  {
        let gradient = Gradient(colors: [Constants.DAMidBlue, .cyan])
        let linearGradient = LinearGradient(gradient: gradient,
                                                startPoint: .top,
                                                endPoint: .bottom)
        
        return VStack {
            Picker("Gift Amount", selection: $currentSelection) {
                ForEach(InAppId.Subscription.allCases) { inappID in
                    Text(inappID.title).tag(inappID)
                }
            }
            
            continueButton(gradient: linearGradient)

            HStack {
                Button(action: restore) {
                    Text("Restore", comment: "restore iap")
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
            }
        }
    }
    
    func buy() async {
        do {
            if let transaction = try await subscriptionStore.purchaseWithID([currentSelection.rawValue]) {
                print(transaction.ownershipType, "RWRW")
                callback?()
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(currentSelection.rawValue): \(error)")
        }
    }

    private func makePurchase() {
        Task {
            declarationStore.isPurchasing = true
            await buy()
            declarationStore.isPurchasing = false
        }
    }
    
    private func continueButton(gradient: LinearGradient) -> some View {
        ShimmerButton(colors: [Constants.DAMidBlue, .cyan], buttonTitle: "Try Free & Subscribe", action: makePurchase)
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

struct SubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        SubscriptionView(size: UIScreen.main.bounds.size)
            .environmentObject(DeclarationViewModel(apiService: APIClient()))
            .environmentObject(SubscriptionStore())
    }
}
