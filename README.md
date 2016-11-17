# CoreDataKit
Easily spin up a CoreData stack and create type safe interfaces for retrieving managed objects

## Usage

### CoreDataManager
After creating an xcdatamodel file and NSManagedObject subclasses, here's how to use the `CoreDataManager` and `ContextInterface` classes.

the `CoreDataManager` is responsible for storing the models to disk, adding persistent store coordinators with the given type, and providing managed object contexts to perform work with.

You can extend the CoreDataManager to create any static shared instances. Example:

```swift
extension CoreDataManager {
  static let shared = CoreDataManager(modelName: "Your-Model-Name", storeType: .sqlite, bundles: [.otherBundle])
}

OR you can use the default argument of [.main] for bundles

extension CoreDataManager {
  static let shared = CoreDataManager(modelName: "Your-Model-Name", storeType: .sqlite)
}
```

to which the two context types can be accessed by calling:
```swift
let mainContext = CoreDataManager.shared.main
```
or
```swift
let privateContext = CoreDataManager.shared.private
```

### ContextInterface

A `ContextInterface` gets created with a context and a generic NSManagedObject type.

Given the custom subclass `Place`:

```swift

let manager = CoreDataManager(modelName: "Your-Model-Name", storeType: .sqlite)

// Main NSManagedObjectContext core data interface
let interface = manager.main.interface(for: Place.self) // ContextInterface<Place>

// Private NSManagedObjectContext core data interface
let interface = manager.private.interface(for: Place.self) // ContextInterface<Place>
```

A `ContextInterface` has one baseInterface property with several helper functions that provide modified behavior from that base request.

```swift
// takes a function that is capable of building a fetch request for the specific type, and returns an array if successful of that type of objects from CoreData
func fetch(_ requestBuilder: (_ objectType: T.Type) -> NSFetchRequest<T>) -> [T]?

// inserts a new object of the context's type and takes a configuration function to work with the newly inserted object. handles saving the new object after its been inserted and configured
func insert(objectConfiguration: ((_ newObject: T) -> T)? = nil) -> T

// wraps error handling by printing the error and defaulting to returning 0 for the count.
func count(for fetch: NSFetchRequest<T>) -> Int

// takes a fetch request builder function and returns the count of objects for that request
func count(for requestBuilder: (_ objecType: T.Type) -> NSFetchRequest<T>) -> Int

// gets the first object for the baseRequest property
func fetchFirst() -> T?

// fetches all of the baseRequest property
func fetchAll() -> [T]?

// deletes all of the baseRequest property
func deleteAll() -> Void

// attempts to save if there are any changes
func save() -> Bool

```
