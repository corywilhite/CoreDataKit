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
public struct CoreDataStoreType: RawRepresentable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static let sqlite = CoreDataStoreType(rawValue: NSSQLiteStoreType)
    public static let inMemory = CoreDataStoreType(rawValue: NSInMemoryStoreType)
    public static let binary = CoreDataStoreType(rawValue: NSBinaryStoreType)
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
}
