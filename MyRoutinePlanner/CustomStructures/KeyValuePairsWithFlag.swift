//
//  KeyValuePairsWithFlag.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 17.02.24.
//

import Foundation

struct KeyValuePairsWithFlag<K: Codable & Equatable, V: Codable> {
    private var arrayOfKeys: [K] = [] // Messages, can be something else
    private var arrayOfValues: [V] = [] // Date, can be something else
//    private var arrayOfFlags: [Bool] = [] // for alarm
    private var arrayOfReminders: [Reminder?] = [] // nil = no reminder
    
    var count: Int {
        get {
            return arrayOfKeys.count
        }
    }
    
    init() {
        
    }
    
    init(arrayOfKeys: [K], arrayOfValues: [V], arrayOfReminders: [Reminder?]) {
        if (arrayOfKeys.count != arrayOfValues.count) || (arrayOfValues.count != arrayOfReminders.count) || (arrayOfKeys.count != arrayOfReminders.count) {
            fatalError("CustomKeyValuePairs Error: arrayOfKeys length should equal to arrayOfValues length!")
        } else {
            self.arrayOfKeys = arrayOfKeys
            self.arrayOfValues = arrayOfValues
            self.arrayOfReminders = arrayOfReminders
        }
    }
    
    mutating func append(key: K, value: V, withReminder: Reminder?) {
        self.arrayOfKeys.append(key)
        self.arrayOfValues.append(value)
        self.arrayOfReminders.append(withReminder)
    }
    
    mutating func removeKeyAndValue(for index: Int) {
        self.arrayOfKeys.remove(at: index)
        self.arrayOfValues.remove(at: index)
        self.arrayOfReminders.remove(at: index)
    }
    
    mutating func insert(at: Int, key: K, value: V, withReminder: Reminder?) {
        self.arrayOfKeys.insert(key, at: at)
        self.arrayOfValues.insert(value, at: at)
        self.arrayOfReminders.insert(withReminder, at: at)
    }
    
    mutating func setKeyAndValue(for index: Int, key: K, value: V, withReminder: Reminder?) {
        self.removeKeyAndValue(for: index)
        self.insert(at: index, key: key, value: value, withReminder: withReminder)
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
    
    func getKeyAndValue(for index: Int) -> (key: K, value: V, reminder: Reminder?) {
        let key = self.arrayOfKeys[index]
        let value = self.arrayOfValues[index]
        let reminder = self.arrayOfReminders[index]
        
        return (key, value, reminder)
    }
}

extension KeyValuePairsWithFlag: Codable {
    
}





extension KeyValuePairsWithFlag {
    subscript(_ key: K) -> V? {
        get {
            let indexOfItem = arrayOfKeys.firstIndex(where: {
                value in
                value == key
            })
            return arrayOfValues[indexOfItem!]
        }
        set {
            let indexOfItem = arrayOfKeys.firstIndex(where: {
                value in
                value == key
            })
            arrayOfValues[indexOfItem!] = newValue!
        }
    }
}

extension KeyValuePairsWithFlag {
    
}


//extension KeyValuePairsWithFlag {
//    // if key is type of String
//    func findByKey(_ key: String ) -> [(key: String, value: V)] { // key is message
//        if ((self.arrayOfKeys.first as? String) != nil) {
//            var result: [(key: String, value: V)]
//            
//            for arrayKey in self.arrayOfKeys {
//                if (arrayKey as! String) == key {
//                    result.append(arrayKey)
//                }
//            }
//        } else {
//            fatalError("arrayOfKeys does not contain String type!")
//        }
//    }
//}
