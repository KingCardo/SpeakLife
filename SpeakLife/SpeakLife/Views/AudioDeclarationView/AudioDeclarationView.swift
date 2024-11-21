//
//  AudioDeclarationView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import SwiftUI

struct UpNextCell: View {
    let item: AudioDeclaration
    
    var body: some View {
        HStack(spacing: 16) {
            // Image on the left
            Image(item.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Subtitle
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Play button with duration
                HStack(spacing: 8) {
                    Button(action: {
                        // Handle play action here
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.caption)
                            Text(item.duration)
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                }
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
    @State private var selectedItem: AudioDeclaration? = nil
    @State private var audioURL: URL? = nil
    @State private var errorMessage: ErrorWrapper? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Up Next")) {
                    ForEach(viewModel.audioDeclarations) { item in
                        Button(action: {
                            viewModel.fetchAudio(for: item) { result in
                                switch result {
                                case .success(let url):
                                    audioURL = url
                                    selectedItem = item
                                    viewModel.downloadProgress = nil
                                case .failure(let error):
                                    errorMessage = ErrorWrapper(message: "Failed to download audio: \(error.localizedDescription)")
                                    viewModel.downloadProgress = nil
                                }
                            }
                        }) {
                            UpNextCell(item: item)
                        }
                        
                        if let progress = viewModel.downloadProgress, progress > 0 {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.top, 8)
                        }
                    }
                }
               // .listRowSeparator(.hidden)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Audio Declarations")
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
                               imageUrl: item.imageUrl,
                               isLoading: Binding(
                                get: { viewModel.downloadProgress != nil },
                                set: { _ in } // No-op since progress drives isLoading
                            ),
                            progress: $viewModel.downloadProgress
                    )
                    .onAppear {
                        audioViewModel.loadAudio(from: audioURL) // Initialize player
                    }
                }
            }
            .onDisappear {
                audioViewModel.resetPlayer()
                AudioPlayerService.shared.playMusic()
            }
        }
    }
}

