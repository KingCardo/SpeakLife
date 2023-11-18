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
        
        Benefit(text: "Daily Morning Jesus Devotionals"),
        Benefit(text: "Bible Affirmations for all of life's journey"),
        Benefit(text: "Categories for any situation"),
        Benefit(text: "Create your own affirmations"),
        Benefit(text: "Reminders to transform your mindset"),
        Benefit(text: "Unlock all prayers")

    ]
    
    static var discountBenefits: [Benefit] = [
        
        Benefit(text: "Enjoy 50% off discount"),
        Benefit(text: "Daily Morning Jesus Devotionals"),
        Benefit(text: "Create your own affirmations"),
        Benefit(text: "Bible Affirmations for all of life's journey"),
        Benefit(text: "Categories for any situation"),
        Benefit(text: "Unlock all prayers")
    ]
}

struct DiscountSubscriptionView: View {
    
    let size: CGSize
    var callback: (() -> Void)?
    
    var body: some View {
        SubscriptionView(benefits: Benefit.discountBenefits, size: size, currentSelection: InAppId.Subscription.speakLife1MO2, gradient: Gradients().redCyan, isDiscount: true) {
            callback?()
        }
    }
}

struct SubscriptionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    var currentSelection: InAppId.Subscription
    
    let size: CGSize
    var callback: (() -> Void)?
    let benefits: [Benefit]
    var gradient: any View = Gradients().purple
    var isDiscount = false
    
    var ctaText: String
    
    init(benefits: [Benefit] = Benefit.premiumBenefits, size: CGSize, currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1MO4, gradient: any View = Gradients().purple, ctaText: String = "3 days free, then just", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
        self.benefits = benefits
        self.size = size
        self.currentSelection = currentSelection
        self.gradient = gradient
        self.ctaText = "\(ctaText) \(currentSelection.title). Cancel anytime."
        self.isDiscount = isDiscount
    }

    var body: some View {
        goPremiumView(size: size)
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
            })
    }
    
    private var benefitRows: some View {
        ForEach(benefits)  { benefit in
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
            AnyView(gradient)
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
                    
                    Text(ctaText)
                        .padding(.all)
                        .font(isDiscount ? .body : .caption)
                        .foregroundColor(.white)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("This Book of the Law shall not depart from your mouth, but you shall meditate on it day and night, so that you may be careful to do according to all that is written in it. For then you will make your way prosperous, and then you will have good success. - Joshua 1:8")
                        .padding()
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

            continueButton(gradient: linearGradient)

            HStack {
                Button(action: restore) {
                    Text("Restore", comment: "restore iap")
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
//                Spacer()
//                
//                Button(action: presentOtherIAPOptions) {
//                    Text("Other", comment: "iap iptons")
//                        .font(.caption2)
//                        .foregroundColor(Color.blue)
//                }
            }
        }
    }
    
    func buy() async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([currentSelection.rawValue]) {
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
    
    func presentOtherIAPOptions() {
        
    }
}

//struct SubscriptionView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        SubscriptionView(size: UIScreen.main.bounds.size)
//            .environmentObject(DeclarationViewModel(apiService: APIClient()))
//            .environmentObject(SubscriptionStore())
//    }
//}
