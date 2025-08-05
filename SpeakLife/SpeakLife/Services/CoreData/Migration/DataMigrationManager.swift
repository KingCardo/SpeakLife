//
//  DataMigrationManager.swift
//  SpeakLife
//
//  Data Migration Manager for Legacy Data to Core Data
//

import Foundation
import CoreData

final class DataMigrationManager {
    
    private let persistenceController: PersistenceController
    private let legacyAPIService: APIService
    
    init(persistenceController: PersistenceController = .shared,
         legacyAPIService: APIService = LocalAPIClient()) {
        self.persistenceController = persistenceController
        self.legacyAPIService = legacyAPIService
    }
    
    // MARK: - Migration
    func migrateLegacyData() async throws {
        let context = persistenceController.container.viewContext
        
        // Check if migration has already been performed
        let migrationKey = "HasMigratedToCoreData"
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            legacyAPIService.declarations { [weak self] declarations, error, _ in
                guard let self = self else {
                    continuation.resume(throwing: DataMigrationError.migrationFailed)
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                Task {
                    do {
                        try await self.migrateLegacyDeclarations(declarations, context: context)
                        UserDefaults.standard.set(true, forKey: migrationKey)
                        
                        // Clean up legacy data only after successful migration
                        self.cleanUpLegacyData()
                        continuation.resume()
                    } catch {
                        // Don't set migration flag if failed - will retry next time
                        print("Migration failed: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func migrateLegacyDeclarations(_ declarations: [Declaration], context: NSManagedObjectContext) async throws {
        try await context.perform {
            for declaration in declarations where declaration.category == .myOwn {
                if declaration.contentType == .journal {
                    let journalEntry = JournalEntry(context: context)
                    journalEntry.id = UUID()
                    journalEntry.text = declaration.text
                    journalEntry.book = declaration.book
                    journalEntry.bibleVerseText = declaration.bibleVerseText
                    journalEntry.category = declaration.category.rawValue
                    journalEntry.isFavorite = declaration.isFavorite ?? false
                    journalEntry.createdAt = declaration.lastEdit ?? Date()
                    journalEntry.lastModified = declaration.lastEdit ?? Date()
                } else if declaration.contentType == .affirmation {
                    let affirmationEntry = AffirmationEntry(context: context)
                    affirmationEntry.id = UUID()
                    affirmationEntry.text = declaration.text
                    affirmationEntry.book = declaration.book
                    affirmationEntry.bibleVerseText = declaration.bibleVerseText
                    affirmationEntry.category = declaration.category.rawValue
                    affirmationEntry.isFavorite = declaration.isFavorite ?? false
                    affirmationEntry.createdAt = declaration.lastEdit ?? Date()
                    affirmationEntry.lastModified = declaration.lastEdit ?? Date()
                }
            }
            
            try context.save()
        }
    }
    
    // MARK: - Clean Up Legacy Data
    func cleanUpLegacyData() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let declarationsURL = documentsDirectory.appendingPathComponent("declarations.json")
        
        do {
            if FileManager.default.fileExists(atPath: declarationsURL.path) {
                try FileManager.default.removeItem(at: declarationsURL)
            }
        } catch {
            print("Failed to clean up legacy data: \(error)")
        }
    }
}

// MARK: - Error Types
enum DataMigrationError: Error, LocalizedError {
    case migrationFailed
    case contextNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .migrationFailed:
            return "Data migration failed"
        case .contextNotAvailable:
            return "Core Data context not available"
        }
    }
}