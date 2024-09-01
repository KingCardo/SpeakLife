//
//  SubscriptionView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 2/8/22.
//

import SwiftUI
import StoreKit
import FirebaseAnalytics

let subscriptionImage = "moonlight2"

struct Benefit: Identifiable  {
    
    var text: LocalizedStringKey = ""
    var subText: LocalizedStringKey = ""
    
    var id: String {
        "\(text)"
    }
    
    static var premiumBenefits: [Benefit] = [
        

      //  Benefit(text:"Mark 11:23: Your convictions, voiced out loud, hold incredible power. If you truly believe and verbalize your goals or aspirations, no obstacle is too big to overcome, not even metaphorical mountains."),

       // Benefit(text: "Matthew 21:22: Faith in what you pray for is crucial. When you ask for something, believe in its possibility with conviction, and your prayers can manifest into reality."),

      //  Benefit(text: "James 3:4-5: Like a small rudder steering a large ship, your words, though seemingly insignificant, can define your life's trajectory. They can set you on a path to success or failure."),
      //  Benefit(text: "Dive deeper into your relationship with Jesus, our goal is to support you in cultivating a vibrant, growing relationship with Christ, every single day. Join us and embrace a life transformed by His word."),

       // Benefit(text: "Romans 4:17: This speaks to the power of belief and speaking things into existence. Just as God brought forth creation from nothingness, your faith and words have the potential to bring about change and create new realities.")
                Benefit(text: "Bible Affirmations for all of life's journey", subText: "Experience true peace"),
                Benefit(text: "Daily Devotional's", subText: "Spend time with Jesus"),
                Benefit(text: "Unlock all categories", subText: "Over 30+ for life situations"),
                Benefit(text: "Create your own", subText: "Fulfill your destiny"),
                Benefit(text: "Unlimited reminders", subText: "Renew your mind"),
                Benefit(text: "Unlimited themes", subText: "Regularly added backgrounds and music")
        
    ]
    
    static var discountBenefits: [Benefit] = [
        
        Benefit(text: "Unlock all features"),
        Benefit(text: "Enjoy 50% off discount"),
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
    var currentSelection = InAppId.Subscription.speakLife1YR15
    var percentOffText: String = "70% Off - $0.04 cents a day"
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
   // @State private var timeRemaining: Int = 0
   
    
    init(size: CGSize, currentSelection: InAppId.Subscription = .speakLife1YR15) {
        self.size = size
        self.currentSelection = currentSelection
    }
    
    init(size: CGSize, currentSelection: InAppId.Subscription = .speakLife1YR15, callback: (() -> Void)?) {
        self.size = size
        self.currentSelection = currentSelection
        self.callback = callback
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(subscriptionImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 1.2)
                    .edgesIgnoringSafeArea(.top)
                    .overlay(
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                    )
            }
            
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
    }
    
    func discountView(completion: @escaping(() -> Void)) -> some View {
        VStack {
            discountLabel
            Spacer()
                .frame(height: 16)
            
            
            Spacer()
                .frame(height: 32)
            
            
            HStack {
                Text(percentOffText)
                    .textCase(.uppercase)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                ZStack {
                    Capsule()
                        .fill(Constants.gold)
                        .frame(width: 100, height: 30)
                    Text("Premium").textCase(.uppercase)
                        .font(.subheadline)
                }
            }
 
            Spacer()
                .frame(height:  UIScreen.main.bounds.height * 0.03)
            
            Text("Unlock exclusive savings on our premium content! Take advantage of our special offers and enjoy top-quality features at a fraction of the price. Limited-time discounts available—don’t miss out!")
                .font(.body)
                .foregroundStyle(.white)
                .padding([.leading, .trailing, .top])

            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.20)
            
            Text("\(currentSelection.title) Cancel anytime")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
                .frame(height: 16)
            
            continueButton {
                completion()
            }.padding([.leading, .trailing])
        }
    }
    
    var discountLabel: some View {
        VStack {
            if appState.offerDiscount && !subscriptionStore.isPremium {
                Text("Special gift for you \(appState.userName)!")
                    .font(.title)
                Text("\(timeString(from: appState.timeRemainingForDiscount)) left")
                    .font(.body)
            }
        }.foregroundColor(.white)
    }
    
    
    
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
        impactMed.impactOccurred()
        Task {
            declarationStore.isPurchasing = true
            await buy()
            declarationStore.isPurchasing = false
        }
    }
    
    
    func continueButton(completion: @escaping(() -> Void)) -> some View {
       // ShimmerButton(buttonTitle: currentSelection == firstSelection ? "Try Free & Subscribe" : "Subscribe", action: makePurchase)
        return ShimmerButton(colors: [Constants.DAMidBlue, Constants.gold], buttonTitle: "Continue", action: makePurchase)
    }
}

struct SubscriptionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State private var currentTestimonialIndex: Int = 0
   // let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
  
   
    @State private var textOpacity: Double = 0
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, .cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom)// Adjust time as needed
    
    @State var currentSelection: InAppId.Subscription? = InAppId.Subscription.speakLife1YR29
    @State var firstSelection = InAppId.Subscription.speakLife1YR29
    @State private var localizedPrice: String = "$19.00"
    @State private var regionCode: String = "US"
    @State private var isCheaperPricingCountry = false
    
    var secondSelection = InAppId.Subscription.speakLifeLifetime
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    let size: CGSize
    var callback: (() -> Void)?
    let benefits: [Benefit]
    var isDiscount = false
    
    var ctaText: String? {
        "7 days free, then"

    }
    
    init(benefits: [Benefit] = Benefit.premiumBenefits, size: CGSize, ctaText: String = "3 days free, then", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
        self.benefits = benefits
        self.size = size
       // self.ctaText = ctaText
        self.isDiscount = isDiscount
    }
    
    var body: some View {
        goPremiumView(size: size)
            .foregroundColor(.white)
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
            })
            .onAppear() {
              //  localizePrice()
            }
    }
    
    private var benefitRows: some View {
        ForEach(benefits)  { benefit in
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    .scaledToFit()
                VStack(alignment: .leading) {
                    Text(benefit.text, comment: "Benefit text")
                        .font(.body)
                    Text(benefit.subText, comment: "Benefit subtext")
                        .font(.caption)
                }
                   // .minimumScaleFactor(0.5)
                Spacer()
            }.padding(.horizontal)
        }
    }
    
    private func goPremiumView(size: CGSize) -> some View  {
        ZStack {
          
            GeometryReader { geometry in
                Image(subscriptionImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 1.2)
                    .edgesIgnoringSafeArea([.top])
                    .overlay(
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .edgesIgnoringSafeArea(.all)
                    )
           
            ScrollView {
               
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Spacer()
                        .frame(height: 60)
                    VStack(alignment: .center) {
                        Text("Speak Life and Walk in Victory ✝️", comment: "unlock everything premium view")
                            .multilineTextAlignment(.center)
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding([.leading, .trailing])
                        
                    }
                    Spacer()
                        .frame(height: 24)
                    
                    HStack {
                        StarRatingView(rating: 4.8)
                    }.padding([.leading,.trailing],20)
                    
                    FeatureView()
                    
                        .foregroundColor(.white)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("Over 40K+ happy users 🥳")
                        .font(Font.custom("AppleSDGothicNeo-Bold", size: 25, relativeTo: .title))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    
                    VStack {
                        
                        Button {
                            currentSelection = firstSelection
                        } label: {
                            yearlyCTABox()
                        }
                        
                        if !isCheaperPricingCountry {
                            Button {
                                currentSelection = secondSelection
                            } label: {
                                monthlySelectionBox()
                            }
                            
                        }
                    }
                    
                    goPremiumStack()
                    
                    Spacer()
                        .frame(height: 16)
                    
                    costDescription
                    
                    
                    ForEach(testimonials) { testimonial in
                        TestimonialView(testimonial: testimonial, size: size)
                    }

                    Spacer().frame(height: 100)
                    
                }
                .padding(.bottom, 80)
               
                }

           
                VStack {
                    Spacer()
                    ZStack {
                        Image(onboardingBGImage)
                            .resizable()
                            .frame(width: size.width, height: 80)
                            .overlay(
                                Rectangle()
                                    .fill(Color.black.opacity(0.2))
                                    .edgesIgnoringSafeArea(.all)
                            )
                        continueButton(gradient: linearGradient)
                            .padding(.horizontal, 40)
                            
                    }
                   
                }
                  
               
            }
           
            if declarationStore.isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }
        }
        
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    var costDescription: some View {
            VStack(spacing: 4) {
                if currentSelection == firstSelection {
                    Text(ctaText ?? "")
                }
                
                Text(currentSelection?.title ?? "" + ".")
                
                if currentSelection == firstSelection ||  currentSelection == secondSelection {
                    Text("Cancel anytime.")
                        .font(Font.custom("Roboto-Regular", size: 14, relativeTo: .callout))
                        .foregroundColor(.gray)
                }
                
            }
            .font(Font.custom("Roboto-Regular", size: 14, relativeTo: .callout))
        .foregroundColor(.white)
    }
    
    
    private func goPremiumStack() -> some View  {
        return VStack {
        
           
    
            Spacer()
            .frame(height: 8)
            
            HStack {
                Button(action: restore) {
                    Text("Restore", comment: "restore iap")
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }
                
                    Spacer()
                    .frame(width: 16)
                
                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Text("Terms & Conditions")
                        .font(.caption2)
                        .foregroundColor(Color.blue)
                }

            }
        }
        .padding([.leading, .trailing], 20)
    }
    
    func buy() async {
        do {
            guard let currentSelection = currentSelection else { return }
            if let _ = try await subscriptionStore.purchaseWithID([currentSelection.rawValue]) {
                Analytics.logEvent(currentSelection.rawValue, parameters: nil)
                callback?()
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(currentSelection?.rawValue): \(error)")
        }
    }
    
    private func makePurchase() {
        impactMed.impactOccurred()
        Task {
            
            declarationStore.isPurchasing = true
            await buy()
            declarationStore.isPurchasing = false
        }
    }
    
    private func continueButton(gradient: LinearGradient) -> some View {
        ShimmerButton(colors: [Constants.DAMidBlue, .cyan], buttonTitle: currentSelection == firstSelection ? "Start My 7-Day Free Trial" : "Subscribe" , action: makePurchase)
    }
   // currentSelection == firstSelection ? "Try Free & Subscribe" : "Subscribe"
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
        ZStack() {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == firstSelection ? Constants.DAMidBlue : .clear))
                .frame(height: 60)
            
            HStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Constants.traditionalGold)
                        .frame(width: 110, height: 30)
                    
                    Text("7-Day free trial")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                }
              //  .padding(.trailing)
                .offset(x: -10, y: -32)
            }
            
            if isCheaperPricingCountry {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(firstSelection.ctaDurationTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        Text(" \(localizedPrice)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                            .bold()
                        
                    }
                    Spacer()
                    
                }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
                
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(firstSelection.ctaDurationTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        Text(firstSelection.markDownValue)
                            .strikethrough(true, color: .white)
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 14)) +
                        Text(" \(firstSelection.ctaPriceTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                            .bold()
                        
                    }
                    Spacer()
                    Text(firstSelection.subTitle)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        .bold()
                    
                }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
            }
            
        }
        
        .padding([.leading, .trailing], 20)
    }

    
    func monthlySelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == secondSelection ? Constants.DAMidBlue : .clear))
                .frame(height: 40)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(secondSelection.ctaDurationTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        Spacer()
                        Text("\(secondSelection.subTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                            .bold()
                    }
                }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
                
            }
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    func localizePrice() {
           // Assume you have a function that returns the user's country code
           let countryCode = getUserCountryCode()
            regionCode = countryCode

           switch countryCode {
           case "GH":
               isCheaperPricingCountry = true
               localizedPrice = "$14.99"
           case "KE":
               isCheaperPricingCountry = true
               localizedPrice = "$14.99"
           case "UG":
               isCheaperPricingCountry = true
               localizedPrice = "$14.99"
           case "TH":
               isCheaperPricingCountry = true
               localizedPrice = "฿249.00"
           case "NG":
               isCheaperPricingCountry = true
               localizedPrice = "₦3,900"
           case "PH":
               isCheaperPricingCountry = true
               localizedPrice = "₱499.00"
           case "ZA":
               isCheaperPricingCountry = true
               localizedPrice = "R199.99"
           default:
               isCheaperPricingCountry = false
               localizedPrice = "$19.00"
           }
       }

       func getUserCountryCode() -> String {
           // Example function to get user’s country code
           // You could use Locale, or get this information from the user's account settings
           return Locale.current.region?.identifier ?? "US"
       }
    
}


struct StarRatingView: View {
    @EnvironmentObject var appState: AppState
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
           return Constants.gold
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

struct TestimonialView: View {
    var testimonial: Testimonial
    @Namespace private var animationNamespace
    let size: CGSize
    
    @State private var currentTextOpacity: Double = 1.0
    @State private var textKey: UUID = UUID()

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("🌟 Testimonial's 🌟")
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .headline))
                .padding(.top)
                .frame(maxWidth: .infinity)
            
            TestimonialTextView(text: testimonial.text)
                .id(textKey)
                .frame(height: 110)
                .matchedGeometryEffect(id: "text", in: animationNamespace)
            
//            Text("- \(testimonial.author), \(testimonial.details)")
//                .font(.footnote)
//                .opacity(currentTextOpacity)
//                .frame(maxWidth: .infinity, alignment: .trailing) // Right-align author details
//                .padding([.horizontal, .bottom])
//                .matchedGeometryEffect(id: "author", in: animationNamespace)
//                .transition(.opacity)
        }
        .foregroundColor(.white)
        .padding()
        .frame(width: size.width * 0.90, height: size.height * 0.2)
        .background(Constants.DAMidBlue.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding()
        .onChange(of: testimonial.text) { _ in
            textKey = UUID()
        }
    }
}

struct TestimonialTextView: View {
    var text: String
    
    var body: some View {
        Text("\"\(text)\"")
            .font(.custom("AppleSDGothicNeo-Regular", size: 16))
            //.font(.body)
            .fontWeight(.light)
            .italic()
            .padding()
            .transition(.opacity) // Apply a fade transition
            .animation(.easeInOut(duration: 3.0), value: text) // Animate the opacity transition
    }
}

struct Testimonial: Identifiable {
    var id: Int
    var text: String
    var author: String
    var details: String
}
