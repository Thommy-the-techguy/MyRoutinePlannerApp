//
//  CustomTableViewCellDelegate.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 16.01.24.
//

import UIKit

protocol CustomTableViewCellDelegate: NSObject {
    func removeCheckedRow(sender: UIButton, indexPath: IndexPath) -> Void
}
