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
    
    let spacing: CGFloat = 20
    
    var body: some View {
        contentView
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.presentationMode.wrappedValue.dismiss()
            }
        
    }
    
    @ViewBuilder
    var contentView: some  View {
        if subscriptionStore.isPremium || !viewModel.devotionalLimitReached {
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
            VStack {
                Text("Oops. You've used up your free access limit for Devotionals. To continue using our services uninterrupted, please subscribe to our premium plan.")
                    .font(.callout)
                    .padding()
                SubscriptionView(size: UIScreen.main.bounds.size)
            }
        }
    }
    
    var devotionalView: some View {
        ZStack {
            Gradients().random
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        if !subscriptionStore.isPremium {
                            Text("\(viewModel.devotionalsLeft) more free devotionals left")
                                .padding()
                        }
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
                }
                .onChange(of: scrollToTop) { value in
                    if value {
                        scrollView.scrollTo("titleID", anchor: .top)
                        scrollToTop = false
                    }
                }
            }
            
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
            .font(.title2)
            .fontWeight(.medium)
        
        Spacer()
            .frame(height: 16)
    }
    
    @ViewBuilder
    var bookLabel: some View {
        Text(viewModel.devotionalBooks)
            .font(.callout)
            .italic()
        
        Spacer()
            .frame(height: spacing)
    }
    
    @ViewBuilder
    var devotionText: some View {
        Text(viewModel.devotionalText)
            .font(.body)
            .lineSpacing(4)
        Spacer()
            .frame(height: spacing)
    }
    
    var navigateDevotionalStack: some View {
        HStack {
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
            
            Spacer()
                .frame(width: 25)
            
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
        .foregroundColor(.white)
    }
    
}

