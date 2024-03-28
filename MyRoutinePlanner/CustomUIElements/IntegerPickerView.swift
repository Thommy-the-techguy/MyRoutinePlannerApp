//
//  IntegerPickerView.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 28.03.24.
//

import UIKit

class IntegerPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Data for the picker
    var numbers: [Int] = []
    
    // Selected integer
    var selectedInteger: Int? {
        guard selectedRow(inComponent: 0) < numbers.count else {
            return nil
        }
        return numbers[selectedRow(inComponent: 0)]
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        dataSource = self
        delegate = self
        
        // Set style similar to UIDatePicker
        self.backgroundColor = .white
        self.tintColor = .black
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numbers[row])"
    }
}
