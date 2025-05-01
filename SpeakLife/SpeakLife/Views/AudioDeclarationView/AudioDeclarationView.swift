//
//  AudioDeclarationView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import SwiftUI
import FirebaseAnalytics
import SwiftUI
import UIKit

struct UpNextCell: View {
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @ObservedObject var viewModel: AudioDeclarationViewModel
    @ObservedObject var audioViewModel: AudioPlayerViewModel

    let item: AudioDeclaration

    @State private var showToast = false
    @State private var isTapped = false
    @State private var animateGlow = false

    var body: some View {
        ZStack {
                HStack(spacing: 16) {
                    Image(item.imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 17, weight: .semibold))
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                        
                        Text(item.subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.caption)
                            Text(item.duration)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            
                            if item.isPremium, !subscriptionStore.isPremium {
                                Image(systemName: "lock")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(animateGlow ? 0.15 : 0.05), lineWidth: animateGlow ? 1.5 : 0.5)
                                .shadow(color: Color.blue.opacity(animateGlow ? 0.3 : 0), radius: animateGlow ? 10 : 0)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(isTapped ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTapped)


            if showToast {
                VStack {
                    Text("Added to queue")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .scaleEffect(showToast ? 1.05 : 0.8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: showToast)
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }

    func addToQueue(_ url: URL?) {
        audioViewModel.addToQueue(url)
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
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
    case speaklife = "SpeakLife"
    case godsHeart = "God's Heart"
    case growWithJesus = "Grow With Jesus"
    case divineHealth = "Divine Health"
}

struct FetchedFilter: Identifiable, Hashable {
    var id: String  // unique ID for the filter
    var displayName: String
    var tag: String // used to filter audio files
}

struct AudioDeclarationView: View {
    @EnvironmentObject private var viewModel: AudioDeclarationViewModel
    @StateObject private var audioViewModel: AudioPlayerViewModel
    @EnvironmentObject var subscriptionStore: SubscriptionStore
    @EnvironmentObject var declarationStore: DeclarationViewModel
   
    @State private var audioURL: URL? = nil
    @State private var errorMessage: ErrorWrapper? = nil
    @State private var isPresentingPremiumView = false
    @State var presentDevotionalSubscriptionView = false
   
    init(declarationStore: AudioDeclarationViewModel) {
        let playerVM = AudioPlayerViewModel()
        playerVM.audioDeclarationViewModel = declarationStore
        _audioViewModel = StateObject(wrappedValue: playerVM)
    }
    
    var body: some View {
        GeometryReader { proxy in
        ZStack {
            Gradients().speakLifeCYOCell
                .ignoresSafeArea()
            
           
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("Meditation")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
//                                HStack(spacing: 8) {
//                                    Text("AutoPlay")
//                                        .foregroundColor(.white)
//                                        .font(.subheadline)
//
//                                    Toggle("", isOn: $audioViewModel.autoPlayAudio)
//                                        .labelsHidden()
//                                        .tint(.blue)
//                                .tint(.white)
//                                .onChange(of: audioViewModel.autoPlayAudio) { newValue in
//                                    if subscriptionStore.isPremium {
//                                        if newValue {
//                                            print(newValue, audioViewModel.lastSelectedItem, "RWRW")
//                                            let allItems = filteredContent
//                                            if let lastSelectedItem = audioViewModel.lastSelectedItem,
//                                               let currentIndex = allItems.firstIndex(of: lastSelectedItem),
//                                               currentIndex + 1 < allItems.count {
//                                                print(lastSelectedItem, "RWRW last selected" )
//                                                
//                                                let itemsToQueue = Array(allItems[(currentIndex + 1)...])
//                                                audioViewModel.addToQueue(items: itemsToQueue)
//                                            } else {
//                                                audioViewModel.clearQueue()
//                                            }
//                                        }
//                                    } else {
//                                        withAnimation {
//                                            isPresentingPremiumView = true
//                                            audioViewModel.autoPlayAudio = false
//                                        }
//                                       
//                                    }
//                                }
//                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.top,  44)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        header
                    }
                    .background(.clear)
                    .padding(.vertical)
                    
                    episodeRow(proxy)
            
                    Spacer().frame(height: proxy.size.height * 0.09)
                }
            }
            VStack {
                 Spacer()
                 
                 audioBar
                 Spacer().frame(height: proxy.size.height * 0.09)
            }
        }
        
        .sheet(isPresented: $isPresentingPremiumView) {
            self.isPresentingPremiumView = false
        } content: {
           // GeometryReader { geometry in
            SubscriptionView(size: UIScreen.main.bounds.size)
                .frame(height: UIScreen.main.bounds.height * 0.96)
                    .onDisappear {
                        if !subscriptionStore.isPremium, !subscriptionStore.isInDevotionalPremium {
                            if subscriptionStore.showDevotionalSubscription {
                                presentDevotionalSubscriptionView = true
                            }
                        }
                    }
            //}
        }
        
        .alert(item: $errorMessage) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }

        .sheet(item: $audioViewModel.selectedItem, onDismiss: {
            withAnimation {
                audioViewModel.isBarVisible = true
            }
        }) { item in
          
            if let _ = audioURL {
                AudioPlayerView(
                    viewModel: audioViewModel
                )
                .presentationDetents([.large])
                .onAppear {
                    print(item.subtitle, "RWRW selected" )
                   // audioViewModel.loadAudio(from: audioURL, isSameItem: audioViewModel.lastSelectedItem == item)
                    audioViewModel.lastSelectedItem = item
                    Analytics.logEvent(item.id, parameters: nil)
                }
            }
        }
        
        .sheet(isPresented: $presentDevotionalSubscriptionView) {
            DevotionalSubscriptionView {
                presentDevotionalSubscriptionView = false
            }
        }
    }
    
    var header: some View {
        HStack(spacing: 15) {
            ForEach(viewModel.filters, id: \.self) { filter in
                Button(action: {
                    viewModel.selectedFilter = filter
                  //  viewModel.selectedDynamicFilter = nil
                }) {
                    Text(filter.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(viewModel.selectedFilter == filter ? Constants.DAMidBlue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
            
//            ForEach(viewModel.dynamicFilters, id: \.self) { filter in
//                Button(action: {
//                    viewModel.selectedDynamicFilter = filter
//                    //viewModel.selectedFilter = filter
//                }) {
//                    Text(filter.displayName)
//                        .font(.caption)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 10)
//                        .background(viewModel.selectedDynamicFilter == filter ? Constants.DAMidBlue : Color.gray.opacity(0.2))
//                        .foregroundColor(.white)
//                        .cornerRadius(20)
//                }
//            }
            
//            ForEach(viewModel.dynamicFilters) { fetchedFilter in
//                Button(action: {
//                    viewModel.selectedDynamicFilter = fetchedFilter
//                }) {
//                    Text(fetchedFilter.displayName)
//                        .foregroundColor(viewModel.selectedDynamicFilter == fetchedFilter ? .accentColor : .primary)
//                }
        }
        .padding(.horizontal)
    }
    
    func episodeRow(_ proxy: GeometryProxy) -> some View {
        List {
            ForEach(viewModel.filteredContent) { item in
                Button(action: {
                    if item.isPremium, !subscriptionStore.isPremium {
                        isPresentingPremiumView = true
                    } else {
                        viewModel.downloadProgress[item.id] = nil
                        viewModel.fetchingAudioIDs.insert(item.id)
                        viewModel.fetchAudio(for: item) { result in
                            DispatchQueue.main.async {
                                viewModel.fetchingAudioIDs.remove(item.id)
                                switch result {
                                case .success(let url):
                                    audioURL = url
                                    audioViewModel.selectedItem = item
                                    audioViewModel.insert(url)
                                    viewModel.downloadProgress[item.id] = 0.0
                                    audioViewModel.currentTrack = audioViewModel.selectedItem?.title ?? ""
                                    audioViewModel.subtitle = audioViewModel.selectedItem?.subtitle ?? ""
                                    audioViewModel.imageUrl = audioViewModel.selectedItem?.imageUrl ?? ""
                                    audioViewModel.loadAudio(from: url, isSameItem: audioViewModel.selectedItem == item)
                                case .failure(let error):
                                    errorMessage = ErrorWrapper(message: "Failed to download audio: \(error.localizedDescription)")
                                    audioViewModel.selectedItem = nil
                                    viewModel.downloadProgress[item.id] = 0.0
                                }
                            }
                        }
                        
                    }
                }) {
                    VStack {
                        UpNextCell(viewModel: viewModel, audioViewModel: audioViewModel, item: item)
                            .frame(width: proxy.size.width * 0.85, height: proxy.size.height * 0.15)
                        
                        if let progress = viewModel.downloadProgress[item.id], progress > 0 {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.top, 8)
                        }
                    }
                    .listRowInsets(EdgeInsets()) // remove default padding
                    .background(Color.clear)
                }
                .disabled(viewModel.fetchingAudioIDs.contains(item.id))
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(.clear)
    }
    
    @ViewBuilder
    var audioBar: some View {
        if audioViewModel.isBarVisible {
            PersistentAudioBar(viewModel: audioViewModel)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeOut(duration: 0.4), value: audioViewModel.isBarVisible)
                .onDisappear {
                    if declarationStore.backgroundMusicEnabled, !audioViewModel.isPlaying {
                        AudioPlayerService.shared.playMusic()
                    }
                }
                .onTapGesture {
                    if let lastSelectedItem = audioViewModel.lastSelectedItem {
                        self.audioViewModel.selectedItem = lastSelectedItem
                    }
                }
        }
    }
}



extension View {
    func frostedCardStyle(cornerRadius: CGFloat = 20) -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
