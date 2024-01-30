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
        
//        Benefit(text: "Unlock all features"),
        Benefit(text: "Grow your relationship with Jesus"),
        Benefit(text: "Walk in your new identity"),
        Benefit(text: "Fight back with God's promises"),
        Benefit(text: "Enjoy victory in every area of your life"),
        Benefit(text: "Experience peace, joy, and God's love"),
       // Benefit(text: "Unlock all Jesus Devotionals"),
//        Benefit(text: "Categories for any situation"),
//        Benefit(text: "Unlock all themes"),
        Benefit(text: "Unlock everything"),
       // Benefit(text:"Proverbs 18:21: Words have immense power; they can shape your reality and influence your future. Think of them as tools that can build or destroy."),

      //  Benefit(text:"Mark 11:23: Your convictions, voiced out loud, hold incredible power. If you truly believe and verbalize your goals or aspirations, no obstacle is too big to overcome, not even metaphorical mountains."),

       // Benefit(text: "Matthew 21:22: Faith in what you pray for is crucial. When you ask for something, believe in its possibility with conviction, and your prayers can manifest into reality."),

      //  Benefit(text: "James 3:4-5: Like a small rudder steering a large ship, your words, though seemingly insignificant, can define your life's trajectory. They can set you on a path to success or failure."),
      //  Benefit(text: "Dive deeper into your relationship with Jesus, our goal is to support you in cultivating a vibrant, growing relationship with Christ, every single day. Join us and embrace a life transformed by His word."),

       // Benefit(text: "Romans 4:17: This speaks to the power of belief and speaking things into existence. Just as God brought forth creation from nothingness, your faith and words have the potential to bring about change and create new realities.")
        //        Benefit(text: "Bible Affirmations for all of life's journey"),
        //        Benefit(text: "Categories for any situation"),
        //        Benefit(text: "Create your own affirmations"),
        //        Benefit(text: "Reminders to transform your mindset"),
        //        Benefit(text: "Unlock all prayers")
        
    ]
    
    static var discountBenefits: [Benefit] = [
        
        Benefit(text: "Unlock all features"),
        Benefit(text: "Enjoy 60% off discount"),
        Benefit(text: "Romans 4:17: This speaks to the power of belief and speaking things into existence. Just as God brought forth creation from nothingness, your faith and words have the potential to bring about change and create new realities.")
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
    var percentOffText: String = "50% Off Yearly"
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    init(size: CGSize, currentSelection: InAppId.Subscription = .speakLife1YR19, percentOffText: String = "50% Off Yearly") {
        self.size = size
        self.currentSelection = currentSelection
        self.percentOffText = percentOffText
    }
    
    init(size: CGSize, currentSelection: InAppId.Subscription = .speakLife1YR19,  callback: (() -> Void)? = nil) {
        self.size = size
        self.currentSelection = currentSelection
        self.callback = callback
    }
    
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
            
            Text(percentOffText)
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
            
            Text("Romans 4:17: This speaks to the power of belief and speaking things into existence. Just as God brought forth creation from nothingness, your faith and words have the potential to bring about change and create new realities.")
                .font(.body)
                .foregroundStyle(.white)
                .padding([.leading, .trailing, .top])
            
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
                .foregroundColor(.black)
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
       // ShimmerButton(buttonTitle: currentSelection == firstSelection ? "Try Free & Subscribe" : "Subscribe", action: makePurchase)
        return ShimmerButton(colors: [Constants.DAMidBlue, Constants.gold], buttonTitle: "Try free & save", action: makePurchase)
    }
}

struct SubscriptionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    @State var currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1YR39
    var firstSelection = InAppId.Subscription.speakLife1YR39
    var thirdSelection = InAppId.Subscription.speakLife1YR29
    var secondSelection = InAppId.Subscription.speakLife1MO4
    
    let size: CGSize
    var callback: (() -> Void)?
    let benefits: [Benefit]
    var isDiscount = false
    
    var ctaText: String
    
    init(benefits: [Benefit] = Benefit.premiumBenefits, size: CGSize, ctaText: String = "3 days free, then", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
        self.benefits = benefits
        self.size = size
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
            Gradients().cyanPurple
            ScrollView {
                VStack  {
                    Spacer()
                        .frame(height: 40)
                    VStack(alignment: .center) {
                        Text("Try SpeakLife Premium", comment: "unlock everything premium view")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                    }
                    Spacer()
                        .frame(height: 24)
                    
                    HStack {
                        StarRatingView(rating: 4.8)
                    }.padding([.leading,.trailing, .bottom],20)
                    
                    benefitRows
                        .foregroundColor(.white)
                    
                    
                    Spacer()
                        .frame(height: 24)
                    
                    
                    VStack {
                        
                        Button {
                            currentSelection = firstSelection
                        } label: {
                            yearlyCTABox()
                        }
                        
//                        Button {
//                            currentSelection = thirdSelection
//                        } label: {
//                            yearlyNoTrialCTABox()
//                        }
                        
                        Button {
                            currentSelection = secondSelection
                        } label: {
                            monthlySelectionBox()
                        }
                        
                        
                    }
                    
                    
                    goPremiumStack(size: size)
                    
                    Spacer()
                        .frame(height: 16)
                    
                    costDescription
                    
                    Spacer()
                        .frame(height: 16)
                   
                    
                    Text("James 3:4-5 teaches us the immense power of our words: just as a tiny rudder directs a mighty ship, our words chart the course of our life's journey—guiding us towards either triumph or defeat.")
                        .font(.caption)
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
    
    @ViewBuilder
    var costDescription: some View {
            HStack(spacing: 2) {
                if currentSelection == firstSelection {
                    Text(ctaText)
                }
                
                Text(currentSelection.title + ".")
                
                Text("Cancel anytime.")
                
            }
            .font(Font.custom("Roboto-Regular", size: 16, relativeTo: .body))
        .foregroundColor(.white)
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
        ShimmerButton(colors: [Constants.DAMidBlue, .cyan], buttonTitle: currentSelection == firstSelection ? "Start 3-Day Free Trial" : "Subscribe", action: makePurchase)
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
    
    func yearlyCTABox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == firstSelection ? Constants.DAMidBlue : .clear))
                .frame(height: 60)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(firstSelection.ctaDurationTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        Text("\(firstSelection.ctaPriceTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 20))
                            .bold()
                    }
                    Text(firstSelection.subTitle)
                        .font(.caption)
                }
                .foregroundStyle(currentSelection == firstSelection ? .white : .black)
                .padding(.leading)
                
                Spacer()
                
                ZStack {
                    Capsule()
                        .fill(Constants.specialRateColor)
                        .frame(width: 100, height: 30)
                    
                    Text("Best Value")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
            
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    func yearlyNoTrialCTABox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == thirdSelection ? Constants.DAMidBlue : .clear))
                .frame(height: 60)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(thirdSelection.ctaDurationTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        Text("\(thirdSelection.ctaPriceTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 20))
                            .bold()
                    }
                    Text("Abundant savings. Billed annually.")
                        .font(.caption)
                }
                .foregroundStyle(currentSelection == thirdSelection ? .white : .black)
                .padding(.leading)
                
                Spacer()
                
                ZStack {
                    Capsule()
                        .fill(Constants.specialRateColor)
                        .frame(width: 100, height: 30)
                    
                    Text("Special Rate")
                            .font(.callout)
                            .foregroundColor(.white)
                }
                .padding(.trailing)
            }
            
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    func monthlySelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == secondSelection ? Constants.DAMidBlue : .clear))
                .frame(height: 60)
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(secondSelection.ctaDurationTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        Text("\(secondSelection.ctaPriceTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 20))
                            .bold()
                    }
                }
                .foregroundStyle(currentSelection == secondSelection ? .white : .black)
                .padding(.leading)
                
                Spacer()
            }
        }
        
        .padding([.leading, .trailing], 20)
    }
}


struct StarRatingView: View {
    let rating: Double // Assuming the rating is out of 5
    @State private var starAnimations: [Bool] = Array(repeating: false, count: 5)

    var body: some View {
        VStack {
            HStack {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(self.starColor(for: index))
                        .scaleEffect(self.starAnimations[index] ? 1.2 : 1.0)
                       // .opacity(self.starAnimations[index] ? 0.5 : 1.0)
                        .onAppear {
                            self.animateStar(at: index)
                        }
                }
            }
            Spacer()
                .frame(height: 2)
            Text(String(format: "%.1f/5 star rating", rating))
                .foregroundStyle(Color.white)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .caption))
        }
       }
       
       func starColor(for index: Int) -> Color {
           return .yellow //index <= Int(rating) ? .yellow : .gray
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
