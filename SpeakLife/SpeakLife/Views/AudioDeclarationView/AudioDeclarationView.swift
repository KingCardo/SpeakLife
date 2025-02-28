//
//  AudioDeclarationView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import SwiftUI
import FirebaseAnalytics

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
                    .minimumScaleFactor(0.8)
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

enum Filter: String {
    case declarations = "Mountain-Moving Prayers"
    case bedtimeStories = "Bedtime Stories"
    case gospel = "Gospel"
    case meditation = "Scripture Meditation's"
    case devotional = "Devotional"
}

struct AudioDeclarationView: View {
    @StateObject private var viewModel = AudioDeclarationViewModel()
    @StateObject private var audioViewModel = AudioPlayerViewModel()
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var declarationStore: DeclarationViewModel
    @State private var selectedItem: AudioDeclaration? = nil
    @State private var lastSelectedItem: AudioDeclaration?
    @State private var audioURL: URL? = nil
    @State private var errorMessage: ErrorWrapper? = nil
    @State private var isPresentingPremiumView = false
    let filters: [Filter] = [.declarations, .meditation, .gospel, .bedtimeStories, .devotional]
    @State private var selectedFilter: Filter = .declarations
    @State var presentDevotionalSubscriptionView = false
    
     var filteredContent: [AudioDeclaration] {
        switch selectedFilter {
        case .declarations:
            return viewModel.audioDeclarations
        case .bedtimeStories:
            return viewModel.bedtimeStories
        case .gospel:
            return viewModel.gospelStories
        case .meditation:
            return viewModel.meditations
        case .devotional:
            return viewModel.devotionals
        }
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: {
                                    selectedFilter = filter
                                }) {
                                    Text(filter.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 10)
                                        .background(selectedFilter == filter ? Constants.DAMidBlue : Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                     .padding(.top)
                    List {
                        ForEach(filteredContent) { item in
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
                                            audioViewModel.currentTrack = selectedItem?.title ?? ""
                                            audioViewModel.subtitle = selectedItem?.subtitle ?? ""
                                            audioViewModel.imageUrl = selectedItem?.imageUrl ?? ""
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
                    Spacer()
                    if audioViewModel.isBarVisible {
                        PersistentAudioBar(viewModel: audioViewModel)
                            .onDisappear {
                                if declarationStore.backgroundMusicEnabled {
                                    AudioPlayerService.shared.playMusic()
                                }
                            }
                            .onTapGesture {
                                if let lastSelectedItem = lastSelectedItem {
                                self.selectedItem = lastSelectedItem
                            }
                            }
                    }
                }
                    
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Meditation")
                .sheet(isPresented: $isPresentingPremiumView) {
                    self.isPresentingPremiumView = false
                } content: {
                    GeometryReader { geometry in
                        SubscriptionView(size: geometry.size)
                            .onDisappear {
                                if !subscriptionStore.isPremium, !subscriptionStore.isInDevotionalPremium {
                                    if subscriptionStore.showDevotionalSubscription {
                                        presentDevotionalSubscriptionView = true
                                    }
                                }
                            }
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
                    withAnimation {
                        audioViewModel.isBarVisible = true
                    }
                }) { item in
                    if let audioURL = audioURL {
                        AudioPlayerView(
                            viewModel: audioViewModel,
                            audioTitle: item.title,
                            audioSubtitle: item.subtitle,
                            imageUrl: item.imageUrl
                        )
                        .onAppear {
                            audioViewModel.loadAudio(from: audioURL, isSameItem: lastSelectedItem == item)
                            lastSelectedItem = item
                            Analytics.logEvent(item.id, parameters: nil)
                        }
                        
                    }
                }
                
            }
        .sheet(isPresented: $presentDevotionalSubscriptionView) {
            DevotionalSubscriptionView() {
                presentDevotionalSubscriptionView = false
            }
        }
        }
        
    }
//}

