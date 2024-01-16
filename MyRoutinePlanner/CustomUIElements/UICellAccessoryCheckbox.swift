//
//  UICheckbox.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 15.01.24.
//

import UIKit

class UICellAccessoryCheckbox: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var isChecked = false
    var indexPath: IndexPath? = nil

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
