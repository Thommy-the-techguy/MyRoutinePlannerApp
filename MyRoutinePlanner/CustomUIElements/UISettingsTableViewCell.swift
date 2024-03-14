//
//  UISettingsTableViewCell.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.03.24.
//

import UIKit

class UISettingsTableViewCell: UITableViewCell {

    static let identifier = "CustomSettingsCell"
    private let label: UILabel = {
        let configuratedLabel = UILabel()
        configuratedLabel.numberOfLines = 0
        configuratedLabel.font = .systemFont(ofSize: 18)
        configuratedLabel.textAlignment = .justified
        return configuratedLabel
    }()
    
    private var cellImageView: UIImageView = {
        let configuredImageView = UIImageView()
        
        return configuredImageView
    }()
    
    var labelSize: (width: CGFloat, height: CGFloat) {
        get {
            return (width: label.frame.width, height: label.frame.height)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        self.label.text = text
    }
    
    func setImage(_ image: UIImage) {
        self.cellImageView.image = image
    }
    
    func getCellTextLabel() -> UILabel {
        return self.label
    }
    
    private func setupUI() {
        self.contentView.addSubview(cellImageView)
        self.contentView.addSubview(label)
        
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: self.label.leadingAnchor, constant: -15.0),
            cellImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 20.0),
            cellImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20.0),
            

            label.leadingAnchor.constraint(equalTo: self.cellImageView.trailingAnchor, constant: 15.0),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15.0),
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
    }
}
