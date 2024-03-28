//
//  KeyValuePairsWithFlag.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 17.02.24.
//

import Foundation

struct KeyValuePairsWithFlag<K: Codable, V: Codable, P: Codable> {
    private var arrayOfKeys: [K] = [] // Messages, can be something else
    private var arrayOfValues: [V] = [] // Date, can be something else
    private var arrayOfReminders: [Reminder?] = [] // nil = no reminder
    private var arrayOfPriorities: [P] = [] // priorities
    
    var count: Int {
        get {
            return arrayOfKeys.count
        }
    }
    
    init() {
        
    }
    
    init(arrayOfKeys: [K], arrayOfValues: [V], arrayOfReminders: [Reminder?], arrayOfPriorities: [P]) {
        if (arrayOfKeys.count != arrayOfValues.count) || (arrayOfValues.count != arrayOfReminders.count) || (arrayOfKeys.count != arrayOfReminders.count) || (arrayOfKeys.count != arrayOfPriorities.count) || (arrayOfValues.count != arrayOfPriorities.count) || (arrayOfReminders.count != arrayOfPriorities.count) {
            fatalError("CustomKeyValuePairs Error: all array sizes should be equal (arrayOfKeys = arrayOfValues = arrayOfReminders = arrayOfPriorities)!")
        } else {
            self.arrayOfKeys = arrayOfKeys
            self.arrayOfValues = arrayOfValues
            self.arrayOfReminders = arrayOfReminders
            self.arrayOfPriorities = arrayOfPriorities
        }
    }
    
    mutating func append(key: K, value: V, withReminder: Reminder?, priority: P) {
        self.arrayOfKeys.append(key)
        self.arrayOfValues.append(value)
        self.arrayOfReminders.append(withReminder)
        self.arrayOfPriorities.append(priority)
    }
    
    mutating func removeKeyAndValue(for index: Int) {
        self.arrayOfKeys.remove(at: index)
        self.arrayOfValues.remove(at: index)
        self.arrayOfReminders.remove(at: index)
        self.arrayOfPriorities.remove(at: index)
    }
    
    mutating func insert(at: Int, key: K, value: V, withReminder: Reminder?, priority: P) {
        self.arrayOfKeys.insert(key, at: at)
        self.arrayOfValues.insert(value, at: at)
        self.arrayOfReminders.insert(withReminder, at: at)
        self.arrayOfPriorities.insert(priority, at: at)
    }
    
    mutating func setKeyAndValue(for index: Int, key: K, value: V, withReminder: Reminder?, priority: P) {
        self.removeKeyAndValue(for: index)
        self.insert(at: index, key: key, value: value, withReminder: withReminder, priority: priority)
    }
    
    mutating func setReminder(for index: Int, withReminder: Reminder?) {
        self.arrayOfReminders[index] = withReminder
    }
    
    func getKey(for index: Int) -> K {
        return self.arrayOfKeys[index]
    }
    
    func getValue(for index: Int) -> V {
        return self.arrayOfValues[index]
    }
    
    func getReminder(for index: Int) -> Reminder? {
        return self.arrayOfReminders[index]
    }
    
    func getPriority(for index: Int) -> P {
        return self.arrayOfPriorities[index]
    }
    
    func getKeyAndValue(for index: Int) -> (key: K, value: V, reminder: Reminder?, priority: P) {
        let key = self.arrayOfKeys[index]
        let value = self.arrayOfValues[index]
        let reminder = self.arrayOfReminders[index]
        let priority = self.arrayOfPriorities[index]
        
        return (key, value, reminder, priority)
    }
}

extension KeyValuePairsWithFlag: Codable {
    
}
