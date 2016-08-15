# CoreDataKit
Easily spin up a CoreData stack and create type safe interfaces for retrieving managed objects

## Usage

### CoreDataManager
After creating an xcdatamodel file and NSManagedObject subclasses, here's how to use the `CoreDataManager` and `CoreDataInterface` classes.

the `CoreDataManager` is responsible for storing the models to disk, adding persistent store coordinators with the given type, and providing managed object contexts to perform work with.

You can extend the CoreDataManager to create any static shared instances. Example:

```swift
extension CoreDataManager {
  static let shared = CoreDataManager(modelName: "Your-Model-Name", storeType: .sqlite, bundles: [.mainBundle()])
}
```

to which the two context types can be accessed by calling:
```swift
let mainContext = CoreDataManager.shared.mainContext 
```
or
```swift
let privateContext = CoreDataManager.shared.privateContext
```

### CoreDataInterface

A `CoreDataInterface` gets created with a context and a generic NSManagedObject type.

Given the custom subclass `Place`:

```swift
let interface = CoreDataInterface<Place>(context: CoreDataManager.shared.mainContext)
```

to which any of the CoreDataInterfaceType functions can be called on it.
