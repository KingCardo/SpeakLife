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

struct SubscriptionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State private var currentTestimonialIndex: Int = 0
  
   
    @State private var textOpacity: Double = 0
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, .cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom)// Adjust time as needed
    
    @State var currentSelection: InAppId.Subscription? = InAppId.Subscription.speakLife1YR29
    @State var firstSelection = InAppId.Subscription.speakLife1YR29
    @State private var localizedPrice: String = "$19.00"
    @State private var regionCode: String = "US"
    @State private var isCheaperPricingCountry = false
    
    var secondSelection = InAppId.Subscription.speakLife1MO4
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    let valueProps: [Feature]
    let size: CGSize
    var callback: (() -> Void)?
    var isDiscount = false
    
    var ctaText: String? {
        "7 days free, then"

    }
    
    init(valueProps: [Feature] = [], size: CGSize, ctaText: String = "3 days free, then", isDiscount: Bool = false, callback: (() -> Void)? = nil) {
        self.valueProps = valueProps
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
    
    
    private func goPremiumView(size: CGSize) -> some View  {
        ZStack {
          
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, Color.black]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                        Spacer()
                            .frame(height: 60)
                        VStack(alignment: .center) {
                            Text("Unlock SpeakLife for free", comment: "unlock everything premium view")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("AppleSDGothicNeo-Regular", size: 26))
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
                        
                        FeatureView(valueProps)
                            .foregroundColor(.white)
                        
    
                            Spacer()
                            Text("Over 40K+ happy users 🥳")
                                .font(Font.custom("AppleSDGothicNeo-Bold", size: 25, relativeTo: .title))
                                .foregroundStyle(Color.white)
                            
                            subscriptionStack
                            
                            goPremiumStack()
        
                        
                    }
                    
            }.padding(.bottom, 30)
           
            if declarationStore.isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }
        }
        
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var subscriptionStack: some View {
        VStack {
            Text("Start your 7-day free trial today")
                .font(Font.custom("AppleSDGothicNeo-Bold", size: 20))
                .foregroundColor(Constants.gold)
                .padding(.bottom, 4)
            
            Button {
                makePurchase()
            } label: {
                Text("Try Free & Subscribe")
                    .font(Font.custom("AppleSDGothicNeo-Bold", size: 20))
                    .foregroundColor(Constants.DAMidBlue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            
            Text(firstSelection.title)
                .font(Font.custom("AppleSDGothicNeo-Regular", size: 12, relativeTo: .callout))
                .foregroundColor(.white)
                .padding(.top, 4)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemBackground).opacity(0.2))
        .cornerRadius(10)
        .padding()
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


struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Custom shape drawing logic
        // This example creates an arc-like shape
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}
