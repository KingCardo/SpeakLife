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
    
    var body: some View {
        if subscriptionStore.isPremium || !viewModel.devotionalLimitReached {
            devotionalView
                .onAppear {
                    Task {
                        await viewModel.fetchDevotional()
                        viewModel.setDevotionalDictionary()
                    }
                }
        } else {
            VStack {
                Text("It seems like you've used up your free access limit for Devotionals. To continue using our services uninterrupted, please subscribe to our premium plan.")
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
                        .frame(height: 20)
                    Text(viewModel.devotionalDate)
                        .font(.caption)
                    Spacer()
                        .frame(height: 20)
                    
                    Text(viewModel.title)
                        .font(.title)
                        .italic()
                    Spacer()
                        .frame(height: 10)
                    Text(viewModel.devotionalBooks)
                        .font(.callout)
                        .italic()
                        .padding([.leading, .trailing])
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Text(viewModel.devotionalText)
                        .font(.body)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                    
                    
                }
                .foregroundColor(.black)
            }
            
        }
    }
}

