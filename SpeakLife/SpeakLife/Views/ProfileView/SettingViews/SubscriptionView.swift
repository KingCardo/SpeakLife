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

import SwiftUI

// ViewModel to manage data for the view
class OfferViewModel: ObservableObject {
    @Published var originalPrice: String = "$39.99/year"
    @Published var monthlyPrice: String = "$3.33/month"
    @Published var discountedPrice: String = "$19.99/year"
    @Published var discountedMonthlyPrice: String = "$1.67/month"
}

struct OfferPageView: View {
    @ObservedObject var viewModel = OfferViewModel()
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    let callBack: (() -> Void)
    
    @State var firstSelection = InAppId.Subscription.speakLife1YR19
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                    Image("gift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding(.top, 30)
                        .shadow(color: Color.purple.opacity(0.5), radius: 20, x: 10, y: 10)
                        .cornerRadius(6)
                
                Text("Enjoy a special gift")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .caption))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .leading, endPoint: .trailing))
                    )
                VStack {
                    Text("50% off")
                        .font(Font.custom("AppleSDGothicNeo-Bold", size: 48, relativeTo: .title))
                        .foregroundColor(.white)
                    
                    Text("SpeakLife Premium")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 30, relativeTo: .title))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 10) {
                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.gray, lineWidth: 1)
                            .frame(height: 90)
                            .overlay(
                                VStack(spacing: 4) {
                                    Text("Original price")
                                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                                        .foregroundColor(.gray)
                                    Text(viewModel.originalPrice)
                                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                                        .strikethrough()
                                        .foregroundColor(.gray)
                                    Text(viewModel.monthlyPrice)
                                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14, relativeTo: .body))
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 90)
                            .overlay(
                                VStack(spacing: 4) {
                                    Text("Your price now")
                                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 18, relativeTo: .body))
                                        .foregroundColor(.white)
                                    Text(viewModel.discountedPrice)
                                        .font(Font.custom("AppleSDGothicNeo-Bold", size: 20, relativeTo: .body))
                                        .foregroundColor(.white)
                                    Text(viewModel.discountedMonthlyPrice)
                                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 14, relativeTo: .body))
                                        .foregroundColor(.white)
                                }
                            )
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Claim button
                Button(action: {
                    makePurchase(iap: firstSelection)
                }) {
                    Text("Claim offer now")
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                
                Button(action: {
                    callBack()
                }) {
                    Text("Maybe later")
                        .font(Font.custom("AppleSDGothicNeo-Bold", size: 18, relativeTo: .body))
                        .padding()
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding()
            .background(Gradients().cyanBlue)//Constants.DAMidBlue.opacity(0.8))
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
            })
            
            if declarationStore.isPurchasing {
                RotatingLoadingImageView()
            }
        }
    }
    
    func buy(_ iap: InAppId.Subscription) async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([iap.rawValue]) {
                Analytics.logEvent(iap.rawValue, parameters: nil)
                callBack()
            }
        } catch StoreError.failedVerification {
            print("error RWRW")
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(iap.rawValue): \(error)")
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    private func makePurchase(iap: InAppId.Subscription) {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy(iap)
            withAnimation {
                declarationStore.isPurchasing = false
            }
        }
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
    
    
    @State private var textOpacity: Double = 0
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, .cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom)// Adjust time as needed
    
    @State var currentSelection: InAppId.Subscription? = InAppId.Subscription.speakLife1YR39
    @State var firstSelection = InAppId.Subscription.speakLife1YR39
    @State private var localizedPrice: String = "$19.00"
    @State private var regionCode: String = "US"
    @State private var isCheaperPricingCountry = false
    @State var chooseDifferentAmount = false
    
    var secondSelection = InAppId.Subscription.speakLife1MO4
    
    var thirdSelection = InAppId.Subscription.speakLifeLifetime
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    let valueProps: [Feature]
    let size: CGSize
    var callback: (() -> Void)?
    var isDiscount = false
    
    var ctaText: String? {
        "3 days free, then"
        
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
                //ScrollView {
                LinearGradient(gradient: Gradient(colors: [Constants.DAMidBlue, Color.black]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                        Spacer()
                            .frame(height: 24)
                        VStack(alignment: .center) {
                            
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .offset(x: 0, y: 0)
                                .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
                            
                            Text("SpeakLife")
                                .font(.system(size: 34, weight: .semibold, design: .rounded))
                                .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
                            
                            
                        }
                        Spacer()
                            .frame(height: 24)
                        VStack {
                            Text("Your first week's on us 🥳")
                                .font(Font.custom("AppleSDGothicNeo-Bold", size: 30, relativeTo: .title))
                                .foregroundStyle(Color.white)
                            StarRatingView(rating: 4.8)
                            
                        }
                        Spacer()
                            .frame(height: 24)
                        
                        
                        FeatureView(defaultProps: valueProps)
                            .foregroundColor(.white)
                        
    
                        VStack {
                            
                            
                            Button {
                                currentSelection = firstSelection
                            } label: {
                                yearlyCTABox()
                            }
                            Spacer()
                                .frame(height: 8)
                            Button {
                                currentSelection = secondSelection
                            } label: {
                                monthlySelectionBox()
                            }
                            
//                            Button {
//                                currentSelection = thirdSelection
//                            } label: {
//                                lifetimeSelectionBox()
//                            }
                            
                        }
                        Spacer()
                        
                       //  subscriptionStack
                        
                        goPremiumStack()
                        
                        
                    }
                }
                
                
                if declarationStore.isPurchasing {
                    RotatingLoadingImageView()
                }
            }
         //   }
        .sheet(isPresented: $chooseDifferentAmount) {
            patronView
        }
    }
    
    @ViewBuilder
    private var patronView: some View {
        GeometryReader { reader in
            ZStack {
                // Main content
                VStack {
                    IntroTipScene(
                        title: "Pay What Feels Right",
                        bodyText: "",
                        subtext: "Please support our mission of delivering Jesus, daily peace, love, and transformation to a world in need. Unlocks all features.",
                        ctaText: "Continue",
                        showTestimonials: false,
                        isScholarship: true,
                        size: reader.size,
                        callBack: {},
                        buyCallBack: { subscription in
                            makePurchase(iap: subscription)
                        }
                    )
                }
                
                // ProgressView centered in the middle
                if declarationStore.isPurchasing {
                    RotatingLoadingImageView()
                }
            }
        }
    }
    
    var subscriptionStack: some View {
        VStack {
            
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

            Text(currentSelection?.title ?? "" + ".")
            
        }
        .font(Font.custom("Roboto-Regular", size: 12, relativeTo: .callout))
        .foregroundColor(.white)
    }
    
    
    private func goPremiumStack() -> some View  {
        return VStack {
            continueButton(gradient:  LinearGradient(gradient: Gradient(colors: [.cyan, .black]), startPoint: .top, endPoint: .bottom))
                .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 6)
            Spacer()
                .frame(height: 10)
            costDescription
            Spacer()
                .frame(height: 8)
            
            
            HStack {
                Button(action: restore) {
                    Text("Restore", comment: "restore iap")
                        .font(.caption)
                        .underline()
                        .foregroundColor(Color.blue)
                }
                
                Spacer()
                    .frame(width: 16)
                
                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Text("Terms & Conditions")
                        .font(.caption)
                        .underline()
                        .foregroundColor(Color.blue)
                }
                if appState.isOnboarded {
                    Spacer()
                        .frame(width: 16)
                    Button(action: presentDifferentAmount) {
                        Text("Other", comment: "different iap")
                            .font(.caption2)
                            .foregroundColor(Color.blue)
                    }
                }
            }
        }
        .padding([.leading, .trailing], 20)
    }
    
    func presentDifferentAmount() {
        chooseDifferentAmount.toggle()
    }
    
    func buy() async {
        do {
            guard let currentSelection = currentSelection else { return }
            if let transaction = try await subscriptionStore.purchaseWithID([currentSelection.rawValue]) {
                print(currentSelection, transaction.id, transaction.jsonRepresentation, transaction.productType, "RWRW")
                Analytics.logEvent(currentSelection.rawValue, parameters: nil)
                callback?()
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    private func makePurchase() {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy()
            withAnimation {
                declarationStore.isPurchasing = false
            }
        }
    }
    
    func buy(_ iap: InAppId.Subscription) async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([iap.rawValue]) {
                Analytics.logEvent(iap.rawValue, parameters: nil)
                callback?()
            }
        } catch StoreError.failedVerification {
            print("error RWRW")
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(iap.rawValue): \(error)")
            errorTitle = error.localizedDescription
            isShowingError = true
        }
    }
    
    private func makePurchase(iap: InAppId.Subscription) {
        impactMed.impactOccurred()
        Task {
            withAnimation {
                declarationStore.isPurchasing = true
            }
            await buy(iap)
            withAnimation {
                declarationStore.isPurchasing = false
            }
        }
    }
    
    private func continueButton(gradient: LinearGradient) -> some View {
        ShimmerButton(colors: [Constants.DAMidBlue, .cyan,Constants.DADarkBlue.opacity(0.6) ], buttonTitle: currentSelection == firstSelection ? "TRY FOR FREE" : "SUBSCRIBE" , action: makePurchase)
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
                .shadow(color: currentSelection == firstSelection ? Color.white.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 60)
            
            HStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Constants.traditionalGold)
                        .frame(width: 90, height: 30)
                        .cornerRadius(15)
                    
                    Text("Best Value")
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
                            .bold()
                        Text(" \(localizedPrice)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 14))
                            
                        
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
                            .bold()
                        Text("\(firstSelection.subTitle)")
                            .font(Font.custom("AppleSDGothicNeo-Regular", size: 14))
                        
                    }
                    Spacer()
//                    Text(firstSelection.subTitle)
//                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
//                        .bold()
                    
                }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
            }
            
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    func lifetimeSelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == thirdSelection ? Constants.DAMidBlue : .clear))
                .shadow(color: currentSelection == thirdSelection ? Color.white.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 50)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(thirdSelection.ctaDurationTitle)")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        .bold()
                       
                }
                       Spacer()
                }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
                
        }
        
        .padding([.leading, .trailing], 20)
    }
    
    
    func monthlySelectionBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(currentSelection == secondSelection ? Constants.DAMidBlue : .clear))
                .shadow(color: currentSelection == secondSelection ? Color.white.opacity(0.6) : .clear, radius: 4, x: 0, y: 2)
                .frame(height: 50)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(secondSelection.ctaDurationTitle)")
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16))
                        .bold()
                       
                }
                       Spacer()
                }
                .foregroundStyle(.white)
                .padding([.leading, .trailing])
                
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
                        .opacity(self.starAnimations[index] ? 0.7 : 1.0)
                        .scaleEffect(self.starAnimations[index] ? 1.2 : 1.0)
                        .onAppear {
                            self.animateStar(at: index)
                        }
                }
            }
            Spacer()
                .frame(height: 2)
            Text(String(format: "%.1f stars", rating))
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


struct RotatingLoadingImageView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background or other views here, if needed
            
            // Circular Image with rotation animation
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage()) // Replace this with your image
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150) // Set your desired size
                .clipShape(Circle())
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.8 : 1.0) // Opacity transition
                .shadow(color: isAnimating ? Color.blue.opacity(0.7) : Color.purple.opacity(0.7), radius: 20, x: 0, y: 0) // Change the scale
                .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true // Start the animation when the view appears
                }
        }
        .padding()
    }
}

struct RotatingLoadingImageView_Previews: PreviewProvider {
    static var previews: some View {
        RotatingLoadingImageView() // Display a live preview of ContentView in Xcode
    }
}
