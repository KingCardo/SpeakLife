//
//  DeclarationView.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import SwiftUI
import MessageUI
import StoreKit
import UIKit

struct DeclarationView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var viewModel: DeclarationViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("review.counter") private var reviewCounter = 0
    @AppStorage("share.counter") private var shareCounter = 0
    @AppStorage("review.try") private var reviewTry = 0
    @AppStorage("shared.count") private var shared = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State private var showAlert = false
    @State private var share = false
    @State var isShowingMailView = false
    @State var showDailyDevotion = false
    @State private var isSheetPresented = false
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                DeclarationContentView(themeViewModel: themeViewModel, viewModel: viewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                if appState.showIntentBar {
                    if !appState.showScreenshotLabel {
                        VStack() {
                            HStack {
                                //dailyDevotionButton
                                Spacer()
                                ProfileBarButton(viewModel: ProfileBarButtonViewModel())
                                    .frame(height: geometry.size.height * 0.10)
                            }
                            
                            Spacer()
                            if appState.showIntentBar {
                                IntentsBarView(viewModel: viewModel, themeViewModel: themeViewModel)
                                    .frame(height: geometry.size.height * 0.10)
                            }
                        }
                    }
                }
            }
            
            .sheet(isPresented: $showDailyDevotion) {
                DevotionalView(viewModel: DevotionalViewModel())
            }
            
        }
        .background(
            ZStack {
                
                if themeViewModel.showUserSelectedImage {
                    Image(uiImage: themeViewModel.selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } else {
                    Image(themeViewModel.selectedTheme.backgroundImageString)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                }
                
                Rectangle()
                    .fill(Color.black.opacity(themeViewModel.selectedTheme.blurEffect ? 0.5 : 0))
                    .edgesIgnoringSafeArea(.all)
                
            }
        )
        
        .alert(isPresented: $viewModel.showErrorMessage) {
            Alert(
                title: Text("Error", comment: "Error title message") +  Text(viewModel.errorMessage ?? ""),
                message: Text("Select a category", comment: "OK alert message")
            )
        }
        .onAppear {
            reviewCounter += 1
            shareCounter += 1
            requestReview()
            shareApp()
        }
        
        .alert("Are you enjoying SpeakLife?", isPresented: $showAlert) {
            Button("Leave us a 5 star review") {
                showReview()
            }
            Button("Leave feedback") {
                sendEmail()
            }
        }
        
        .alert("Help us spread SpeakLife?", isPresented: $share) {
            Button("Yes, I'll share with friends!") {
                shareSpeakLife()
            }
            Button("No thanks") {
            }
        }
        
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView, result: self.$result)
        }
    }
    
    private var dailyDevotionButton: some View {
        CapsuleImageButton(title: "book.fill") {
            showDailyDevotion = true
            Selection.shared.selectionFeedback()
        }
        
        .foregroundColor(.white)
        .padding(4)
        .background(Gradients().trio)
        .cornerRadius(40)
        .padding(.leading)
    }
    
    private func requestReview() {
        if reviewCounter > 2 && reviewTry < 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showAlert = true
                reviewCounter = 0
                reviewTry += 1
            }
        }
    }
    
    private func shareApp() {
#if !DEBUG
        if shareCounter > 5 && shared < 3 {
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
                
                let activityVC = UIActivityViewController(activityItems: ["Check out Speak Life - Bible Verses app that'll transform your life!", url], applicationActivities: nil)
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
            //            if let url = URL(string: "\(APP.Product.urlID)?action=write-review") {
            //                UIApplication.shared.open(url)
            //            }
        }
    }
    
    private func sendEmail() {
        reviewTry += 3
        if MFMailComposeViewController.canSendMail() {
            isShowingMailView = true
        }
    }
}
