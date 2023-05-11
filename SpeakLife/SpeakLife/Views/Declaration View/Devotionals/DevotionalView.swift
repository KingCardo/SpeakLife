//
//  DevotionalView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import SwiftUI

struct DevotionalView: View {
    
    @StateObject var viewModel: DevotionalViewModel
    
    var body: some View {
        
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
                    Text(viewModel.devotionalText)
                        .font(.body)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                    Spacer()
                        .frame(height: 20)
                    Text(viewModel.devotionalBooks)
                        .font(.callout)
                        .italic()
            
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
