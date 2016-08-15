//
//  CoreDataInterface.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData

/// Generic implementation of CoreDataInterfaceType using a generic type parameter constrained to NSManagedObjects
///
/// NOTE: Should probably rename the type to ManagedObjectContextInterface
struct CoreDataInterface<T: NSManagedObject>: CoreDataInterfaceType {
    
    // since all methods come with default extensions
    // we can't infer the associatedType and thus have to
    // explicitly typealias
    typealias ObjectType = T
    
    let context: NSManagedObjectContext // init(context:)
}

/// CoreData Interface protocol for defining a type-safe structure used to access objects that belong to an NSManagedObjectContext
///
/// This protocol allows type constrained extensions to be used easily
protocol CoreDataInterfaceType {
    associatedtype ObjectType: NSManagedObject
    var context: NSManagedObjectContext { get }
    
    func defaultRequest() -> NSFetchRequest
    func fetch(requestBuilder: (objectType: ObjectType.Type) -> NSFetchRequest) -> [ObjectType]?
    func count(for fetchRequest: NSFetchRequest) -> Int
    func count(for requestBuilder: (objecType: ObjectType.Type) -> NSFetchRequest) -> Int
    func insert(objectType: ObjectType.Type, objectConfiguration: ((newObject: ObjectType) -> ObjectType)?) -> ObjectType
    func deleteAll()
    func save() -> Bool
}

// This extension provides all function implementations of the interface
extension CoreDataInterfaceType {
    func defaultRequest() -> NSFetchRequest {
        return NSFetchRequest.allRequest(forType: ObjectType.self)
    }
    
    /// Fetches all objects found by the request built by the builder function.
    /// The fetch occurs on this interface's context
    func fetch(requestBuilder: (objectType: ObjectType.Type) -> NSFetchRequest) -> [ObjectType]? {
        let request = requestBuilder(objectType: ObjectType.self)
        return context.execute(fetchRequest: request)
    }
    
    /// Insets a new object into the context and allows an optional configuration block
    /// to be passed in to set the new object up before its returned
    ///
    /// returning the object from the configuration block allows more methods to be chained
    func insert(objectType: ObjectType.Type, objectConfiguration: ((newObject: ObjectType) -> ObjectType)? = nil) -> ObjectType {
        guard let entityDescription = NSEntityDescription.entityForName(String(ObjectType), inManagedObjectContext: context) else {
            fatalError("Failed to retrieve entity description with name \(String(ObjectType))")
        }
        
        guard let newObject = NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: context) as? ObjectType else {
            fatalError("Failed to insert entity (with description \(entityDescription)) into MOC")
        }
        
        let configured = objectConfiguration?(newObject: newObject)
        
        return configured ?? newObject
    }
    
    /// Returns the count of the passed in request
    ///
    /// If an error occurs the count will be returned as 0
    func count(for fetch: NSFetchRequest) -> Int {
        var error: NSError?
        let count = context.countForFetchRequest(fetch, error: &error)
        
        if let error = error {
            debugPrint(error.localizedDescription)
            return 0
        }
        
        return count
    }
    
    /// Returns the count of the request returned by the passed in builder function
    ///
    /// If an error occurs the count will be returned as 0
    func count(for requestBuilder: (objecType: ObjectType.Type) -> NSFetchRequest) -> Int {
        let request = requestBuilder(objecType: ObjectType.self)
        
        var error: NSError?
        let count = context.countForFetchRequest(request, error: &error)
        
        if let error = error {
            debugPrint(error.localizedDescription)
            return 0
        }
        
        return count
    }
    
    /// Fetches the first object found in the interface's context using the default request
    func fetchFirst() -> ObjectType? {
        return fetch { (objectType) -> NSFetchRequest in
            return self.defaultRequest()
            }?.first
    }
    
    /// Fetches all of objects in the interface's context using the default request
    func fetchAll() -> [ObjectType]? {
        return fetch { (objectType) -> NSFetchRequest in
            return self.defaultRequest()
        }
    }
    
    /// Deletes all objects accessed by this interface's default request on this context
    func deleteAll() {
        fetchAll()?.forEach { context.deleteObject($0) }
    }
    
    /// Attempts to save on this context
    func save() -> Bool {
        return context.attemptToSave()
    }
}
