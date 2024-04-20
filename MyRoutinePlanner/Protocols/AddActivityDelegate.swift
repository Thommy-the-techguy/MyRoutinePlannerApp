//
//  AddActivityDelegate.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 18.01.24.
//

import UIKit

protocol AddActivityDelegate: NSObject {
//    func saveNewTask(_ newTask: String, taskDate: Date, withReminder: Reminder?, priority: Priority)
    func saveNewTask(_ newTask: MyTask)
    
//    func editSelectedTask(taskText: String, taskDate: Date, withReminder: Reminder?, priority: Priority)
    func editSelectedTask(_ editedTask: MyTask)
}
