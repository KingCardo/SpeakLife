//
//  PersistenceController.swift
//  SpeakLife
//
//  Core Data Stack with iCloud Sync Configuration
//

import CoreData
import CloudKit
import UIKit

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
            
            // Configure for CloudKit sync with performance optimizations
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // Performance optimization: Enable WAL mode for better concurrent access
            description.setOption(["journal_mode": "WAL"] as NSDictionary, forKey: NSSQLitePragmasOption)
            
            // Set CloudKit container options with optimizations
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.franchiz.speaklife")
            options.databaseScope = .private
            
            description.cloudKitContainerOptions = options
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("RWRW: Persistent store load FAILED - \(error.localizedDescription)")
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                // In production, log error but don't crash the app
                print("Core Data error: \(error), \(error.userInfo)")
                #endif
            } else {
                print("RWRW: Persistent store loaded successfully")
                print("RWRW: Store URL: \(storeDescription.url?.path ?? "No URL")")
                print("RWRW: CloudKit enabled: \(storeDescription.cloudKitContainerOptions != nil)")
                
                // Check CloudKit account status
                self.checkCloudKitAccountStatus()
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Configure merge policy for conflict resolution
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Performance optimizations for faster sync
        container.viewContext.undoManager = nil // Disable undo for better performance
        
        // Setup CloudKit sync event notifications
        setupCloudKitSyncLogging()
        
        // Setup background sync optimization
        setupBackgroundSyncOptimization()
        
        // Force initial CloudKit import check on fresh install
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkForInitialCloudKitImport()
        }
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("RWRW: Context saved successfully - changes committed to CloudKit sync")
        } catch {
            let nsError = error as NSError
            print("RWRW: Context save failed - \(nsError.localizedDescription)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // MARK: - CloudKit Sync Logging
    private func setupCloudKitSyncLogging() {
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main
        ) { notification in
            print("RWRW: CloudKit remote change notification received - \(notification.userInfo ?? [:])")
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NSPersistentCloudKitContainerEventChangedNotification"),
            object: container,
            queue: .main
        ) { notification in
            if let event = notification.userInfo?["event"] as? NSPersistentCloudKitContainer.Event {
                self.logCloudKitEvent(event)
            }
        }
    }
    
    private func logCloudKitEvent(_ event: NSPersistentCloudKitContainer.Event) {
        let eventType = switch event.type {
        case .setup: "Setup"
        case .import: "Import"
        case .export: "Export"
        @unknown default: "Unknown"
        }
        
        print("RWRW: CloudKit \(eventType) - Started: \(event.startDate), Ended: \(event.endDate?.description ?? "In Progress")")
        
        if let error = event.error {
            print("RWRW: CloudKit \(eventType) Error - \(error.localizedDescription)")
        } else if event.endDate != nil {
            print("RWRW: CloudKit \(eventType) Success")
        }
    }
    
    private func checkCloudKitAccountStatus() {
        let container = CKContainer(identifier: "iCloud.com.franchiz.speaklife")
        
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("RWRW: CloudKit account status check FAILED - \(error.localizedDescription)")
                } else {
                    let statusString = switch status {
                    case .available: "Available"
                    case .noAccount: "No Account"
                    case .restricted: "Restricted"
                    case .couldNotDetermine: "Could Not Determine"
                    case .temporarilyUnavailable: "Temporarily Unavailable"
                    @unknown default: "Unknown"
                    }
                    print("RWRW: CloudKit account status: \(statusString)")
                    
                    if status != .available {
                        print("RWRW: ⚠️ CloudKit not available - data will not sync")
                    }
                }
            }
        }
    }
    
    // MARK: - Background Sync Optimization
    private func setupBackgroundSyncOptimization() {
        // Trigger sync when app becomes active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("RWRW: App became active - requesting CloudKit sync")
            self?.requestSyncIfNeeded()
        }
        
        // Trigger sync when app enters background
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("RWRW: App entering background - ensuring sync completion")
            self?.requestSyncIfNeeded()
        }
    }
    
    private func requestSyncIfNeeded() {
        // Force a sync by triggering export if there are pending changes
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("RWRW: Proactive sync triggered")
            } catch {
                print("RWRW: Proactive sync failed - \(error.localizedDescription)")
            }
        }
        
        // Also request import of remote changes
        container.viewContext.refreshAllObjects()
    }
    
    // MARK: - Initial CloudKit Import Check
    private func checkForInitialCloudKitImport() {
        print("RWRW: Checking for initial CloudKit import...")
        
        let context = container.viewContext
        context.perform {
            // Check if we have any local data
            let journalRequest = JournalEntry.fetchRequest()
            let affirmationRequest = AffirmationEntry.fetchRequest()
            
            do {
                let journalCount = try context.count(for: journalRequest)
                let affirmationCount = try context.count(for: affirmationRequest)
                
                print("RWRW: Local data count - Journals: \(journalCount), Affirmations: \(affirmationCount)")
                
                if journalCount == 0 && affirmationCount == 0 {
                    print("RWRW: No local data found - forcing CloudKit import...")
                    
                    // Force CloudKit to import by refreshing context
                    DispatchQueue.main.async {
                        self.container.viewContext.refreshAllObjects()
                        
                        // Also try to trigger import by fetching from CloudKit
                        self.forceCloudKitImport()
                    }
                } else {
                    print("RWRW: Local data exists - no import needed")
                }
            } catch {
                print("RWRW: Error checking local data count - \(error.localizedDescription)")
            }
        }
    }
    
    private func forceCloudKitImport() {
        print("RWRW: Forcing CloudKit import...")
        
        // Create a background context to trigger import
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.perform {
            // Perform fetch operations to trigger CloudKit import
            let journalRequest = JournalEntry.fetchRequest()
            let affirmationRequest = AffirmationEntry.fetchRequest()
            
            do {
                let journals = try backgroundContext.fetch(journalRequest)
                let affirmations = try backgroundContext.fetch(affirmationRequest)
                
                print("RWRW: Background fetch results - Journals: \(journals.count), Affirmations: \(affirmations.count)")
                
                // Save context to ensure changes propagate
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
                
                // Wait a bit then check main context
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.recheckAfterImport()
                }
                
            } catch {
                print("RWRW: Error during forced import - \(error.localizedDescription)")
            }
        }
    }
    
    private func recheckAfterImport() {
        print("RWRW: Rechecking data after forced import...")
        
        let context = container.viewContext
        context.perform {
            let journalRequest = JournalEntry.fetchRequest()
            let affirmationRequest = AffirmationEntry.fetchRequest()
            
            do {
                let journalCount = try context.count(for: journalRequest)
                let affirmationCount = try context.count(for: affirmationRequest)
                
                print("RWRW: Data count after import attempt - Journals: \(journalCount), Affirmations: \(affirmationCount)")
                
                if journalCount > 0 || affirmationCount > 0 {
                    print("RWRW: ✅ CloudKit import successful!")
                    
                    // Notify UI to refresh
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("CloudKitImportCompleted"), object: nil)
                    }
                } else {
                    print("RWRW: ⚠️ No data imported - may need manual sync or CloudKit account check")
                }
            } catch {
                print("RWRW: Error rechecking data - \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Manual Sync Request
    func requestImmediateSync() {
        print("RWRW: Manual sync requested")
        
        // Save any pending changes
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
        
        // Refresh to pull remote changes
        container.viewContext.refreshAllObjects()
        
        // Force merge of remote changes
        container.viewContext.perform {
            // This triggers CloudKit to check for remote changes
            _ = try? self.container.viewContext.fetch(JournalEntry.fetchRequest())
            _ = try? self.container.viewContext.fetch(AffirmationEntry.fetchRequest())
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
