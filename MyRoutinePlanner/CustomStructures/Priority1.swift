//
//  Priority.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 28.03.24.
//

import Foundation
import UIKit

//struct Priority1 {
//    private var priorityLevel: Int = 4 // 1 - highest, 2 - medium, 3 - lowest, 4 - no priority / default
//    private var priorityColor: UIColor = .gray
//    
//    // if init is not used default values are 4 and .gray
//    init(priorityLevel: Int) {
//        self.priorityLevel = priorityLevel
//        setPriorityColor()
//    }
//    
//    func getPriorityLevel() -> Int {
//        return priorityLevel
//    }
//    
//    func getPriorityColor() -> UIColor {
//        return priorityColor
//    }
//    
//    mutating func setPriorityLevel(newPriorityLevel: Int) {
//        self.priorityLevel = newPriorityLevel
//        setPriorityColor()
//    }
//    
//    private mutating func setPriorityColor() {
//        switch priorityLevel {
//            case 1:
//                priorityColor = .red
//            case 2:
//                priorityColor = .orange
//            case 3:
//                priorityColor = .blue
//            default:
//                let adjustedGray = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1.0) // Adjust the values as needed
//                priorityColor = adjustedGray
//        }
//    }
//}

extension UIColor {
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toHexString() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

//extension Priority: Codable {
//    enum CodingKeys: String, CodingKey {
//        case priorityLevel
//        case priorityColor
//    }
//        
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.priorityLevel = try container.decode(Int.self, forKey: .priorityLevel)
//        let colorString = try container.decode(String.self, forKey: .priorityColor)
//        
//        // Create UIColor directly from hex string
//        self.priorityColor = UIColor(hexString: colorString) ?? .gray
//    }
//        
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(priorityLevel, forKey: .priorityLevel)
//        try container.encode(priorityColor.toHexString(), forKey: .priorityColor)
//    }
//}
