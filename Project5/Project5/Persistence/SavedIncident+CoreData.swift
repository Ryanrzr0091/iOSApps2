import Foundation
import CoreData

@objc(SavedIncident)
public class SavedIncident: NSManagedObject {}

extension SavedIncident {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedIncident> {
        NSFetchRequest<SavedIncident>(entityName: "SavedIncident")
    }

    @NSManaged public var id: String?
    @NSManaged public var offense: String?
    @NSManaged public var block: String?
    @NSManaged public var ward: Int16
    @NSManaged public var reportDate: Date?
    @NSManaged public var savedDate: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var shift: String?
    @NSManaged public var method: String?
}

extension SavedIncident: Identifiable {}
