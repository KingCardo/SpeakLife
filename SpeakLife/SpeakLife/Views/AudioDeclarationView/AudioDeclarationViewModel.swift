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
    @Published var audioDeclarations: [AudioDeclaration]  = []
    @Published var bedtimeStories: [AudioDeclaration]  = []
    @Published var gospelStories: [AudioDeclaration]  = []
    @Published var meditations: [AudioDeclaration]  = []
    @Published var devotionals: [AudioDeclaration]  = []
    @Published var speaklife: [AudioDeclaration]  = []
    @Published var godsHeart: [AudioDeclaration]  = []
    @Published var growWithJesus: [AudioDeclaration]  = []
    @Published var divineHealth: [AudioDeclaration]  = []
    @Published var imagination: [AudioDeclaration]  = []
    @Published var psalm91: [AudioDeclaration]  = []
    @Published var magnify: [AudioDeclaration]  = []
   // @Published var audioDeclarations: [AudioDeclaration] = []
    private(set) var allAudioFiles: [AudioDeclaration] = []
    @Published var downloadProgress: [String: Double] = [:]
    @Published var fetchingAudioIDs: Set<String> = []
    @Published var filters: [Filter] = [.godsHeart, .speaklife, .growWithJesus, .psalm91, .divineHealth, .magnify,/*.imagination,.devotional,*/ .declarations, .gospel, .meditation, .bedtimeStories]


    @Published var selectedFilter: Filter = .godsHeart
    private let storage = Storage.storage()
    private let fileManager = FileManager.default
    @AppStorage("shouldClearCachev3") private var shouldClearCachev3 = true
    private let service: APIService = LocalAPIClient()
    init() {

      }

    
    var filteredContent: [AudioDeclaration] {
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
        case .imagination:
            return imagination
        case .psalm91:
            return psalm91.reversed()
        case .magnify:
            return magnify.reversed()
        }
    }
    
    func fetchAudio(version: Int) {
        service.audio(version: version) { [weak self] welcome, audios in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.allAudioFiles = welcome?.audios ?? audios!
                audioDeclarations = self.allAudioFiles
                    .filter { $0.tag == "declarations" }
                bedtimeStories = self.allAudioFiles.filter { $0.tag == "bedtimeStories" }
                gospelStories = self.allAudioFiles.filter { $0.tag == "gospel" }
                meditations = self.allAudioFiles.filter { $0.tag == "meditation" }
                speaklife = self.allAudioFiles.filter { $0.tag == "speaklife" }
                godsHeart = self.allAudioFiles.filter { $0.tag == "godsHeart" }
                growWithJesus = self.allAudioFiles.filter { $0.tag == "growWithJesus" }
                divineHealth = self.allAudioFiles.filter { $0.tag == "divineHealth" }
                psalm91 = self.allAudioFiles.filter { $0.tag == "psalm91" }
                imagination = self.allAudioFiles.filter { $0.tag == "imagination" }
                magnify = self.allAudioFiles.filter { $0.tag == "magnify" }
               // setFilters(welcome)
            }
        }
    }
                    
//    private func setFilters(_ weclome: WelcomeAudio?) {
//        guard let filterString = weclome?.filters else {
//            self.filters = [.godsHeart, .magnify, .speaklife, .psalm91, /*.imagination,.devotional,*/ .divineHealth,  .growWithJesus,.declarations, .gospel, .meditation, .bedtimeStories]
//            return }
//        let filters = filterString.compactMap { Filter(rawValue: $0)}
//        self.filters = filters
//    }
    
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
    let filters: [String]?
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
