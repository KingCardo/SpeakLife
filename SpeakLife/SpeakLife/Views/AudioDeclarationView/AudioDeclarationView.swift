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
    @ObservedObject var viewModel: AudioDeclarationViewModel
    @ObservedObject var audioViewModel: AudioPlayerViewModel
    let item: AudioDeclaration
    @State var downloadURL: URL?
    @State private var selectedEpisode: URL? // Track selected episode
    @State private var showSheet = false // Track sheet visibility
    @State private var showToast = false
    
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                Image(item.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 120)
                    .cornerRadius(8)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline)
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                    
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
                    
                }
                Spacer()
//                if subscriptionStore.isPremium {
//                    Button {
//                        viewModel.fetchAudio(for: item) { result in
//                            DispatchQueue.main.async {
//                                switch result {
//                                case .success(let url):
//                                    addToQueue(url)
//                                    withAnimation {
//                                        showToast = true
//                                    }
//                                    // Hide the toast after 2 seconds
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                        withAnimation {
//                                            showToast = false
//                                        }
//                                    }
//                                    downloadURL = url
//                                case .failure(let error):
//                                    print(error)
//                                }
//                            }
//                        }
//                    } label: {
//                        
//                        Image(systemName: "text.badge.plus")
//                            .frame(width: 20, height: 20)
//                    }
//                }
            }
            .padding()
            
            if showToast {
                VStack {
                    Text("Added to queue")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showToast)
    }

func addToQueue(_ url: URL?) {
    audioViewModel.addToQueue(url)
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
    let filters: [Filter] = [.declarations]
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
                        header
                    }
                    .padding(.top)
                    episodeRow(proxy)
                    Spacer()
                    audioBar
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
    
    var header: some View {
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
    
    func episodeRow(_ proxy: GeometryProxy) -> some View {
        List {
            ForEach(filteredContent) { item in
                Button(action: {
                    if item.isPremium, !subscriptionStore.isPremium {
                        isPresentingPremiumView = true
                    } else {
                        viewModel.downloadProgress[item.id] = nil
                        viewModel.fetchAudio(for: item) { result in
                            DispatchQueue.main.async {
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
                        
                    }
                }) {
                    VStack {
                        UpNextCell(viewModel: viewModel, audioViewModel: audioViewModel, item: item)
                            .frame(width: proxy.size.width * 0.8, height: proxy.size.height * 0.20)
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
    
    @ViewBuilder
    var audioBar: some View {
        if audioViewModel.isBarVisible {
            PersistentAudioBar(viewModel: audioViewModel)
                .onDisappear {
                    if declarationStore.backgroundMusicEnabled, !audioViewModel.isPlaying {
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


