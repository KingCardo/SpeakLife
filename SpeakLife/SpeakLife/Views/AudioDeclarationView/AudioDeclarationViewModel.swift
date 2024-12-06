//
//  AudioDeclarationViewModel.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 11/14/24.
//

import Foundation
import FirebaseStorage

let audioFiles: [AudioDeclaration] = [
    AudioDeclaration(
           id: "health1.mp3",
           title: "Healing Declarations",
           subtitle: "Speaking Wholeness, Strength, and Restoration Through the Power of Faith",
           duration: "4m",
           imageUrl: "JesusHealing",
           isPremium: false
       ),
    AudioDeclaration(
           id: "peace.mp3",
           title: "Peace Beyond Understanding",
           subtitle: "Overcoming Anxiety, Stress, and Fear Through God’s Promisess",
           duration: "3m",
           imageUrl: "JesusPraying",
           isPremium: true
       ),
    AudioDeclaration(
           id: "gratitude.mp3",
           title: "A Heart of Gratitude",
           subtitle: "Declaring God’s Goodness and Faithfulness with Thankful Praise",
           duration: "3m",
           imageUrl: "desertSky",
           isPremium: true
       ),
    AudioDeclaration(
           id: "warfare.mp3",
           title: "Victory in Spiritual Warfare",
           subtitle: "Declaring Authority and Triumph Over All Evil Through Christ",
           duration: "3m",
           imageUrl: "heavenly",
           isPremium: true
       ),
    AudioDeclaration(
           id: "psalm91.mp3",
           title: "Psalm 91: A Shield of Protection",
           subtitle: "Declaring God’s Faithful Promises of Safety and Refuge",
           duration: "2m",
           imageUrl: "pinkHueMountain",
           isPremium: true
       ),
    AudioDeclaration(
           id: "victorious.mp3",
           title: "Living Victoriously in Christ",
           subtitle: "Declaring Bible Verses to Walk in Victory Every Day",
           duration: "3m",
           imageUrl: "sereneMountain",
           isPremium: true
       ),
    AudioDeclaration(
           id: "prosperity.mp3",
           title: "Abundance Declarations",
           subtitle: "Unlocking Wealth, Prosperity, and Overflow Through Faith and Affirmation",
           duration: "4m",
           imageUrl: "JesusHeaven",
           isPremium: true
       ),
    AudioDeclaration(
           id: "identity.mp3",
           title: "Identity in Christ",
           subtitle: "Living in the Power of Your God-Given Identity",
           duration: "4m",
           imageUrl: "JesusOnCross",
           isPremium: true
       ),
    AudioDeclaration(
           id: "godsprotection.mp3",
           title: "Protection Promises",
           subtitle: "Speaking God’s Word for Safety and Peace Over Your Life",
           duration: "4m",
           imageUrl: "warriorAngel",
           isPremium: true
       ),
    AudioDeclaration(
           id: "longlife.mp3",
           title: "Renewed Youth and Long Life Declaration",
           subtitle: "Declarations for Long Life, Strength, and Youth Restored Through God’s Promises",
           duration: "3m",
           imageUrl: "JesusRisen",
           isPremium: true
       ),
    AudioDeclaration(
           id: "closer.mp3",
           title: "Closer to God",
           subtitle: "Declaring a Life of Intimacy with Him and Walking in the Spirit Every Day",
           duration: "3m",
           imageUrl: "flowingRiver",
           isPremium: true
       ),
    AudioDeclaration(
           id: "children.mp3",
           title: "Blessing Our Children",
           subtitle: "Declaring Safety, Wisdom, and Destiny Over Their Lives",
           duration: "3m",
           imageUrl: "calmLake",
           isPremium: true
       ),
    AudioDeclaration(
           id: "miracles.mp3",
           title: "Breakthrough and Miracles",
           subtitle: "Declaring the Power of God to Transform the Impossible",
           duration: "3m",
           imageUrl: "radiantAngel",
           isPremium: true
       ),
    AudioDeclaration(
           id: "restoration.mp3",
           title: "Restoring Relationships",
           subtitle: "Declaring Healing, Unity, and Love Over Marriages and Families",
           duration: "3m",
           imageUrl: "breathTakingSunset",
           isPremium: true
       ),
]

let bedTimeFiles: [AudioDeclaration] = [
    AudioDeclaration(
           id: "beginning.mp3",
           title: "In the Beginning",
           subtitle: "Journey into God’s Perfect Creation",
           duration: "9m",
           imageUrl: "flowingRiver",
           isPremium: false
       ),
    ]

final class AudioDeclarationViewModel: ObservableObject {
    @Published var audioDeclarations: [AudioDeclaration]
    @Published var bedtimeStories: [AudioDeclaration]
    @Published var downloadProgress: [String: Double] = [:]
    private let storage = Storage.storage()
    private let fileManager = FileManager.default
      
      init() {
          self.audioDeclarations = audioFiles
          self.bedtimeStories = bedTimeFiles
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
