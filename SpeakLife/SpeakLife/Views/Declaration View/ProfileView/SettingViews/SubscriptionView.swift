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
        
        Benefit(text: "Unlock all features"),
        Benefit(text: "Unlock all Jesus Devotionals"),
        Benefit(text: "Unlock all themes"),
//        Benefit(text: "Bible Affirmations for all of life's journey"),
//        Benefit(text: "Categories for any situation"),
//        Benefit(text: "Create your own affirmations"),
//        Benefit(text: "Reminders to transform your mindset"),
//        Benefit(text: "Unlock all prayers")

    ]
    
    static var discountBenefits: [Benefit] = [
        
        Benefit(text: "Unlock all features"),
        Benefit(text: "Enjoy 50% off discount"),
//        Benefit(text: "Daily Morning Jesus Devotionals"),
//        Benefit(text: "Create your own affirmations"),
//        Benefit(text: "Bible Affirmations for all of life's journey"),
//        Benefit(text: "Categories for any situation"),
//        Benefit(text: "Unlock all prayers")
    ]
}

struct DiscountSubscriptionView: View {
    
    let size: CGSize
    var callback: (() -> Void)?
    var currentSelection = InAppId.Subscription.speakLife1YR19
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    var body: some View {
        ZStack {
            Gradients().purple
            discountView() {
                callback?()
            }
            if declarationStore.isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
        })
//        SubscriptionView(benefits: Benefit.discountBenefits, size: size, currentSelection: InAppId.Subscription.speakLife1YR19, gradient: Gradients().redCyan, isDiscount: true) {
//            callback?()
//        }
    }
    
    func discountView(completion: @escaping(() -> Void)) -> some View {
        VStack {
            Text("SpeakLife")
                .font(Constants.titleFont)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .foregroundStyle(Constants.gold)
            Spacer()
                .frame(height: 16)
            
            ZStack {
                Capsule()
                    .fill(Constants.gold)
                    .frame(width: 100, height: 30)
                Text("Premium").textCase(.uppercase)
                    .font(.subheadline)
            }
            
            Spacer()
                .frame(height: 32)
            
            Text("One Time Offer")
                .font(.largeTitle)
            
            Text("50% Off Yearly")
                .textCase(.uppercase)
                .font(.headline)
            
            Spacer()
                .frame(height: 32)
            
            selectionBox(currentSelection: currentSelection)
            Spacer()
                .frame(height: 32)
            
           
            continueButton {
                completion()
            }
            
            Spacer()
                .frame(height: 32)
            
            Text("Cancel anytime")
                .font(.caption)
            
            
            
            
        }
    }
    
    func selectionBox(currentSelection: InAppId.Subscription) -> some View {
        ZStack {
                   RoundedRectangle(cornerRadius: 10)
                       .strokeBorder(Color.gray, lineWidth: 1)
                       .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                       .frame(height: 60)
                   
                   HStack {
                       VStack(alignment: .leading) {
                           Text("\(currentSelection.title)")
                               .bold()
                           Text("Abundant savings. Billed annually.")
                               .font(.caption)
                       }
                       .padding(.leading)
                       
                       Spacer()
                       
                       ZStack {
                           Capsule()
                               .fill(Color.black)
                               .frame(width: 100, height: 30)
                           
                           Text("Best Value")
                               .font(.caption)
                               .foregroundColor(.white)
                       }
                       .padding(.trailing)
                   }
               }
               .padding([.leading, .trailing], 20)
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

    
    func continueButton(completion: @escaping(() -> Void)) -> some View {
        return ShimmerButton(colors: [Constants.DAMidBlue, Constants.gold], buttonTitle: "Try free & save", action: makePurchase)
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
    
    init(benefits: [Benefit] = Benefit.premiumBenefits, size: CGSize, currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1YR39, gradient: any View = Gradients().purple, ctaText: String = "3 days free, then", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
        self.benefits = benefits
        self.size = size
        self.currentSelection = currentSelection
        self.gradient = gradient
        self.ctaText = ctaText
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
                    .font(.callout)
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
                    VStack(alignment: .center) {
                        Text("SpeakLife", comment: "unlock everything premium view")
                            .font(Constants.titleFont)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                            .frame(height: 18)
                        
                        Text("Manifest your greatest potential for your life with premium")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    Spacer()
                        .frame(height: 36)
                    
                    benefitRows
                        .foregroundColor(.white)
                    
                                        
                    Spacer()
                        .frame(height: 40)
                    
                    Text(ctaText)
    
                        .font(.callout)
                        .foregroundColor(.white)
                    
                    Text(currentSelection.title)
                        .padding(.horizontal)
                        .font(.body)
                        .bold()
                        .foregroundColor(.white)
                    
                    goPremiumStack(size: size)
                    
                    
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("Don’t copy the behavior and customs of this world, but let God transform you into a new person by changing the way you think. Then you will learn to know God’s will for you, which is good and pleasing and perfect. ~ Romans 12:2 (NIV)")
                        .font(.title3)
                        .foregroundColor(.white)
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
