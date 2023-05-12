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
        if !subscriptionStore.isPremium {
            SubscriptionView(size: UIScreen.main.bounds.size)
        } else {
            ZStack {
                Gradients().random
                ScrollView {
                    VStack {
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
            .onAppear {
                Task {
                    await viewModel.fetchDevotional()
                }
                
            }
        }
    }
}
