//
//  Reminder+CoreDataProperties.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 13.04.24.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var reminderDate: Date?
    @NSManaged public var reminderIdentifier: String?
    @NSManaged public var reminderTaskRel: MyTask?

}

extension Reminder : Identifiable {

}
