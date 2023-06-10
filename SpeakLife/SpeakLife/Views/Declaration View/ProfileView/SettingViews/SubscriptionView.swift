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

        Benefit(text: "But seek first his kingdom and his righteousness, and all these things will be given to you as well. - Matthew 6:33"),
        Benefit(text: "Do not conform to the pattern of this world, but be transformed by the renewing of your mind. Then you will be able to test and approve what God's will is—his good, pleasing and perfect will. - Romans 12:2"),
        
        Benefit(text: "Therefore put on the full armor of God, so that when the day of evil comes, you may be able to stand your ground - Ephesians 6:13"),
        Benefit(text: "If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault, and it will be given to you. - James 1:5"),
        
        Benefit(text: "Unlimited Access: With a premium subscription, get unlimited access to our extensive library of Bible affirmations, allowing you to find comfort, guidance, and inspiration anytime you need it."),
//        Benefit(text: "Personalized Experience: Tailor your experience to your needs. Customize and create your own affirmations, and choose themes that resonate with your spiritual journey."),
//        Benefit(text: "Ad-Free Experience: Enjoy an uninterrupted, ad-free experience. Focus on your affirmations without any distractions."),
//       Benefit(text: "Daily Inspirations: Receive exclusive daily inspirational quotes and affirmations, curated just for you, to help start your day on a positive note."),
//        Benefit(text: "Offline Access: Download your favorite affirmations and access them anytime, anywhere, even without internet connection."),
//        Benefit(text: "Early Access: Get early access to new features and content. Be the first to explore new affirmations, themes, and tools."),
//        Benefit(text: "Support the App: Your subscription helps us maintain the app, create new content, and continue providing you with a valuable resource for your spiritual journey."),
        Benefit(text: "Let each man give according as he has determined in his heart; not grudgingly, or under compulsion; for God loves a cheerful giver. - 2 Corinthians 9:7"),
        Benefit(text: "Choose amount comfortable for you! Unlocks all premium features."),
    ]
}

struct SubscriptionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    @State var currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1YR39
    
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
                    
                    Text("Your premium subscription will help to enrich your spiritual journey and allow us to continuously deliver high-quality, inspiring content. Subscribe today and experience the power of Bible affirmations like never before!")
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
