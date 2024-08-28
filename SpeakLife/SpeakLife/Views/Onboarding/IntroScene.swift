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
    let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    
    let title: String
    let bodyText: String
    let subtext: String
    let ctaText: String
    let showTestimonials: Bool
    let isScholarship: Bool
    
    let size: CGSize
    let callBack: (() -> Void)?
    var buyCallBack: (() -> Void)?
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
            
            if appState.onBoardingTest {
                Spacer().frame(height: 30)
            } else {
                Spacer().frame(height: 90)
                
                Image("declarationsIllustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 235, height: size.height * 0.25)
            }
           

            VStack {
                Text(title)
                    .font(Font.custom("AppleSDGothicNeo-Regular", size: 34, relativeTo: .title))
                    .fontWeight(.semibold)
                    .foregroundColor(appState.onBoardingTest ? .white : Constants.DEABlack)
                    .padding([.leading, .trailing], 4)
                
                Spacer().frame(height: 16)
                
                VStack {
                    Text(bodyText)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 20, relativeTo: .body))
                        .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .lineLimit(nil)
                    
                    Spacer().frame(height: appState.onBoardingTest ? size.height * 0.04 : 24)
                    
            
                    Text(subtext)
                        .font(Font.custom("AppleSDGothicNeo-Regular", size: 16, relativeTo: .body))
                        .foregroundColor(appState.onBoardingTest ? .white : Constants.DALightBlue)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .foregroundColor(Color(red: 119, green: 142, blue: 180, opacity: 1))
                        .lineLimit(nil)
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
                   // .clipped()
                }
                if showTestimonials {
                   
                    TestimonialView(testimonial: testimonials[currentTestimonialIndex], size: size)
                        .id(currentTestimonialIndex)
                    Spacer().frame(height: 12)
                    Text("Over 40K+ happy users")
                        .font(Font.custom("AppleSDGothicNeo-Bold", size: 25, relativeTo: .title))
                        .foregroundStyle(Color.white)
                   
                  
                }
         
                  
    
            }
    
            Spacer().frame(height: size.height * 0.25)
            Button {
                if isScholarship {
                    makePurchase()
                } else {
                    callBack?()
                }
            } label: {
                HStack {
                    Text(ctaText)
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
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut) {
                            let nextIndex = (currentTestimonialIndex + 1) % testimonials.count
                            currentTestimonialIndex = nextIndex
                        }
                    }
        
                .onDisappear {
                    timer.upstream.connect().cancel()
                }

    }
    
    private func makePurchase() {
        impactMed.impactOccurred()
        Task {
            
            viewModel.isPurchasing = true
            await buy()
            viewModel.isPurchasing = false
        }
    }
    
    func buy() async {
        do {
            if let _ = try await subscriptionStore.purchaseWithID([selectedOption.id]) {
                callBack?()
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(selectedOption.rawValue): \(error)")
        }
    }
}

let testimonials: [Testimonial] = [
    Testimonial(id: 1, text: "This app has transformed my daily routine, bringing peace and inspiration to every day.", author: "Alex J.", details: "UK"),
    Testimonial(id: 2, text: "A truly uplifting experience every time I use this app. Highly recommended for anyone seeking daily motivation.", author: "Caleb W.", details: "USA"),
    Testimonial(id: 3, text: "I've found solace and strength in the daily affirmations. It's a part of my morning ritual now!", author: "Samantha F.", details: "USA"),
    Testimonial(id: 4, text: "I love creating my own affirmations and saying them thruout the day!", author: "Rahul P.", details: "India"),
    Testimonial(id: 5, text: "Every morning, I look forward to the daily affirmations and devotionals. They set a positive tone for my day and remind me of the strength within.", author: " Michael T.", details: "Australia"),
    Testimonial(id: 6, text: "This app has been a true companion in my spiritual journey. The personalized scriptures have helped me find answers and peace in difficult times!", author: "Khalil P.", details: "Singapore"),
    Testimonial(id: 7, text: "I never realized how impactful daily devotionals could be until I started using this app. It's like having a personal guide to navigate life's ups and downs.", author: "Emily C.", details: "United Kingdom"),
    Testimonial(id: 8, text: "Integrating this app into my daily routine has been transformative. The affirmations and prayers provide a moment of peace and reflection that enriches my whole day.", author: "Maria S.", details: "Philippines")
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
                //                    .scaleEffect(pulsate ? 1.4 : 0.9)
                //                    .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulsate)
                //                    .onAppear {
                //                        self.pulsate = true
                //                    }
                
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


