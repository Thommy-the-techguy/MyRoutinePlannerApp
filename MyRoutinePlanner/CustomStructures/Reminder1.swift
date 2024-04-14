//
//  Reminder.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 25.03.24.
//

import Foundation

final class Reminder1 {
    var reminderDate: Date
    var reminderIdentifier: String
    
    init(reminderDate: Date, reminderIdentifier: String) {
        self.reminderDate = reminderDate
        self.reminderIdentifier = reminderIdentifier
    }
}

extension Reminder1: Codable {
    
}

extension Reminder1: Equatable {
    static func == (lhs: Reminder1, rhs: Reminder1) -> Bool {
        return lhs.reminderDate == rhs.reminderDate && lhs.reminderIdentifier == rhs.reminderIdentifier
    }
}
