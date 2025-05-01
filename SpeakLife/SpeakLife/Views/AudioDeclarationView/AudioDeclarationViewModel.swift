//
//  AudioDeclarationViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import Foundation
import FirebaseStorage
import SwiftUI

final class AudioDeclarationViewModel: ObservableObject {
    @Published var audioDeclarations: [AudioDeclaration]
    @Published var bedtimeStories: [AudioDeclaration]
    @Published var gospelStories: [AudioDeclaration]
    @Published var meditations: [AudioDeclaration]
    @Published var devotionals: [AudioDeclaration]
    @Published var speaklife: [AudioDeclaration]
    @Published var godsHeart: [AudioDeclaration]
    @Published var growWithJesus: [AudioDeclaration]
    @Published var divineHealth: [AudioDeclaration]
    @Published var downloadProgress: [String: Double] = [:]
    @Published var fetchingAudioIDs: Set<String> = []
    @Published var filters: [Filter] = [
        .godsHeart, .divineHealth, .growWithJesus, .speaklife, .declarations, .gospel, .bedtimeStories, .meditation
    ]
    @Published var selectedFilter: Filter = .godsHeart
    @Published var dynamicFilters: [FetchedFilter] = []
    @Published var selectedDynamicFilter: FetchedFilter? = nil
    private let storage = Storage.storage()
    private let fileManager = FileManager.default
    @AppStorage("shouldClearCachev3") private var shouldClearCachev3 = true
    private let service: APIService = LocalAPIClient()
    init() {
          self.audioDeclarations = audioFiles
          self.bedtimeStories = bedTimeFiles
          self.gospelStories = gospelFiles
          self.meditations = meditationFiles
          self.devotionals = devotionalFiles
          self.growWithJesus = growWithJesusFiles
          self.speaklife = []
          self.godsHeart = []
          self.divineHealth = divineHealthFiles
      }
    
    var filteredContent: [AudioDeclaration] {
        
//        if let dynamicFilter = selectedDynamicFilter {
////                return allAudioDeclarations
////                    .filter { $0.tag == dynamicFilter.tag }
////                    .reversed()
//            }
        switch selectedFilter {
        case .declarations:
            return audioDeclarations
        case .bedtimeStories:
            return bedtimeStories
        case .gospel:
            return gospelStories
        case .meditation:
            return meditations
        case .devotional:
            return devotionals
        case .speaklife:
            return speaklife.reversed()
        case .godsHeart:
            return godsHeart.reversed()
        case .growWithJesus:
            return growWithJesus
        case .divineHealth:
            return divineHealth
        }
    }
    
    func fetchAudio(version: Int) {
        print(version, "RWRW version")
        service.audio(version: version) { audio in
            print(audio.count, "RWRW")
            DispatchQueue.main.async {
                let godsHeart = audio.filter { $0.tag == "godsHeart" }
                let speakLife = audio.filter { $0.tag == "speaklife" || $0.tag == nil }
                self.speaklife = speakLife
                self.godsHeart = godsHeart
            }
        }
    }
    
    func fetchAudio(for item: AudioDeclaration, completion: @escaping (Result<URL, Error>) -> Void) {
        if shouldClearCachev3 {
            clearCache()
            shouldClearCachev3 = false
        }
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
    
    private func clearCache() {
        let fileManager = FileManager.default
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let cacheContents = try fileManager.contentsOfDirectory(atPath: cacheDirectory.path)
                for file in cacheContents {
                    let fileURL = cacheDirectory.appendingPathComponent(file)
                    try fileManager.removeItem(at: fileURL)
                }
                print("Cache cleared successfully!")
            } catch {
                print("Failed to clear cache: \(error.localizedDescription)")
            }
        }
    }
  }

struct WelcomeAudio: Codable {
    let version: Int
    let audios: [AudioDeclaration]
}

struct AudioDeclaration: Identifiable, Equatable, Codable, Comparable {
    static func < (lhs: AudioDeclaration, rhs: AudioDeclaration) -> Bool {
        return lhs.id == rhs.id
    }
    
      let id: String
      let title: String
      let subtitle: String
      let duration: String
      let imageUrl: String
      let isPremium: Bool
      var tag: String?
}
