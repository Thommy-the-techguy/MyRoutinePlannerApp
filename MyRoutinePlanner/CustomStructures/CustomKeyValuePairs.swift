//
//  CustomKeyValuePairs.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 18.01.24.
//

import Foundation

struct CustomKeyValuePairs<K, V> {
    private var arrayOfKeys: [K] = [] // Messages, can be something else
    private var arrayOfValues: [V] = [] // Date, can be something else
    
    
    var count: Int {
        get {
            return arrayOfKeys.count
        }
    }
    
    init() {
        
    }
    
    init(arrayOfKeys: [K], arrayOfValues: [V]) {
        if arrayOfKeys.count != arrayOfValues.count {
            fatalError("CustomKeyValuePairs Error: arrayOfKeys length should equal to arrayOfValues length!")
        } else {
            self.arrayOfKeys = arrayOfKeys
            self.arrayOfValues = arrayOfValues
        }
    }
    
    mutating func append(key: K, value: V) {
        self.arrayOfKeys.append(key)
        self.arrayOfValues.append(value)
    }
    
    mutating func removeKeyAndValue(for index: Int) {
        self.arrayOfKeys.remove(at: index)
        self.arrayOfValues.remove(at: index)
    }
    
    mutating func insert(at: Int, key: K, value: V) {
        self.arrayOfKeys.insert(key, at: at)
        self.arrayOfValues.insert(value, at: at)
    }
    
    mutating func setKeyAndValue(for index: Int, key: K, value: V) {
        self.removeKeyAndValue(for: index)
        self.insert(at: index, key: key, value: value)
    }
    
    func getKey(for index: Int) -> K {
        return self.arrayOfKeys[index]
    }
    
    func getValue(for index: Int) -> V {
        return self.arrayOfValues[index]
    }
    
    func getKeyAndValue(for index: Int) -> (key: K, value: V) {
        let key = self.arrayOfKeys[index]
        let value = self.arrayOfValues[index]
        
        return (key, value)
    }
}

//extension CustomKeyValuePairs: Codable {
//    
//}
