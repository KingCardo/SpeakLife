//
//  DevotionalService.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import Foundation
import FirebaseStorage

protocol DevotionalService {
    func fetchDevotionForToday(needsSync: Bool) async -> [Devotional]
    func fetchAllDevotionals(needsSync: Bool) async -> [Devotional]
    var devotionals: [Devotional] { get }
    
}

final class DevotionalServiceClient: DevotionalService {
    
    internal var devotionals: [Devotional] = []
    
    init() {
//        loadFromFileDevotionals { devotionals in
//            self.devotionals = devotionals
//        }
    }
    
    func fetchDevotionForToday(needsSync: Bool) async -> [Devotional] {
        
        
        guard let data = await fetch(needsSync: needsSync) else { return [] }
        
        
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let welcome = try decoder.decode(WelcomeDevotional.self, from: data)
            let devotionals = welcome.devotionals
            self.devotionals = devotionals
            saveRemoteDevotionals { success in
                print(success, "saved RWRW")
            }
            print(devotionals.count, "RWRW")
            
           
            let todaysDate = Date()
            let calendar = Calendar.current
            let todaysComponents = calendar.dateComponents([.year, .month, .day], from: todaysDate)
            
                let month = todaysComponents.month
                let day = todaysComponents.day
            
            if let today = devotionals.first(where: {
                let devotionalComponents = calendar.dateComponents([.month, .day], from: $0.date)
                let devotionalMonth = devotionalComponents.month
                let devotionalDay = devotionalComponents.day
                return (devotionalMonth, devotionalDay) == (month, day)}) {
                return [today]
            } else {
                return []
            }
            
        } catch {
            print(error, "RWRW")
           return []
        }
    }
    
    func fetchAllDevotionals(needsSync: Bool) async -> [Devotional] {
       
        guard let data = await fetch(needsSync: needsSync) else { return [] }
        
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let welcome = try decoder.decode(WelcomeDevotional.self, from: data)
            let devotionals = welcome.devotionals
            saveRemoteDevotionals { success in
                print(success, "saved RWRW")
            }
            return devotionals
            
            
        } catch {
            print(error.localizedDescription, "RWRW")
           return []
        }
        
    }
    
    func downloadDevotionals(completion: @escaping((Data?, Error?) -> Void))  {
        let storage = Storage.storage()
        let jsonRef = storage.reference(withPath: "devotionals.json")

        // Download the file into memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        jsonRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(nil, error)
                print("Error downloading JSON file: \(error)")
            } else if let jsonData = data {
                completion(jsonData, nil)
                print("JSON download successful, data length: \(jsonData.count)")
            }
        }
    }
    
    func saveRemoteDevotionals(completion: @escaping(Bool) -> Void) {
        guard
            let DocumentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true),
            let data = try? JSONEncoder().encode(devotionals)
        else {
            completion(false)
            fatalError("Unable to Load Notification categories")
        }
        
        do  {
            let fileURL = DocumentDirURL.appendingPathComponent("remoteDevotionals").appendingPathExtension("json")
            try data.write(to: fileURL, options: .atomic)
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
    
    private func loadFromFileDevotionals(completion: @escaping([Devotional]) -> Void) {
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirURL.appendingPathComponent("remoteDevotionals").appendingPathExtension("json")
        
        
        guard let data = try? Data(contentsOf: fileURL),
              let devotionals = try? JSONDecoder().decode([Devotional].self, from: data) else {
            completion([])
            return
        }
        completion(devotionals)
        return
    }
    
    
    private func fetch(needsSync: Bool) async -> Data? {
        var remoteData: Data?
        if needsSync {
            downloadDevotionals { data, error in
                remoteData = data
            }
            return remoteData
        }
        guard
            let url = Bundle.main.url(forResource: "devotionals", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
            print("RWRW file not found")
            return nil
        }
        return data
       
    }
}
