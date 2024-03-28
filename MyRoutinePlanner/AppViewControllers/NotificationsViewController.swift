//
//  NotificationsViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 15.03.24.
//

import UIKit

class NotificationsViewController: UIViewController {
    var currentTextSizePreference = Storage.textSizePreference
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Notifications"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()
    
//    let tableViewLabelForSettingsApp = "ENABLE NOTIFICATIONS"
    
    var tableView: UITableView!
    
    var footerTextEnabled = "Push notifications for MyRoutinePlanner are turned off. To turn them on, visit the Settings app."
    
    var footerTextDisabled = "Push notifications for MyRoutinePlanner are turned on. To turn them off, visit the Settigns app."
    
    var isNotificationsOn = true
    
    typealias TableViewTextFillers = (preferenceText: String, subText: String?, footerText: String?)
    
    let tableViewData = CustomKeyValuePairs(
        arrayOfKeys: ["ENABLE NOTIFICATIONS", nil],
        arrayOfValues: [
            [
                TableViewTextFillers(preferenceText: "Open Settings App", subText: nil, footerText: "Push notifications for MyRoutinePlanner are turned off. To turn them on, visit the Settings app."),
            ],
            [
                TableViewTextFillers(preferenceText: "Morning overview", subText: "Organize your tasks for the day", footerText: nil),
                TableViewTextFillers(preferenceText: "Evening review", subText: "Review what's left to get done", footerText: nil),
            ],
        ]
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        setupView()
        configureTableView()
        
        view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
        ])
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissView))
        
//        self.title = "Text Size"
        //title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 20
        
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.delegate = self
        tableView.register(UICustomTableViewCell.self, forCellReuseIdentifier: "NotificationsPreferencesCell")
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }

}


extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.getValue(for: section).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsPreferencesCell", for: indexPath) as! UICustomTableViewCell
        
        let (preferenceName, subText, footerText) = tableViewData.getValue(for: indexPath.section)[indexPath.row]
        
        cell.getCheckButton().setImage(nil, for: .normal)
        cell.getCellTextLabel().text = preferenceName
        cell.getCellDateLabel().text = subText
        
        if indexPath.section == 0 {
            cell.getCellTextLabel().textColor = .systemRed
            cell.getCellTextLabel().textAlignment = .center
            
            let settingsTextLabel = cell.getCellTextLabel()
            NSLayoutConstraint.activate([
                settingsTextLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                settingsTextLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            ])
        }
        
        // change text label text size when settings updated
        cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        // change text label date text size when settings updated
        let textSizeForSubText = Storage.textSizePreference > 15 ? 15.0 : Storage.textSizePreference
        cell.getCellDateLabel().font = .systemFont(ofSize: CGFloat(textSizeForSubText))
        
        if indexPath.section != 0 {
            cell.accessoryType = .disclosureIndicator
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingName = (tableView.cellForRow(at: indexPath) as! UICustomTableViewCell).getCellTextLabel().text!
        
        switch settingName {
            case "Open Settings App":
                openSettingsApp()
            case "Morning overview":
                let morningOverviewController = MorningOverviewViewController()
                let navigationVC = UINavigationController(rootViewController: morningOverviewController)
                present(navigationVC, animated: true)
            case "Evening review":
                let eveningReviewController = EveningReviewViewController()
                let navigationVC = UINavigationController(rootViewController: eveningReviewController)
                present(navigationVC, animated: true)
                
            default: break
        }
    }
    
    private func openSettingsApp() {
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    
}

extension NotificationsViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData.getKey(for: section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewData.getValue(for: section)[0].footerText
    }
}

extension NotificationsViewController: UITableViewDelegate {
    
}
