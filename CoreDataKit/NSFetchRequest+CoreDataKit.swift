//
//  NSFetchRequest+CoreDataKit.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData


/// Creates a fetch request with no predicate which will return all objects of the given type
func fetchAll<T: NSManagedObject>(of type: T.Type) -> NSFetchRequest<NSFetchRequestResult> {
    return NSFetchRequest(entityName: String(describing: T.self))
}

