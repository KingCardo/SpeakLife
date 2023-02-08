//
//  DeclarationView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import SwiftUI
import MessageUI
import StoreKit

struct DeclarationView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var viewModel: DeclarationViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    
    @AppStorage("review.counter") private var reviewCounter = 0
    @AppStorage("share.counter") private var shareCounter = 0
    @AppStorage("review.done") private var reviewDone = false
    @AppStorage("shared.count") private var shared = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State private var showAlert = false
    @State private var share = false
    @State var isShowingMailView = false
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                DeclarationContentView(themeViewModel: themeViewModel, viewModel: viewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack() {
                    
                    ProfileBarButton()
                        .frame(height: geometry.size.height * 0.10)
                    
                    Spacer()
                    
                    IntentsBarView(viewModel: viewModel, themeViewModel: themeViewModel)
                        .frame(height: geometry.size.height * 0.10)
                }
                
            }
        }
        .background(Image(themeViewModel.selectedTheme.backgroundImageString)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: (themeViewModel.selectedTheme.blurEffect ? 2 : 0))
            .ignoresSafeArea())
        .alert(isPresented: $viewModel.showErrorMessage) {
            Alert(
                title: Text("Error", comment: "Error title message"),
                message: Text("OK", comment: "OK alert message")
            )
        }
        .onAppear {
            reviewCounter += 1
            shareCounter += 1
            requestReview()
            shareApp()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you enjoying SpeakLife?", comment: "review alert title"),
                primaryButton: .default(
                    Text("Yes"),
                    action: showReview
                ),
                secondaryButton: .destructive(
                    Text("No"),
                    action: sendEmail
                )
            )
        }
        .alert(isPresented: $share) {
            Alert(
                title: Text("Help us spread SpeakLife?", comment: ""),
                primaryButton: .default(
                    Text("Yes, I'll share with friends!"),
                    action: shareSpeakLife
                ),
                secondaryButton: .destructive(
                    Text("No thanks"),
                    action: { }
                )
            )
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView, result: self.$result)
        }
    }
    
    private func requestReview() {
        #if !DEBUG
          if reviewCounter > 5 && !reviewDone {
              showAlert = true
              reviewDone.toggle()
              reviewCounter = 0
          }
        #endif
      }
    
    private func shareApp() {
#if !DEBUG
        if shareCounter > 3 && !subscriptionStore.isPremium && shared < 3 {
            share = true
            shareCounter = 0
        }
#endif
    }
    
    private func shareSpeakLife()  {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene {
                let url = URL(string: "\(APP.Product.urlID)")!
                
                let activityVC = UIActivityViewController(activityItems: ["Check out SpeakLife - Daily Bible Promises app that'll transform your life!", url], applicationActivities: nil)
                let window = scene.windows.first
                window?.rootViewController?.present(activityVC, animated: true)
                shared += 1
            }
        }
    }
    
    private func showReview() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            isShowingMailView = true
        }
    }
}

