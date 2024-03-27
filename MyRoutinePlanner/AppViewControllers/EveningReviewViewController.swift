//
//  EveningReviewViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 27.03.24.
//

import UIKit

class EveningReviewViewController: UIViewController {
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Evening task review"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()
    
    var tableView: UITableView!
    
    let tableViewData = ["Evening review", "Send notification at"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        setupView()
        configureTableView()
        
        view.addSubview(self.tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
        ])
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 20
        
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EveningReviewCell")
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissView))
        
        //title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
}

extension EveningReviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EveningReviewCell", for: indexPath)
        
        cell.textLabel?.text = tableViewData[indexPath.row]
        
        if indexPath.row == 0 {
            let uiSwitch = UISwitch()
            cell.accessoryView = uiSwitch
        } else if indexPath.row == 1 {
            let timePicker: UIDatePicker = {
                let configuredDatePicker = UIDatePicker()
                configuredDatePicker.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
                configuredDatePicker.datePickerMode = .time
                
                var dateComponents = DateComponents(hour: 18, minute: 0)
                let startTime = Calendar.current.date(from: dateComponents)!
                configuredDatePicker.date = startTime
                
                dateComponents = DateComponents(hour: 16, minute: 0)
                let minDate = Calendar.current.date(from: dateComponents)
                configuredDatePicker.minimumDate = minDate
                
                dateComponents = DateComponents(hour: 20, minute: 59)
                let maxTime = Calendar.current.date(from: dateComponents)
                configuredDatePicker.maximumDate = maxTime
                
                return configuredDatePicker
            }()
            
            cell.accessoryView = timePicker
        }
        
        // change text label text size when settings updated
        let textSize = Storage.textSizePreference > 20.0 ? 20.0 : Storage.textSizePreference
        cell.textLabel?.font = .systemFont(ofSize: CGFloat(textSize))
        
        return cell
    }
    
    
}

extension EveningReviewViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension EveningReviewViewController: UITableViewDelegate {
    
}
