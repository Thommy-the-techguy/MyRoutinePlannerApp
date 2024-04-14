//
//  Priority+CoreDataProperties.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 13.04.24.
//
//

import Foundation
import CoreData


extension Priority {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Priority> {
        return NSFetchRequest<Priority>(entityName: "Priority")
    }

    @NSManaged public var priorityLevel: Int64
    @NSManaged public var priorityColor: String?
    @NSManaged public var priorityTaskRel: MyTask?

}

extension Priority : Identifiable {

}
