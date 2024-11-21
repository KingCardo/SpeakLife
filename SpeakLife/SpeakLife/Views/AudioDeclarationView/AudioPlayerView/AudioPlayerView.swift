//
//  AudioPlayerView.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/20/24.
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var viewModel: AudioPlayerViewModel
    let audioTitle: String
    let audioSubtitle: String
    let imageUrl: String // Local or remote image URL
    @Binding var isLoading: Bool // Add loading state
    @Binding var progress: Double? // Bind download progress
    
    var body: some View {
        ZStack {
            // Background Color
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                if isLoading {
                    VStack(spacing: 20) {
                        Text("Downloading...")
                            .font(.headline)
                        if let progress = progress {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding()
                        }
                    }
                } else {
                    // Top section: Image and details
                    VStack(spacing: 30) {
                        Image(imageUrl) // Replace with actual remote image logic if needed
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 10) {
                            Text(audioTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            
                        Text(audioSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                   // .padding()
                    
                    // Playback controls
                        VStack(spacing: 16) {
                            // Slider for playback progress
                            Slider(
                                value: $viewModel.currentTime,
                                in: 0...viewModel.duration,
                                onEditingChanged: { isEditing in
                                    if !isEditing {
                                        viewModel.seek(to: viewModel.currentTime)
                                    }
                                }
                            )
                           
                            
                            // Time indicators
                            HStack {
                                Text(formatTime(viewModel.currentTime))
                                    .font(.caption)
                                Spacer()
                                Text(formatTime(viewModel.duration))
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            // Playback buttons
                            HStack(spacing: 50) {
                                Button(action: {
                                    let newTime = max(viewModel.currentTime - 15, 0)
                                    viewModel.seek(to: newTime)
                                }) {
                                    Image(systemName: "gobackward.15")
                                        .font(.title)
                                        .frame(width: 60, height: 60)
                                        .background(Circle().fill(Color(.systemGray6)))
                                        .shadow(radius: 5)
                                }
                                
                                Button(action: {
                                    viewModel.togglePlayPause()
                                }) {
                                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 70))
                                        .frame(width: 80, height: 80)
                                        .background(Circle().fill(Color(.systemGray6)))
                                        .shadow(radius: 5)
                                }
                                
                                Button(action: {
                                    let newTime = min(viewModel.currentTime + 30, viewModel.duration)
                                    viewModel.seek(to: newTime)
                                }) {
                                    Image(systemName: "goforward.30")
                                        .font(.title)
                                        .frame(width: 60, height: 60)
                                        .background(Circle().fill(Color(.systemGray6)))
                                        .shadow(radius: 5)
                                }
                            }
                            .padding(.top)
                        }
                        
                        // Playback speed control
                        //                    HStack {
                        //                        Text("Speed")
                        //                            .font(.caption)
                        //                        Picker("Speed", selection: $viewModel.playbackSpeed) {
                        //                            Text("0.5x").tag(0.5)
                        //                            Text("1x").tag(1.0)
                        //                            Text("1.5x").tag(1.5)
                        //                            Text("2x").tag(2.0)
                        //                        }
                        //                        .pickerStyle(SegmentedPickerStyle())
                        //                        .onChange(of: viewModel.playbackSpeed) { newSpeed in
                        //                            viewModel.changePlaybackSpeed(to: newSpeed)
                        //                        }
                        //                    }
                    }
                    .padding()
                    
                    //   Spacer()
                }
            }
            .onChange(of: progress) { newProgress in
                print("Progress in view: \(String(describing: progress)) RWRW")
                if newProgress == 1.0 {
                    isLoading = false
                    print("Is loading: \(isLoading) RWRW")// Transition to player view on completion
                }
            }
            .onAppear {
                viewModel.changePlaybackSpeed(to: 1.0) // Reset speed to default
            }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
