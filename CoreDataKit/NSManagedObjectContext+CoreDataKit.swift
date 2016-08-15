//
//  NSManagedObjectContext+CoreDataKit.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    /// Returns true if the context managed to save
    /// or eats any error and returns false if there were either
    /// no changes or it failed to save
    func attemptToSave() -> Bool {
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
    
    /// Attempts to execute the fetch request and return the array of objects if there were any found
    /// and they could be casted to the inferred type.
    ///
    /// Returns nil if there was a request error or the objects could not be casted
    public func execute<T: NSManagedObject>(fetchRequest fetchRequest: NSFetchRequest) -> [T]? {
        do {
            let rawObjects = try self.executeFetchRequest(fetchRequest)
            let objects = rawObjects as? [T]
            if objects == nil { debugPrint("cast to type [\(T.self)] failed for fetch request execute") }
            return objects
        } catch {
            debugPrint("fetch request failed: \(fetchRequest)")
            return nil
        }
    }
    
    /// Executes a fetch request and takes the first object found. Nil if the underlying fetch request
    /// failed to find any objects or cast to the inferred type.
    public func executeAndTakeFirst<T: NSManagedObject>(fetchRequest fetchRequest: NSFetchRequest) -> T? {
        guard let objects: [T] = self.execute(fetchRequest: fetchRequest) else { return nil }
        return objects.first
    }
}