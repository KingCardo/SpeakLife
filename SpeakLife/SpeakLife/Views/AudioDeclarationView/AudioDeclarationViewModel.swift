//
//  AudioDeclarationViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import Foundation
import FirebaseStorage
import SwiftUI
import Combine

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
    @Published var praise: [AudioDeclaration]  = []
   // @Published var audioDeclarations: [AudioDeclaration] = []
    private(set) var allAudioFiles: [AudioDeclaration] = []
    @Published var downloadProgress: [String: Double] = [:]
    @Published var fetchingAudioIDs: Set<String> = []
    @Published var filters: [Filter] = [.favorites, .speaklife, .declarations, .praise, .godsHeart, .growWithJesus, .psalm91, .divineHealth, .magnify,/*.imagination,.devotional,*/  .gospel, .meditation, .bedtimeStories]

    // Favorites manager
    let favoritesManager = AudioFavoritesManager()

    @Published var selectedFilter: Filter = .speaklife
    private let storage = Storage.storage()
    private let fileManager = FileManager.default
    @AppStorage("lastCachedAudioVersion") private var lastCachedAudioVersion = 0
    private let service: APIService = LocalAPIClient()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe changes in favorites manager to trigger UI updates
        favoritesManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    
    var filteredContent: [AudioDeclaration] {
        switch selectedFilter {
        case .favorites:
            return favoritesManager.getFavoritesSortedByDate()
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
        case .praise:
            return praise.reversed()
        }
    }
    
    func fetchAudio(version: Int) {
        if version > lastCachedAudioVersion {
            clearCache()
            clearAudioDeclarationsCache()
        }
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
                praise = self.allAudioFiles.filter { $0.tag == "praise" }
               // setFilters(welcome)
                
                // Update the cached version after successful fetch
                self.lastCachedAudioVersion = version
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
        print(item.id, "RWRW")
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
    
    private func clearAudioDeclarationsCache() {
        let fileManager = FileManager.default
        let documentDirURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirURL.appendingPathComponent("audioDeclarations").appendingPathExtension("txt")
        
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("Audio declarations cache cleared successfully!")
            }
            
            // Reset the audio local version to force fresh download
            UserDefaults.standard.set(0, forKey: "audioLocalVersion")
            print("Audio local version reset to force fresh download")
            
        } catch {
            print("Failed to clear audio declarations cache: \(error.localizedDescription)")
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
      var isFavorite: Bool = false
      var favoriteId: String?
      var dateFavorited: Date?
    
    // Initializer for creating new instances (used in AudioFiles.swift)
    init(id: String, title: String, subtitle: String, duration: String, imageUrl: String, 
         isPremium: Bool, tag: String? = nil, isFavorite: Bool = false, 
         favoriteId: String? = nil, dateFavorited: Date? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.imageUrl = imageUrl
        self.isPremium = isPremium
        self.tag = tag
        self.isFavorite = isFavorite
        self.favoriteId = favoriteId
        self.dateFavorited = dateFavorited
    }
    
    // Custom coding keys for the core properties
    private enum CodingKeys: String, CodingKey {
        case id, title, subtitle, duration, imageUrl, isPremium, tag
        case isFavorite, favoriteId, dateFavorited
    }
    
    // Custom decoder to handle missing favorite fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        duration = try container.decode(String.self, forKey: .duration)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        
        // Decode favorite fields with defaults if missing
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        favoriteId = try container.decodeIfPresent(String.self, forKey: .favoriteId)
        dateFavorited = try container.decodeIfPresent(Date.self, forKey: .dateFavorited)
    }
    
    // Custom encoder to include all fields when saving
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(duration, forKey: .duration)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encodeIfPresent(tag, forKey: .tag)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(favoriteId, forKey: .favoriteId)
        try container.encodeIfPresent(dateFavorited, forKey: .dateFavorited)
    }
}
