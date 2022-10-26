//
//  SubscriptionView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/8/22.
//

import SwiftUI

struct Benefit: Identifiable  {
    
    var text: LocalizedStringKey = ""
    
    var id: String {
        "\(text)"
    }
    
    static var premiumBenefits: [Benefit] = [
        Benefit(text: "Affirmations that will transform your day and life!"),
        Benefit(text: "Access to all categories"),
        Benefit(text: "Create and schedule your own affirmations"),
        Benefit(text: "Reminders to revamp your mindset!"),
        Benefit(text: "Access to all themes and new features on the way"),
    ]
}

struct SubscriptionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var storeManager: StoreManager
    
    @State var currentSelection: InAppId.AppID = InAppId.AppID.speakLife1YR19
    
    let size: CGSize

    var body: some View {
        goPremiumView(size: size)
            .foregroundColor(colorScheme == .dark ? .white : Constants.DEABlack)
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
                ForEach(InAppId.AppID.allCases) { inappID in
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

    private func makePurchase() {
        declarationStore.isPurchasing = true
        StoreObserver.shared.productId = currentSelection.rawValue
        
        if let id = StoreObserver.shared.productId  {
            print(id)
            StoreManager.shared.startProductRequest(with: id)
        }
    }
    
    private func continueButton(gradient: LinearGradient) -> some View {
        Button("Continue", action: makePurchase)
        .foregroundColor(Color.white)
        .frame(width: size.width * 0.22 ,height: 100)
        .padding(.horizontal)
        .background(Capsule().fill(gradient))
        .cornerRadius(20)
    }
    
    private func restore() {
        StoreObserver.shared.restore()
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        SubscriptionView(size: UIScreen.main.bounds.size)
    }
}
