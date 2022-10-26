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
    
    @AppStorage("review.counter") private var reviewCounter = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State private var showAlert = false
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
            requestReview()
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
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView, result: self.$result)
        }
    }
    
    
    
    private func requestReview() {
        #if !DEBUG
          if reviewCounter > 2 {
              showAlert = true
              reviewCounter = 0
  
          }
        #endif
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

