//
//  SavableData.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 26.03.24.
//

import Foundation

protocol Savable: Codable {
    
}

extension KeyValuePairsWithFlag: Savable {
    
}

extension CodableKeyValuePairs: Savable {
    
}

extension Float: Savable {
    
}

extension Bool: Savable {
    
}

extension Date: Savable {
    
}

extension [String]: Savable {
    
}

//extension Priority: Savable {
//    
//}
