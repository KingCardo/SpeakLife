//
//  AffirmationRepository.swift
//  SpeakLife
//
//  Affirmation Repository Implementation
//

import Foundation
import CoreData
import Combine

protocol AffirmationRepositoryProtocol: Repository where Entity == AffirmationEntry {
    func fetchFavorites() async throws -> [AffirmationEntry]
    func toggleFavorite(_ entry: AffirmationEntry) async throws
    func search(text: String) async throws -> [AffirmationEntry]
    func fetchByCategory(_ category: String) async throws -> [AffirmationEntry]
}

final class AffirmationRepository: AffirmationRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    private let notificationCenter: NotificationCenter
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         notificationCenter: NotificationCenter = .default) {
        self.context = context
        self.notificationCenter = notificationCenter
    }
    
    // MARK: - Create
    func create(_ entity: AffirmationEntry) async throws {
        try await context.perform {
            entity.id = UUID()
            entity.createdAt = Date()
            entity.lastModified = Date()
            try self.context.save()
        }
    }
    
    // MARK: - Update
    func update(_ entity: AffirmationEntry) async throws {
        try await context.perform {
            entity.lastModified = Date()
            try self.context.save()
        }
    }
    
    // MARK: - Delete
    func delete(_ entity: AffirmationEntry) async throws {
        try await context.perform {
            self.context.delete(entity)
            try self.context.save()
        }
    }
    
    // MARK: - Fetch
    func fetch(predicate: NSPredicate? = nil) async throws -> [AffirmationEntry] {
        try await context.perform {
            let request = AffirmationEntry.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = [NSSortDescriptor(keyPath: \AffirmationEntry.lastModified, ascending: false)]
            return try self.context.fetch(request)
        }
    }
    
    // MARK: - Fetch by ID
    func fetchById(_ id: UUID) async throws -> AffirmationEntry? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try await fetch(predicate: predicate)
        return results.first
    }
    
    // MARK: - Observe All
    func observeAll() -> AnyPublisher<[AffirmationEntry], Never> {
        let request = AffirmationEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AffirmationEntry.lastModified, ascending: false)]
        
        let initialResults = (try? context.fetch(request)) ?? []
        
        return notificationCenter.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .compactMap { _ in
                try? self.context.fetch(request)
            }
            .prepend(initialResults)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Favorites
    func fetchFavorites() async throws -> [AffirmationEntry] {
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        return try await fetch(predicate: predicate)
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ entry: AffirmationEntry) async throws {
        try await context.perform {
            entry.isFavorite.toggle()
            entry.lastModified = Date()
            try self.context.save()
        }
    }
    
    // MARK: - Search
    func search(text: String) async throws -> [AffirmationEntry] {
        let predicate = NSPredicate(format: "text CONTAINS[cd] %@", text)
        return try await fetch(predicate: predicate)
    }
    
    // MARK: - Fetch by Category
    func fetchByCategory(_ category: String) async throws -> [AffirmationEntry] {
        let predicate = NSPredicate(format: "category == %@", category)
        return try await fetch(predicate: predicate)
    }
}