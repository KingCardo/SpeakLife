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
    
    let size: CGSize
    let monthly = Text("Monthly Premium", comment: "Monthly premium title") + Text(" ")
    let monthlyPrice = Text("$3.99", comment: "monthly price")
        .fontWeight(.bold)
    
    let yearly = Text("12 months Premium", comment: "yearly premium") + Text(" ")
    let yearlyPrice = Text("$14.99")
        .fontWeight(.bold)
    
    let lp = Text("Lifetime Premium", comment: "lifetime premium") + Text(" ")
    let price = Text("$49.99")
        .fontWeight(.bold)
    let oneTime = Text(" ") + Text("one time", comment: "one time fee")
        .font(.caption)
    
    var body: some View {
        goPremiumView(size:  size)
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
            
            Text("Only $1.25/month, with yearly option billed annually.", comment: "monthly text breakdown")
                .font(.callout)
                .minimumScaleFactor(0.5)
            
            HStack {
                
               priceButton(action: actionMonthly,
                           durationtext: monthly,
                           subcsriptionPriceText: monthlyPrice,
                           gradient: linearGradient)
                
                priceButton(action: actionYearly,
                            durationtext: yearly,
                            subcsriptionPriceText: yearlyPrice,
                            gradient: linearGradient)
                
                priceButton(action: actionLifetime,
                            durationtext: lp,
                            subcsriptionPriceText: price + oneTime,
                            gradient: linearGradient)
                
            }
            
            .cornerRadius(4)
            HStack {
                Button(action: restore) {
                    Text("Restore", comment: "restore iap")
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
            }
        }
    }
    
    private func actionMonthly() {
        makePurchase(with: InAppId.revampMonthlyId)
    }
    
    private func actionYearly() {
        makePurchase(with: InAppId.revampYearlyId)
    }
    
    private func actionLifetime() {
        makePurchase(with: InAppId.revampLifetime)
    }
    
    private func makePurchase(with id: String) {
        declarationStore.isPurchasing = true
        StoreObserver.shared.productId = id
        
        if let id = StoreObserver.shared.productId  {
            StoreManager.shared.startProductRequest(with: id)
        }
    }
    
    private func priceButton(action: @escaping() -> Void, durationtext: Text, subcsriptionPriceText: Text, gradient: LinearGradient) -> some View {
        Button(action: action) {
            durationtext +
            subcsriptionPriceText
        }
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
