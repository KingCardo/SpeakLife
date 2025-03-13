//
//  AudioDeclarationViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import Foundation
import FirebaseStorage

final class AudioDeclarationViewModel: ObservableObject {
    @Published var audioDeclarations: [AudioDeclaration]
    @Published var bedtimeStories: [AudioDeclaration]
    @Published var gospelStories: [AudioDeclaration]
    @Published var meditations: [AudioDeclaration]
    @Published var devotionals: [AudioDeclaration]
    @Published var downloadProgress: [String: Double] = [:]
    private let storage = Storage.storage()
    private let fileManager = FileManager.default
    
      init() {
          self.audioDeclarations = audioFiles
          self.bedtimeStories = bedTimeFiles
          self.gospelStories = gospelFiles
          self.meditations = meditationFiles
          self.devotionals = devotionalFiles
      }
    
    func fetchAudio(for item: AudioDeclaration, completion: @escaping (Result<URL, Error>) -> Void) {
           // Get the local URL for the file
           let localURL = cachedFileURL(for: item.id)
           // self.downloadProgress[item.id] = 0.0

           // Check if the file exists locally
           if fileManager.fileExists(atPath: localURL.path) {
               print("File found in cache: \(localURL.path)")
               completion(.success(localURL))
               return
           }

           // If not, download from Firebase
           print("File not found in cache. Downloading from Firebase.")
           downloadAudio(for: item, to: localURL, completion: completion)
       }
    
    func downloadAudio(for item: AudioDeclaration, to localURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = storage.reference().child(item.id)
        
        let downloadTask = storageRef.write(toFile: localURL) { url, error in
            DispatchQueue.main.async {
                self.downloadProgress[item.id] = 0.0 // Reset progress when download completes
            }
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                
                completion(.success(url))
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
           
            if let progress = snapshot.progress {
                print("Download Progress: \(progress.fractionCompleted)")
                DispatchQueue.main.async {
                    self.downloadProgress[item.id] = progress.fractionCompleted
                    
                }
            }
        }
    }
    
    private func cachedFileURL(for filename: String) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            return cacheDirectory.appendingPathComponent(filename)
        }
  }

struct AudioDeclaration: Identifiable, Equatable {
      let id: String
      let title: String
      let subtitle: String
      let duration: String
      let imageUrl: String
     let isPremium: Bool
    
}
