import Foundation
import CoreData
import UIKit

class DataManager {

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.automaticallyMergesChangesFromParent = true
            try! container.viewContext.setQueryGenerationFrom(.current)

            if let error = error as NSError? {
                print("Error creating persistent store: \(error)")
            } else {
                print("Core data loaded: \(storeDescription)")
                self.setupNotifications()
            }
        })
        return container
    }()

    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveContext), name: .UIApplicationWillTerminate, object: nil)
    }

    func addNewNote(completion: (Note?) -> Void) {
        let context = persistentContainer.viewContext
        let note = Note(context: context)
        note.id = UUID().uuidString
        note.createdAt = Date() as Date
        note.modifiedAt = Date() as Date
        note.text = "New note"

        do {
            try persistentContainer.viewContext.save()
        } catch {
            fatalError("Failed to save note: \(error.localizedDescription)")
        }

        completion(note)
    }

    func fetchNote(for id: String) -> Note? {
        return nil
    }

    // MARK: - Core Data Saving support

    @objc func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
