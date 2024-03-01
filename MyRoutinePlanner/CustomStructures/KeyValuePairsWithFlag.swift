//
//  KeyValuePairsWithFlag.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 17.02.24.
//

import Foundation

struct KeyValuePairsWithFlag<K: Codable, V: Codable> {
    private var arrayOfKeys: [K] = [] // Messages, can be something else
    private var arrayOfValues: [V] = [] // Date, can be something else
    private var arrayOfFlags: [Bool] = [] // for alarm
    
    var count: Int {
        get {
            return arrayOfKeys.count
        }
    }
    
    init() {
        
    }
    
    init(arrayOfKeys: [K], arrayOfValues: [V], arrayOfFlags: [Bool]) {
        if (arrayOfKeys.count != arrayOfValues.count) || (arrayOfValues.count != arrayOfFlags.count) || (arrayOfKeys.count != arrayOfFlags.count) {
            fatalError("CustomKeyValuePairs Error: arrayOfKeys length should equal to arrayOfValues length!")
        } else {
            self.arrayOfKeys = arrayOfKeys
            self.arrayOfValues = arrayOfValues
            self.arrayOfFlags = arrayOfFlags
        }
    }
    
    mutating func append(key: K, value: V, withReminder: Bool) {
        self.arrayOfKeys.append(key)
        self.arrayOfValues.append(value)
        self.arrayOfFlags.append(withReminder)
    }
    
    mutating func removeKeyAndValue(for index: Int) {
        self.arrayOfKeys.remove(at: index)
        self.arrayOfValues.remove(at: index)
        self.arrayOfFlags.remove(at: index)
    }
    
    mutating func insert(at: Int, key: K, value: V, withReminder: Bool) {
        self.arrayOfKeys.insert(key, at: at)
        self.arrayOfValues.insert(value, at: at)
        self.arrayOfFlags.insert(withReminder, at: at)
    }
    
    mutating func setKeyAndValue(for index: Int, key: K, value: V, withReminder: Bool) {
        self.removeKeyAndValue(for: index)
        self.insert(at: index, key: key, value: value, withReminder: withReminder)
    }
    
    mutating func setFlag(for index: Int, withReminder: Bool) {
        self.arrayOfFlags[index] = withReminder
    }
    
    func getKey(for index: Int) -> K {
        return self.arrayOfKeys[index]
    }
    
    func getValue(for index: Int) -> V {
        return self.arrayOfValues[index]
    }
    
    func getFlag(for index: Int) -> Bool {
        return self.arrayOfFlags[index]
    }
    
    func getKeyAndValue(for index: Int) -> (key: K, value: V, flag: Bool) {
        let key = self.arrayOfKeys[index]
        let value = self.arrayOfValues[index]
        let flag = self.arrayOfFlags[index]
        
        return (key, value, flag)
    }
}

extension KeyValuePairsWithFlag: Codable {
    
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
