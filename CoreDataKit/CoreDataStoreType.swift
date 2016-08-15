//
//  CoreDataStoreType.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData

// Type safe helping wrapper around the CoreData persistent store type string constants
//
// Hashable conformance allows for a CoreDataStoreType to be used in a switch statement
struct CoreDataStoreType: RawRepresentable, Hashable {
    let rawValue: String
    
    static let sqlite = CoreDataStoreType(rawValue: NSSQLiteStoreType)
    static let inMemory = CoreDataStoreType(rawValue: NSInMemoryStoreType)
    static let binary = CoreDataStoreType(rawValue: NSBinaryStoreType)
    
    var hashValue: Int {
        return rawValue.hashValue
    }
}