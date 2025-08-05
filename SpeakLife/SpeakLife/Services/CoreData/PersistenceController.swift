//
//  PersistenceController.swift
//  SpeakLife
//
//  Core Data Stack with iCloud Sync Configuration
//

import CoreData
import CloudKit

final class PersistenceController {
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Add sample data for previews
        for i in 0..<5 {
            let journalEntry = JournalEntry(context: viewContext)
            journalEntry.id = UUID()
            journalEntry.text = "Sample journal entry \(i)"
            journalEntry.category = "faith"
            journalEntry.createdAt = Date()
            journalEntry.lastModified = Date()
            journalEntry.isFavorite = false
            
            let affirmationEntry = AffirmationEntry(context: viewContext)
            affirmationEntry.id = UUID()
            affirmationEntry.text = "Sample affirmation \(i)"
            affirmationEntry.category = "faith"
            affirmationEntry.createdAt = Date()
            affirmationEntry.lastModified = Date()
            affirmationEntry.isFavorite = false
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "SpeakLife")
        
        if inMemory {
            container.persistentStoreDescriptions.forEach { storeDescription in
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
            }
        } else {
            // Create a store description if none exists
            if container.persistentStoreDescriptions.isEmpty {
                let description = NSPersistentStoreDescription()
                description.type = NSSQLiteStoreType
                description.shouldInferMappingModelAutomatically = true
                description.shouldMigrateStoreAutomatically = true
                container.persistentStoreDescriptions = [description]
            }
            
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve a persistent store description.")
            }
            
            // Configure for CloudKit sync
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // Set CloudKit container options
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.franchiz.speaklife")
            options.databaseScope = .private
            description.cloudKitContainerOptions = options
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, log error but don't crash the app
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                print("Core Data error: \(error), \(error.userInfo)")
                // Could fallback to local-only storage or show user message
                #endif
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Configure merge policy for conflict resolution
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // MARK: - Batch Delete
    func deleteAll<T: NSManagedObject>(_ type: T.Type) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try container.viewContext.execute(deleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
    }
}
