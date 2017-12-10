import Foundation
import UIKit

class AppCoordinator {

    var window: UIWindow?
    var rootNavController: UINavigationController?
    let dataManager: DataManager

    init(window: UIWindow) {
        self.window = window
        dataManager = DataManager()
    }

    func start() {
        customize()

        let notesVC = NotesTableViewController.makeFromStoryboard()
        notesVC.container = dataManager.persistentContainer
        notesVC.delegate = self
        rootNavController = UINavigationController(rootViewController: notesVC)
        window?.rootViewController = rootNavController
        window?.makeKeyAndVisible()
    }

    private func customize() {
        let navBarProxy = UINavigationBar.appearance()
        navBarProxy.barTintColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.00)
        navBarProxy.tintColor = UIColor.white
        navBarProxy.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
}

extension AppCoordinator: NotesTableViewControllerDelegate {

    func notesTableViewControllerDidTapAddNote(vc: NotesTableViewController) {
        dataManager.addNewNote() { note in
            guard let note = note else {
                print("Error adding new note")
                return
            }
            presentNoteDetailViewController(with: note)
        }
    }

    func notesTableViewController(vc: NotesTableViewController, didSelect note: Note) {
        presentNoteDetailViewController(with: note)
    }

    func presentNoteDetailViewController(with note: Note) {
        let noteDetailVC = NoteDetailViewController.makeFromStoryboard()
        noteDetailVC.note = note
        noteDetailVC.dataManager = dataManager
        rootNavController?.pushViewController(noteDetailVC, animated: true)
    }
}
