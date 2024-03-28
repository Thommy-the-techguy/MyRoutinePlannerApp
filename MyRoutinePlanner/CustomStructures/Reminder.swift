//
//  Reminder.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 25.03.24.
//

import Foundation

final class Reminder {
    var reminderDate: Date
    var reminderIdentifier: String
    
    init(reminderDate: Date, reminderIdentifier: String) {
        self.reminderDate = reminderDate
        self.reminderIdentifier = reminderIdentifier
    }
}

extension Reminder: Codable {
    
}

extension Reminder: Equatable {
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.reminderDate == rhs.reminderDate && lhs.reminderIdentifier == rhs.reminderIdentifier
    }
}
