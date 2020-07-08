//: #### Other pages
//:
//: * [Demo for `colors` parser](Colors-Demo)
//: * Demo for `coredata` parser
//: * [Demo for `fonts` parser](Fonts-Demo)
//: * [Demo for `ib` parser](InterfaceBuilder-Demo)
//: * [Demo for `json` parser](JSON-Demo)
//: * [Demo for `plist` parser](Plist-Demo)
//: * [Demo for `strings` parser](Strings-Demo)
//: * [Demo for `xcassets` parser](XCAssets-Demo)
//: * [Demo for `yaml` parser](YAML-Demo)

//: #### Example of code generated by `coredata` parser with "swift5" template

import CoreData
import Foundation

public enum IntegerEnum: Int16 {
	case test1
	case test2
}
public enum StringEnum: String {
	case test1
	case test2
	case test3
}

// MARK: - MainEntity

@objc(MainEntity)
internal class MainEntity: NSManagedObject {
  internal class var entityName: String {
    return "MainEntity"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<MainEntity> {
    return NSFetchRequest<MainEntity>(entityName: entityName)
  }

  // swiftlint:disable implicitly_unwrapped_optional
  @NSManaged internal var attributedString: NSAttributedString?
  @NSManaged internal var binaryData: Data?
  @NSManaged internal var boolean: Bool
  @NSManaged internal var date: Date?
  @NSManaged internal var decimal: NSDecimalNumber?
  @NSManaged internal var double: Double
  @NSManaged internal var float: Float
  @NSManaged internal var int16: Int16
  @NSManaged internal var int32: Int32
  @NSManaged internal var int64: Int64
  internal var integerEnum: IntegerEnum {
    get {
      let key = "integerEnum"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      guard let value = primitiveValue(forKey: key) as? IntegerEnum.RawValue,
        let result = IntegerEnum(rawValue: value) else {
        fatalError("Could not convert value for key '\(key)' to type 'IntegerEnum'")
      }
      return result
    }
    set {
      let key = "integerEnum"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue.rawValue, forKey: key)
    }
  }
  @NSManaged internal var string: String
  internal var stringEnum: StringEnum? {
    get {
      let key = "stringEnum"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      guard let value = primitiveValue(forKey: key) as? StringEnum.RawValue else {
        return nil
      }
      return StringEnum(rawValue: value)
    }
    set {
      let key = "stringEnum"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue?.rawValue, forKey: key)
    }
  }
  @NSManaged internal var transformable: AnyObject?
  @NSManaged internal var transient: String?
  @NSManaged internal var uri: URL?
  @NSManaged internal var uuid: UUID?
  // swiftlint:enable implicitly_unwrapped_optional
}

//: #### Usage Example

let container: NSPersistentContainer = createContainer()
let context: NSManagedObjectContext = container.viewContext

let item = MainEntity(context: context)
item.date = Date()
item.boolean = true
item.string = "test"

do {
  let newObjectsCount = context.insertedObjects.count
  print("Preparing to save \(newObjectsCount)")

  try context.save()
  print("Saved")
} catch {
  fatalError("Unresolved error \(error)")
}

do {
    let fetchRequest = MainEntity.makeFetchRequest()
    let count = try context.count(for: fetchRequest)
    print("Found \(count) assets")
} catch {
    fatalError("Unresolved error \(error)")
}
