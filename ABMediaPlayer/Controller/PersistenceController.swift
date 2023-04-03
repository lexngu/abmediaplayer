//
//  Persistence.swift
//  ABMediaPlayer
//
//  Created by Alexander Nguyen on 31.03.23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<3 {
            let newItem = MediaItem(context: viewContext)
            newItem.id = UUID()
            newItem.name = "20230305_nono.mp4"
            newItem.size = 268343715
            newItem.format = "MPEG-4"
            newItem.duration = 2049.183
        }
        for i in 0..<3 {
            let newItem = AlignmentBase(context: viewContext)
            newItem.id = UUID()
            newItem.name = "Base \(i+1)"
        }
        let newMediaAlignment = MediaAlignment(context: viewContext)
        newMediaAlignment.id = UUID()
        do {
            newMediaAlignment.mediaItem = try viewContext.fetch(MediaItem.fetchRequest()).first!
            newMediaAlignment.alignmentBase = try viewContext.fetch(AlignmentBase.fetchRequest()).first!
        } catch {
            print("Error while creating media alignment entity: \(error)")
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ABMediaPlayer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
