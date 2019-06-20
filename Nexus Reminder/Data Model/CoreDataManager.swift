//
//  CoreDataManager.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 6/19/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation

class CoreDataManager {
    lazy var fetchedResultsController: NSFetchedResultsController<Person> = {
        // Initialize Fetch Request
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        /*Before you can do anything with Core Data, you need a managed object context. */
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
         
         Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
         */
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController<Person>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        //    fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
}
