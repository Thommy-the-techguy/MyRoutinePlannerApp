//
//  MyTask+CoreDataProperties.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 13.04.24.
//
//

import Foundation
import CoreData


extension MyTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTask> {
        return NSFetchRequest<MyTask>(entityName: "MyTask")
    }

    @NSManaged public var taskTitle: String?
    @NSManaged public var taskDate: Date?
    @NSManaged public var taskOrderIndex: Int64
    @NSManaged public var taskReminderRel: Reminder?
    @NSManaged public var taskPriorityRel: Priority?

}

extension MyTask : Identifiable {

}

extension MyTask : Encodable {
    public func encode(to encoder: Encoder) throws {
        
    }
}

