//
//  CoreDataInterface.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData

class Place: NSManagedObject { }

public extension NSManagedObjectContext {
    
    public func interface<T: NSManagedObject>(for type: T.Type) -> ContextInterface<T> {
        return ContextInterface(context: self)
    }
    
    /// Returns true if the context managed to save
    /// or eats any error and returns false if there were either
    /// no changes or it failed to save
    @discardableResult
    public func attemptToSave() -> Bool {
        if hasChanges {
            do {
                try save()
                return true
            } catch {
                print(error)
                return false
            }
        } else {
            return false
        }
    }
    
}


fileprivate extension NSManagedObject {
    static func allRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        return NSFetchRequest(entityName: String(describing: type(of: self)))
    }
}

/// Generic implementation of CoreDataInterfaceType using a generic type parameter constrained to NSManagedObjects
public struct ContextInterface<T: NSManagedObject> {
    
    public let context: NSManagedObjectContext // init(context:)
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public var baseRequest: NSFetchRequest<T> = T.allRequest()
    
    /// Fetches all objects found by the request built by the builder function.
    /// The fetch occurs on this interface's context
    public func fetch(_ requestBuilder: (_ objectType: T.Type) -> NSFetchRequest<T>) -> [T]? {
        return try? context.fetch(requestBuilder(T.self))
    }
    
    /// Insets a new object into the context and allows an optional configuration block
    /// to be passed in to set the new object up before its returned
    ///
    /// returning the object from the configuration block allows more methods to be chained
    @discardableResult
    public func insert(objectConfiguration: ((_ newObject: T) -> T)? = nil) -> T {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context) else {
            fatalError("Failed to retrieve entity description with name \(String(describing: T.self))")
        }
        
        let newObject = T(entity: entityDescription, insertInto: context)
        
        let configured = objectConfiguration?(newObject)
        
        context.attemptToSave()
        
        return configured ?? newObject
        
        
    }
    
    /// Returns the count of the passed in request
    ///
    /// If an error occurs the count will be returned as 0
    public func count(for fetch: NSFetchRequest<T>) -> Int {
        
        do {
            let count = try context.count(for: fetch)
            return count
        } catch {
            print(error.localizedDescription)
            return 0
        }
        
    }
    
    /// Returns the count of the request returned by the passed in builder function
    ///
    /// If an error occurs the count will be returned as 0
    public func count(for requestBuilder: (_ objecType: T.Type) -> NSFetchRequest<T>) -> Int {
        
        let request = requestBuilder(T.self)
        
        do {
            let count = try context.count(for: request)
            
            return count
        } catch {
            print(error.localizedDescription)
            return 0
        }
        
    }
    
    /// Fetches the first object found in the interface's context using the default request
    public func fetchFirst() -> T? {
        return fetch { (objectType) -> NSFetchRequest<T> in
            return self.baseRequest
        }?.first
    }
    
    /// Fetches all of objects in the interface's context using the default request
    public func fetchAll() -> [T]? {
        return fetch { (objectType) -> NSFetchRequest<T> in
            return self.baseRequest
        }
    }
    
    /// Deletes all objects accessed by this interface's default request on this context
    public func deleteAll() {
        fetchAll()?.forEach { context.delete($0) }
    }
    
    /// Attempts to save on this context
    public func save() -> Bool {
        return context.attemptToSave()
    }
}

