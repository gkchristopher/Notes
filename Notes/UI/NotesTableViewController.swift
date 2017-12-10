import UIKit
import CoreData

protocol NotesTableViewControllerDelegate {
    func notesTableViewControllerDidTapAddNote(vc: NotesTableViewController)
    func notesTableViewController(vc: NotesTableViewController, didSelect note: Note)
}

final class NotesTableViewController: UITableViewController, StoryboardInitializable {

    let reuseIdentifier = "NoteCell"
    var delegate: NotesTableViewControllerDelegate?
    let dateFormatter = DateFormatter()
    var fetchedResultsController: NSFetchedResultsController<Note>?
    var container: NSPersistentContainer? {
        didSet {
            if container != nil {
                loadNotes()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = addButtonItem()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    func loadNotes() {
        guard let context = container?.viewContext else { return }

        let fetchRequest : NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modifiedAt", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch notes: \(error)")
        }

        tableView.reloadData()
    }

    private func addButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }

    @objc func addNote() {
        delegate?.notesTableViewControllerDidTapAddNote(vc: self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoteTableViewCell

        let note = fetchedResultsController!.object(at: indexPath)
        cell.configure(with: note, dateFormatter: dateFormatter)

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = fetchedResultsController?.object(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.notesTableViewController(vc: self, didSelect: note)
    }
}

extension NotesTableViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadNotes()
    }
}
