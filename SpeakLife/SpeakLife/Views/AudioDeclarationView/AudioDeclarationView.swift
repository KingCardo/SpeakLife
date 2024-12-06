//
//  AudioDeclarationView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import SwiftUI

struct UpNextCell: View {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    let item: AudioDeclaration
    
    var body: some View {
        HStack(spacing: 16) {
            // Image on the left
            Image(item.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 120)
                .cornerRadius(8)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(2)
                
                // Subtitle
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.caption)
                            Text(item.duration)
                                .font(.caption)
                            if item.isPremium, !subscriptionStore.isPremium {
                                Image(systemName: "lock")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    //}
              //  }
            }
            Spacer()
        }
        .padding()
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID() // Unique identifier
    let message: String
}

struct AudioDeclarationView: View {
    @StateObject private var viewModel = AudioDeclarationViewModel()
    @StateObject private var audioViewModel = AudioPlayerViewModel()
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @State private var selectedItem: AudioDeclaration? = nil
    @State private var audioURL: URL? = nil
    @State private var errorMessage: ErrorWrapper? = nil
    @State private var isPresentingPremiumView = false
    
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                List {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 16) {
                    Section("Declarations") {
                                ForEach(viewModel.audioDeclarations) { item in
                                    Button(action: {
                                        if item.isPremium, !subscriptionStore.isPremium {
                                            isPresentingPremiumView = true
                                        } else {
                                            viewModel.fetchAudio(for: item) { result in
                                                switch result {
                                                case .success(let url):
                                                    audioURL = url
                                                    selectedItem = item
                                                    viewModel.downloadProgress[item.id] = 0.0
                                                case .failure(let error):
                                                    errorMessage = ErrorWrapper(message: "Failed to download audio: \(error.localizedDescription)")
                                                    selectedItem = nil
                                                    viewModel.downloadProgress[item.id] = 0.0
                                                }
                                            }
                                            
                                        }
                                    }) {
                                        VStack {
                                            UpNextCell(item: item)
                                                .frame(width: proxy.size.width * 0.8, height: proxy.size.height * 0.26)
                        
                                            if let progress = viewModel.downloadProgress[item.id], progress > 0 {
                                                ProgressView(value: progress)
                                                    .progressViewStyle(LinearProgressViewStyle())
                                                    .padding(.top, 8)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                       // }
                        
                    Section("Bedtime Stories") {
                        ForEach(viewModel.bedtimeStories) { item in
                            Button(action: {
                                if item.isPremium, !subscriptionStore.isPremium {
                                    isPresentingPremiumView = true
                                } else {
                                    viewModel.fetchAudio(for: item) { result in
                                        switch result {
                                        case .success(let url):
                                            audioURL = url
                                            selectedItem = item
                                            viewModel.downloadProgress[item.id] = 0.0
                                        case .failure(let error):
                                            errorMessage = ErrorWrapper(message: "Failed to download audio: \(error.localizedDescription)")
                                            selectedItem = nil
                                            viewModel.downloadProgress[item.id] = 0.0
                                        }
                                    }
                                    
                                }
                            }) {
                                VStack {
                                    UpNextCell(item: item)
                                    
                                    if let progress = viewModel.downloadProgress[item.id], progress > 0 {
                                        ProgressView(value: progress)
                                            .progressViewStyle(LinearProgressViewStyle())
                                            .padding(.top, 8)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Audio")
                .sheet(isPresented: $isPresentingPremiumView) {
                    self.isPresentingPremiumView = false
                } content: {
                    GeometryReader { geometry in
                        SubscriptionView(size: geometry.size)
                    }
                }
                .alert(item: $errorMessage) { error in
                    Alert(
                        title: Text("Error"),
                        message: Text(error.message),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(item: $selectedItem, onDismiss: {
                    selectedItem = nil
                    audioURL = nil
                }) { item in
                    if let audioURL = audioURL {
                        AudioPlayerView(
                            viewModel: audioViewModel,
                            audioTitle: item.title,
                            audioSubtitle: item.subtitle,
                            imageUrl: item.imageUrl
                        )
                        .onAppear {
                            audioViewModel.loadAudio(from: audioURL) // Initialize player
                        }
                        .onDisappear {
                            audioViewModel.resetPlayer()
                            AudioPlayerService.shared.playMusic()
                        }
                        
                    }
                }
                
            }
        }
        
    }
}

