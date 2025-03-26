//
//  DevotionalService.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/10/23.
//

import Foundation
import FirebaseStorage
import SwiftUI

protocol DevotionalService {
    func fetchDevotionForToday(remoteVersion: Int) async -> [Devotional]
    func fetchAllDevotionals(needsSync: Bool) async -> [Devotional]
    var devotionals: [Devotional] { get }
    
}

final class DevotionalServiceClient: DevotionalService {
    
    internal var devotionals: [Devotional] = []
    @AppStorage("devotionalRemoteVersion") var currentVersion = 0
    
    init() { }
    
    func fetchDevotionForToday(remoteVersion: Int) async -> [Devotional] {
        let needsSync = currentVersion < remoteVersion
        print(needsSync)
        guard let data = await fetch(needsSync: needsSync) else { return [] }
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM"
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let welcome = try decoder.decode(WelcomeDevotional.self, from: data)
            let devotionals = welcome.devotionals
            self.currentVersion = welcome.version
            self.devotionals = devotionals
   
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
            print(error, "decoding RWRW")
           return []
        }
    }
    
    func fetchAllDevotionals(needsSync: Bool) async -> [Devotional] {
       
        guard let data = await fetch(needsSync: needsSync) else { return [] }
        
        do {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM"
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
    
    func downloadDevotionals() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            downloadDevotionals { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data and no error returned"]))
                }
            }
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
                print("JSON download successful, data length devotionals: \(jsonData.count)")
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
        if needsSync {
            do {
                let data = try await downloadDevotionals()
                return data
            } catch {
                guard
                    let url = Bundle.main.url(forResource: "devotionals", withExtension: "json"),
                    let data = try? Data(contentsOf: url) else {
                    print("RWRW file not found")
                    return nil
                }
                return data
            }
        } else {
            guard
                let url = Bundle.main.url(forResource: "devotionals", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                print("RWRW file not found")
                return nil
            }
            return data
        }
    }
}
