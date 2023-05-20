//
//  DevotionalView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import SwiftUI

struct DevotionalView: View {
    
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @StateObject var viewModel: DevotionalViewModel
    
    let spacing: CGFloat = 20
    
    var body: some View {
        if subscriptionStore.isPremium || !viewModel.devotionalLimitReached {
            devotionalView
                .onAppear {
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
            ScrollView {
                VStack {
                    if !subscriptionStore.isPremium {
                        Text("\(viewModel.devotionalsLeft) more free devotionals left")
                            .padding()
                    }
                    Spacer()
                        .frame(height: spacing)
                    dateLabel
                    Spacer()
                        .frame(height: spacing)
                    
                    titleLabel
                    Spacer()
                        .frame(height: 10)
                    bookLabel
                    
                    Spacer()
                        .frame(height: spacing)
                    
                    devotionText
                    Spacer()
                        .frame(height: spacing)
                    
                }
                .padding(.horizontal, 24)
                .foregroundColor(.black)
            }
            
        }
    }
    
    var dateLabel: some View {
        HStack {
            Spacer()
            Text(viewModel.devotionalDate)
                .font(.caption)
                .fontWeight(.bold)
        }
    }
    
    var titleLabel: some View {
        Text(viewModel.title)
            .font(.title)
            .fontWeight(.medium)
    }
    
    var bookLabel: some View {
        Text(viewModel.devotionalBooks)
            .font(.callout)
            .italic()
    }
    
    var devotionText: some View {
        Text(viewModel.devotionalText)
            .font(.body)
            .lineSpacing(4)
    }
    
}

