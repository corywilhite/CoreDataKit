//
//  NSFetchRequest+CoreDataKit.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData

public extension NSFetchRequest {
    /// Creates a fetch request with no predicate which will return all objects of the given type
    static func allRequest<T: NSManagedObject>(forType type: T.Type) -> NSFetchRequest {
        return NSFetchRequest(entityName: String(T))
    }
}