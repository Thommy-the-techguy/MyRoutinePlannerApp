//
//  UICustomTableViewCell.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 16.01.24.
//

import UIKit

class UICustomTableViewCell: UITableViewCell {

    static let identifier = "CustomCell"
    private let label: UILabel = {
        let configuratedLabel = UILabel()
        configuratedLabel.numberOfLines = 0
        configuratedLabel.font = .systemFont(ofSize: 18)
        configuratedLabel.textAlignment = .justified
        return configuratedLabel
    }()
    
    private let checkButton: UIButton = {
        let configuratedButton = UIButton()
        configuratedButton.setImage(UIImage(systemName: "circle"), for: .normal)
        configuratedButton.addTarget(self, action: #selector(buttonAction(sender: )), for: .touchUpInside)
        return configuratedButton
    }()
    
    private let dateTextLabel: UILabel = {
        let configuredDateTextLabel = UILabel()
        configuredDateTextLabel.textColor = .systemOrange
        return configuredDateTextLabel
    }()
    
    var date: Date?
    
    var indexPath: IndexPath? {
        get {
            guard let superview = self.superview as? UITableView else {
                fatalError("superview is not a UITableView")
            }
            return superview.indexPath(for: self)
        }
    }
    var labelSize: (width: CGFloat, height: CGFloat) {
        get {
            return (width: label.frame.width, height: label.frame.height)
        }
    }
    static weak var delegate: CustomTableViewCellDelegate?

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
    
    func setDate(_ date: Date) {
        self.date = date
        if #available(iOS 15, *) {
            dateTextLabel.text = self.date?.formatted(date: .numeric, time: .omitted)
//            dateTextLabel.text = date.formatted(Date.FormatStyle.dateTime)
        } else {
            dateTextLabel.text = self.date?.description
        }
    }
    
    override func prepareForReuse() {
        self.checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    private func setupUI() {
        self.contentView.addSubview(checkButton)
        self.contentView.addSubview(label)
        self.contentView.addSubview(dateTextLabel)
        
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        dateTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            checkButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            checkButton.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
            checkButton.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            checkButton.trailingAnchor.constraint(equalTo: self.label.leadingAnchor, constant: -15.0),
            checkButton.widthAnchor.constraint(lessThanOrEqualToConstant: 20.0),
            checkButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 20.0),
            

            label.leadingAnchor.constraint(equalTo: self.checkButton.trailingAnchor, constant: 15.0),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15.0),
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            label.bottomAnchor.constraint(equalTo: self.dateTextLabel.topAnchor),
            
            
            dateTextLabel.topAnchor.constraint(equalTo: self.label.bottomAnchor),
            dateTextLabel.trailingAnchor.constraint(equalTo: self.label.trailingAnchor),
            dateTextLabel.leadingAnchor.constraint(equalTo: self.label.leadingAnchor),
            dateTextLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
    }
    
    
    // MARK: - selectors
    
    @objc func buttonAction(sender: UIButton) {
        if let delegate = UICustomTableViewCell.delegate {
            delegate.removeCheckedRow(sender: sender, indexPath: self.indexPath!)
        } else {
            fatalError("CustomTableViewCellDelegate was not assigned!")
        }
    }
}
