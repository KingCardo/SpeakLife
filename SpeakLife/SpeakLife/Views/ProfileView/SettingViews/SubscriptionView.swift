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
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    var percentOffText: String = "25% Off SpeakLife yearly"
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
                Image(onboardingBGImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 1.2)
                    .edgesIgnoringSafeArea(.top)
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
            
            Text("One Time Offer")
                .font(.largeTitle)
                .foregroundStyle(.white)
            
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
            
            Text("Romans 4:17: This speaks to the power of belief and speaking things into existence. Just as God brought forth creation from nothingness, your faith and words have the potential to bring about change and create new realities.")
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
            }
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
  
   
    @State private var textOpacity: Double = 0
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, .cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom)// Adjust time as needed
    
    @State var currentSelection: InAppId.Subscription = InAppId.Subscription.speakLife1YR19
    var firstSelection = InAppId.Subscription.speakLife1YR19
    var secondSelection = InAppId.Subscription.speakLife1MO4
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    let size: CGSize
    var callback: (() -> Void)?
    let benefits: [Benefit]
    var isDiscount = false
    
    var ctaText: String
    
    init(benefits: [Benefit] = Benefit.premiumBenefits, size: CGSize, ctaText: String = "7 days free, then", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
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
               
                Image(onboardingBGImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 1.2)
                    .edgesIgnoringSafeArea([.top])
            
           
            ScrollView {
               
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                        Spacer()
                            .frame(height: 60)
                        VStack(alignment: .center) {
                            Text("Unlock SpeakLife Premium", comment: "unlock everything premium view")
                                .font(Font.custom("AppleSDGothicNeo-Regular", size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                        }
                        Spacer()
                            .frame(height: 24)
                        
                        HStack {
                            StarRatingView(rating: 4.8)
                        }.padding([.leading,.trailing],20)
                        
                        FeatureView()
                           // .frame(width: geometry.size.width * 0.93)
                        // benefitRows
                            .foregroundColor(.white)
                    
//                        Spacer()
//                            .frame(height: 48)
                        
                        
                                            Spacer()
                                                .frame(height: 24)
                        
                        
                                            VStack {
                        
                                                Button {
                                                    currentSelection = firstSelection
                                                } label: {
                                                    yearlyCTABox()
                                                }
                        
                        
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
                    
                    
                }
            
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
            VStack(spacing: 4) {
                if currentSelection == firstSelection {
                    Text(ctaText)
                }
                
                Text(currentSelection.title + ".")
                
                Text("Cancel anytime.")
                    .font(Font.custom("Roboto-Regular", size: 14, relativeTo: .callout))
                .foregroundColor(.gray)
                
            }
            .font(Font.custom("Roboto-Regular", size: 14, relativeTo: .title))
        .foregroundColor(.white)
    }
    
    
    private func goPremiumStack(size: CGSize) -> some View  {
        let gradient = Gradient(colors: [Constants.DAMidBlue, .cyan])
        _ = LinearGradient(gradient: gradient,
                                            startPoint: .top,
                                            endPoint: .bottom)
        
        return VStack {
            HStack {
                Spacer()
                continueButton(gradient: linearGradient)
                Spacer()
            }
            
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
        impactMed.impactOccurred()
        Task {
            
            declarationStore.isPurchasing = true
            await buy()
            declarationStore.isPurchasing = false
        }
    }
    
    private func continueButton(gradient: LinearGradient) -> some View {
        ShimmerButton(colors: [Constants.DAMidBlue, .cyan], buttonTitle: currentSelection == firstSelection ? "Continue" : "Subscribe", action: makePurchase)
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
                .foregroundStyle(.white)
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
                .foregroundStyle(.white)
                .padding(.leading)
                
                Spacer()
            }
        }
        
        .padding([.leading, .trailing], 20)
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
            
            Text("- \(testimonial.author), \(testimonial.details)")
                .font(.footnote)
                .opacity(currentTextOpacity)
                .frame(maxWidth: .infinity, alignment: .trailing) // Right-align author details
                .padding([.horizontal, .bottom])
                .matchedGeometryEffect(id: "author", in: animationNamespace)
                .transition(.opacity)
        }
        .foregroundColor(.white)
        .padding()
        .frame(width: size.width * 0.90, height: 200)
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

struct Testimonial {
    var id: Int
    var text: String
    var author: String
    var details: String
}
