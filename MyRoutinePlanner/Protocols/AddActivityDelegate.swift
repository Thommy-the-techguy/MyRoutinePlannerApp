//
//  AddActivityDelegate.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 18.01.24.
//

import UIKit

protocol AddActivityDelegate: NSObject {
    func saveNewTask(_ newTask: String, taskDate: Date, withReminder: Bool)
    
    func editSelectedTask(taskText: String, taskDate: Date, withReminder: Bool)
}
