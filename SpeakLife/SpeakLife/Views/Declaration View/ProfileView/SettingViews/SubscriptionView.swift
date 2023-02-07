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
        Benefit(text: "Bible promises that will transform your day and life!"),
        Benefit(text: "Access to all categories"),
        Benefit(text: "Create and schedule your own Bible promises or affirmations."),
        Benefit(text: "Reminders to renew your mindset with promises from the Creator of the Universe!"),
        Benefit(text: "Access to all themes and new features on the way"),
        Benefit(text: "Choose amount comfortable for you! Unlocks all premium features.")
    ]
}

struct SubscriptionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    @State var currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1MO4
    
    let size: CGSize
    var callback: (() -> Void)?

    var body: some View {
        goPremiumView(size: size)
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
            })
    }
    
    private var benefitRows: some View {
        ForEach(Benefit.premiumBenefits)  { benefit in
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Constants.DAMidBlue)
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
            VStack  {
                Spacer()
                    .frame(width: 8, height: 36)
                Text("Try Premium", comment: "premium view title")
                    .font(.largeTitle)
                Spacer()
                    .frame(height: 36)
                VStack {
                    Image(systemName: "crown.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.yellow)
                        .scaledToFit()
                    Text("Unlock everything", comment: "unlock everything premium view")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                benefitRows
                
                Spacer()
                    .frame(height: 40)
                
                goPremiumStack(size: size)
            }
            
            if declarationStore.isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
        }
    }
    
    
    private func goPremiumStack(size: CGSize) -> some View  {
        let gradient = Gradient(colors: [Constants.DAMidBlue,  .blue])
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
            if try await subscriptionStore.purchaseWithID([currentSelection.rawValue]) != nil {
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
        Button("Continue".uppercased(), action: makePurchase)
        .foregroundColor(Color.white)
        .frame(width: size.width * 0.75 , height: 70)
        .padding(.horizontal)
        .background(Capsule().fill(gradient))
        .cornerRadius(20)
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
    }
}
