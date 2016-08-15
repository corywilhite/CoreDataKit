//
//  CoreDataManager.swift
//  CoreDataKit
//
//  Created by Cory Wilhite on 8/15/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import Foundation
import CoreData


private extension NSPersistentStoreCoordinator {
    // Helper method for type safe initialization of a persistent store with a CoreDataStoreType
    func addPersistentStore(with type: CoreDataStoreType, configuration: String?, URL: NSURL?, options: [NSObject: AnyObject]?) throws {
        try self.addPersistentStoreWithType(type.rawValue, configuration: configuration, URL: URL, options: options)
    }
}

/// Class that will spin up a full Core Data stack from all managed object models
/// in the bundle that gets passed in to the init.
final class CoreDataManager {
    
    /// The name of the store that will be saved to disk after being created
    let modelName: String
    let bundles: [NSBundle]
    
    /// Developers should not change these options. They can be changed for testing purposes
    internal(set) var options = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    /// Currently only supports being init with a type of .sqlite or .inMemory for CoreDataStoreType
    init(modelName: String, storeType: CoreDataStoreType, bundles: [NSBundle] = [.mainBundle()]) {
        self.modelName = modelName
        self.bundles = bundles
        
        switch storeType {
        case CoreDataStoreType.sqlite:
            try! persistentStoreCoordinator.addPersistentStore(
                with: storeType,
                configuration: nil,
                URL: NSURL(fileURLWithPath: storeURL),
                options: options
            )
            
        case CoreDataStoreType.inMemory:
            try! persistentStoreCoordinator.addPersistentStore(
                with: storeType,
                configuration: nil,
                URL: nil,
                options: options
            )
            
        default:
            fatalError("Unsupported CoreData storeType (\(storeType)) passed in. should never hit this case.")
        }
    }
    
    lazy var storeURL: String = {
        guard let userDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as NSString? else { fatalError("Unable to find user's domain directory") }
        return userDirectory.stringByAppendingPathComponent("\(self.modelName).sqlite") as String
    }()
    
    lazy private(set) var managedObjectModel: NSManagedObjectModel =  {
        guard let model = NSManagedObjectModel.mergedModelFromBundles(self.bundles) else { fatalError("Unable to create merged model from bundles \(self.bundles)") }
        return model
    }()
    
    lazy private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        return NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    }()
    
    /// Factory method for generating a managed object context using this manager's NSPersistentStoreCoordinator
    func context(for type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: type)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
    
    /// The main context used for accessing objects using a main queue concurrency type
    lazy private(set) var mainContext: NSManagedObjectContext = self.context(for: .MainQueueConcurrencyType)
    
    /// A default private context if needed for background processes using private queue concurrency type
    lazy private(set) var privateContext: NSManagedObjectContext = self.context(for: .PrivateQueueConcurrencyType)
    
}
