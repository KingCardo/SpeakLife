//
//  IntroScene.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 3/29/22.
//

import SwiftUI

struct IntroTipScene: View {
    
    @EnvironmentObject var viewModel: DeclarationViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @State private var currentTestimonialIndex: Int = 0
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    @State private var showTitle = false
    @State private var showBodyText = false
    @State private var showSubtext = false
    @State private var buttonTapped = false
    
    let title: String
    let bodyText: String
    let subtext: String
    let ctaText: String
    let showTestimonials: Bool
    let isScholarship: Bool
   // var imageName: String
    
    let size: CGSize
    let callBack: (() -> Void)?
    var buyCallBack: ((InAppId.Subscription) -> Void)?
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    @State private var selectedOption = InAppId.Subscription.speakLife1YR29
    
    var body: some  View {
        introTipScene(size: size)
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK")))
            })
    }
    
   
    
    private func introTipScene(size: CGSize) -> some View  {
        VStack {
            Spacer().frame(height: 30)
        
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Text(title)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                    .padding([.leading, .trailing], 4)
                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 2)
//                    .opacity(showTitle ? 1 : 0) // Initial opacity for fade-in
//                    .onAppear {
//                        withAnimation(Animation.easeIn(duration: 0.3).delay(0.2)) {
//                            showTitle = true
//                        }
                //    }
                
                Spacer().frame(height: appState.onBoardingTest ? size.height * 0.04 : 24)
                
                VStack {
                    Text(bodyText)
                       // .font(.body)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 22, relativeTo: .body))
                        .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(12)
                        .lineLimit(nil)
//                        .opacity(showBodyText ? 1 : 0) // Initial opacity for fade-in
//                        .onAppear {
//                            withAnimation(Animation.easeIn(duration: 2.0).delay(0.6)) {
//                                showBodyText = true
//                            }
//                        }
                    
                    Spacer().frame(height: appState.onBoardingTest ? size.height * 0.04 : 24)
                    
            
                    Text(subtext)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 22, relativeTo: .callout))
                        .foregroundColor(appState.onBoardingTest ? .white : Color(red: 119/255, green: 142/255, blue: 180/255))
                       // .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                      //  .foregroundColor(Color(red: 119, green: 142, blue: 180, opacity: 1))
                        .lineLimit(nil)
                        .opacity(showSubtext ? 1 : 0) // Initial opacity for fade-in
                        .onAppear {
                            withAnimation(Animation.easeIn(duration: 3.0).delay(1.0)) {
                                showSubtext = true
                            }
                        }
                }
                .frame(width: size.width * 0.9)
                if isScholarship {
                    Spacer().frame(height: size.height * 0.05)
                    VStack {
                        Text("Select an option")
                            .foregroundStyle(Color.white)
                            .font(.headline)
                        // .padding()
                    }
                    Picker("subscriptionScholarship", selection: $selectedOption) {
                        ForEach(InAppId.allInApp) { subscription in
                            Text(subscription.scholarshipTitle)
                                .tag(subscription)
                                .foregroundStyle(Color.white)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 150)
                }
                
            }
            
            Spacer()
            ShimmerButton(colors: [Constants.DAMidBlue, .yellow], buttonTitle: ctaText, action: buttonTouched)
            .frame(width: size.width * 0.87 ,height: 60)
            .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
            
            .foregroundColor(.white)
            .cornerRadius(30)
            .shadow(color: Constants.DAMidBlue.opacity(0.5), radius: 8, x: 0, y: 10)
            .scaleEffect(buttonTapped ? 0.95 : 1.0)

            
            Spacer()
                .frame(width: 5, height: size.height * 0.07)
        }
        .frame(width: size.width, height: size.height)
        .background(
            ZStack {
                Image(appState.onBoardingTest ? onboardingBGImage : "declarationBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .brightness(0.05)
                Color.black.opacity(0.05)
                    .edgesIgnoringSafeArea(.all)
            }
        )
    }
    
    func buttonTouched() {
        buttonTapped = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
            buttonTapped = false
        }
        if isScholarship {
        buyCallBack?(selectedOption)
        } else {
            callBack?()
        }
    }
}

let testimonials: [Testimonial] = [
    Testimonial(id: 1, text: "This app has transformed my daily routine, bringing peace and inspiration to every day.", author: "Alex J.", details: "UK"),
    Testimonial(id: 2, text: "A truly uplifting experience every time I use this app. Highly recommended for anyone seeking daily motivation.", author: "Caleb W.", details: "USA"),
    Testimonial(id: 3, text: "I really love this app and have been sharing it with my friends and family! I bought the subscription and am pleased with it. Great job!", author: "Samantha F.", details: "USA"),
    Testimonial(id: 4, text: "Powerful affirmations. Loving it!! Everyone should give it a try", author: "Rahul P.", details: "India"),
    Testimonial(id: 7, text: "I love the awesome backgrounds, the categories you can pick to suit, God uses all things for the good of those that love Him and are Called.", author: "Emily C.", details: "United Kingdom"),
    Testimonial(id: 8, text: "I absolutely love this app because instead of scrolling on tiktok, Instagram etc. I can scroll here and learn about God even more.", author: "Maria S.", details: "Philippines")
]

struct IntroScene: View {
    
    @EnvironmentObject var appState: AppState
    let headerText: String
    let bodyText: String
    let footerText: String
    let buttonTitle: String
    
    let size: CGSize
    let callBack: (() -> Void)
    
    var body: some  View {
        introSceneAlt(size: size)
    }
    
    private func introSceneAlt(size: CGSize) -> some View  {
        VStack {
            
            if appState.onBoardingTest {
                Spacer()
            } else {
                Spacer().frame(height: 90)
                
                Image("declarationsIllustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 235, height: size.height * 0.25)
            }
           
            
            Spacer().frame(height: 40)
            VStack {
                Text(headerText)
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 40, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                
                Spacer().frame(height: 16)
                
                VStack {
                    Text(bodyText)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                        .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .lineLimit(nil)
                    
                    Spacer().frame(height: appState.onBoardingTest ? size.height * 0.25 : 24)
                    
                    Text(footerText)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .title2))
                        .foregroundColor(appState.onBoardingTest ? .white :Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .foregroundColor(Color(red: 119, green: 142, blue: 180, opacity: 1))
                        .lineLimit(nil)
                }
                .frame(width: size.width * 0.8)
            }
            Spacer()
            
            Button(action: callBack) {
                HStack {
                    Text(buttonTitle)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                        .fontWeight(.medium)
                        .frame(width: size.width * 0.91 ,height: 50)
                }.padding()
            }
            .frame(width: size.width * 0.87 ,height: 50)
            .background(Constants.DAMidBlue)
            
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Constants.DAMidBlue, radius: 8, x: 0, y: 10)
            
            Spacer()
                .frame(width: 5, height: size.height * 0.07)
        }
        .frame(width: size.width, height: size.height)
        .background(
            Image(appState.onBoardingTest ? onboardingBGImage : "declarationBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
        )
        
    }
}



struct LoadingScene: View {
    
    let size: CGSize
    let callBack: (() -> Void)
    
    @State private var pulsate = false
    @State private var rotate = false
    @State private var fadeInOut = false
    
    let animationDuration = 0.8
    let maxScale: CGFloat = 1.2
    let minOpacity = 0.5
    let maxOpacity = 1.0
    let delay = Double.random(in: 3...6)
    
    var body: some View {
        ZStack {
            Gradients().purple
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Text("Preparing a personalized journey through the Word for you...")
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                    .foregroundColor(.white)
                    .opacity(fadeInOut ? minOpacity : maxOpacity)
                    .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: fadeInOut)
                    .padding()
                
                Spacer().frame(height: 90)
                
                Circle()
                    .fill(Constants.DAMidBlue.opacity(0.7))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .scaleEffect(pulsate ? maxScale : 1)
                            .opacity(fadeInOut ? minOpacity : maxOpacity)
                    )
                    .rotationEffect(.degrees(rotate ? 360 : 0))
                    .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: pulsate)
                    .animation(Animation.linear(duration: animationDuration * 2).repeatForever(autoreverses: false), value: rotate)
                    .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: fadeInOut)
                    .onAppear {
                        self.pulsate = true
                        self.rotate = true
                        self.fadeInOut = true
                    }
                
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    callBack()
                }
            }
        }
    }
}
