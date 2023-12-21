//
//  DevotionalView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import SwiftUI
import FirebaseAnalytics

struct DevotionalView: View {
    
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: DevotionalViewModel
    @State private var scrollToTop = false
    @State private var share = false
    
    let spacing: CGFloat = 20
    
    var body: some View {
        contentView
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.presentationMode.wrappedValue.dismiss()
            }
        
    }
    
    @ViewBuilder
    var contentView: some  View {
        if subscriptionStore.isPremium {
            devotionalView
                .onAppear {
                    Analytics.logEvent(Event.devotionalTapped, parameters: nil)
                    Task {
                        await viewModel.fetchDevotional()
                    }
                }
                .alert(isPresented: $viewModel.hasError) {
                    Alert(title: Text(viewModel.errorString))
                }
        } else {
                SubscriptionView(size: UIScreen.main.bounds.size)
        }
    }
    
    var devotionalView: some View {
        ZStack {
            Gradients().purple
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        
                        Spacer()
                            .frame(height: spacing)
                        dateLabel
                        
                        titleLabel
                        
                        bookLabel
                        
                        devotionText
                        
                        navigateDevotionalStack
                        
                    }
                    .id("titleID")
                    .padding(.horizontal, 24)
                    .foregroundColor(.black)
                    
                    .sheet(isPresented: $share) {
                        ShareSheet(activityItems: [viewModel.devotionalText as String,  URL(string: "\(APP.Product.urlID)")! as URL])
                    }
                }
                .onChange(of: scrollToTop) { value in
                    if value {
                        scrollView.scrollTo("titleID", anchor: .top)
                        scrollToTop = false
                    }
                }
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.share = false
        }
    }
    
    @ViewBuilder
    var dateLabel: some View {
        HStack {
            Spacer()
            Text(viewModel.devotionalDate)
                .font(.caption)
                .fontWeight(.bold)
        }
        Spacer()
            .frame(height: spacing)
    }
    
    @ViewBuilder
    var titleLabel: some View {
        Text(viewModel.title)
            .font(.custom("AppleSDGothicNeo-Regular", size: 22))
            .fontWeight(.medium)
        
        Spacer()
            .frame(height: 16)
    }
    
    @ViewBuilder
    var bookLabel: some View {
        Text(viewModel.devotionalBooks)
            .font(.custom("AppleSDGothicNeo-Regular", size: 16))
            .italic()
        
        Spacer()
            .frame(height: spacing)
    }
    
    @ViewBuilder
    var devotionText: some View {
        Text(viewModel.devotionalText)
            .font(.custom("AppleSDGothicNeo-Regular", size: 18))
            .lineSpacing(4)
        Spacer()
            .frame(height: spacing)
    }
    
    @ViewBuilder
    private var backDevotionalButton: some View {
        if viewModel.devotionValue > -10 {
            Button {
                Task {
                    viewModel.devotionValue -= 1
                    await viewModel.fetchDevotionalFor(value: viewModel.devotionValue)
                    withAnimation {
                        scrollToTop = true
                    }
                }
            } label: {
                Image(systemName: "arrow.backward.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    @ViewBuilder
    private var forwardDevotionalButton: some View {
        if viewModel.devotionValue < 1 {
            Button {
                Task {
                    viewModel.devotionValue += 1
                    await viewModel.fetchDevotionalFor(value: viewModel.devotionValue)
                    withAnimation {
                        scrollToTop = true
                    }
                }
            } label: {
                Image(systemName: "arrow.forward.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    private var shareButton: some View {
        Button {
            share.toggle()
            Analytics.logEvent(Event.devotionalShared, parameters: nil)
        } label: {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .frame(width: 25)
        }
    }
    
    var navigateDevotionalStack: some View {
        HStack {
            backDevotionalButton
            
            Spacer()
                .frame(width: 25)
            
            forwardDevotionalButton
            
            Spacer()
                .frame(width: 25)
            
            shareButton
            
        }
        .foregroundColor(.white)
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
            }
        }
    }
    
}