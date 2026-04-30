import CoreData
import CoreLocation
import Combine
import Foundation

final class PersistenceController {

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let bookmark = SavedIncident(context: ctx)
        bookmark.id           = "PREVIEW-001"
        bookmark.offense      = "THEFT/OTHER"
        bookmark.block        = "1000 BLOCK OF K ST NW"
        bookmark.ward         = 2
        bookmark.reportDate   = Date()
        bookmark.savedDate    = Date()
        try? ctx.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DCCrimeWatch")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
}

final class BookmarkRepository: ObservableObject {

    private let context: NSManagedObjectContext

    @Published private(set) var savedIDs: Set<String> = []

    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.context = context
        loadSavedIDs()
    }

    func isSaved(_ incident: CrimeIncident) -> Bool {
        savedIDs.contains(incident.id)
    }

    func removeByID(_ id: String) {
        let request: NSFetchRequest<SavedIncident> = SavedIncident.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        if let match = try? context.fetch(request).first {
            context.delete(match)
            saveContext()
        }
        savedIDs.remove(id)
    }

    func toggle(_ incident: CrimeIncident) {
        if isSaved(incident) {
            delete(incident)
        } else {
            save(incident)
        }
    }

    func fetchAll() -> [SavedIncident] {
        let request: NSFetchRequest<SavedIncident> = SavedIncident.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedIncident.savedDate, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    private func save(_ incident: CrimeIncident) {
        let entity = SavedIncident(context: context)
        entity.id           = incident.id
        entity.offense      = incident.offense.rawValue
        entity.block        = incident.block
        entity.ward         = Int16(incident.ward)
        entity.reportDate   = incident.reportDate
        entity.savedDate    = Date()
        entity.latitude     = incident.coordinate.latitude
        entity.longitude    = incident.coordinate.longitude
        entity.shift        = incident.shift.rawValue
        entity.method       = incident.method.rawValue

        saveContext()
        savedIDs.insert(incident.id)
    }

    private func delete(_ incident: CrimeIncident) {
        let request: NSFetchRequest<SavedIncident> = SavedIncident.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", incident.id)

        if let match = try? context.fetch(request).first {
            context.delete(match)
            saveContext()
        }
        savedIDs.remove(incident.id)
    }

    private func loadSavedIDs() {
        let request: NSFetchRequest<SavedIncident> = SavedIncident.fetchRequest()
        let results = (try? context.fetch(request)) ?? []
        savedIDs = Set(results.compactMap { $0.id })
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
