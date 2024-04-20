////
////  CoreDataManager.swift
////  MyRoutinePlanner
////
////  Created by Артем Чижик on 13.04.24.
////
//
//import CoreData
//import UIKit
//
//class CoreDataManager {
//    static let shared = CoreDataManager()
//    
//    var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "TaskPlanner")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//    
//    var context: NSManagedObjectContext {
//        return self.persistentContainer.viewContext
//    }
//}
