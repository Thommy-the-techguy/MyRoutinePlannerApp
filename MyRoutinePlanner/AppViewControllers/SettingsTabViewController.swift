//
//  BrowseTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class SettingsTabViewController: UIViewController {
    var tableView: UITableView!
    
    var currentTextSizePreference = Storage.textSizePreference
    
    let tableViewData = CustomKeyValuePairs(
        arrayOfKeys: ["PERSONALIZATION", "PRODUCTIVITY"],
        arrayOfValues: [
            [
                (iconName: "textformat.size", settingsText: "Text Size"),
            ],
            [
                (iconName: "bell", settingsText: "Notifications")
            ]
        ]
    )
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Settings"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // setting view's background color
        view.backgroundColor = .white
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // update to corresponding settings preferences
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewDataAsync), name: Notification.Name("ReloadData"), object: nil)
        
        setupUI()
    }
    
    private func setupView() {
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
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
        tableView.register(UISettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    @objc func reloadTableViewDataAsync() {
        DispatchQueue.main.async { [unowned self] in
            if currentTextSizePreference != Storage.textSizePreference {
                let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
                viewControllerTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
                
                currentTextSizePreference = Storage.textSizePreference
            }
            
            self.tableView.reloadData()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SettingsTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.getValue(for: 0).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        let textSize = Storage.textSizePreference > 21.0 ? 21.0 : Storage.textSizePreference
        
        header.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(textSize))
        header.textLabel?.frame = header.bounds
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! UISettingsTableViewCell // don't change the identifier!!!
        
        
        let image = UIImage(systemName: tableViewData.getValue(for: indexPath.section)[indexPath.row].iconName)!
        let text = tableViewData.getValue(for: indexPath.section)[indexPath.row].settingsText
        
        
        cell.setImage(image)
        cell.setText(text)
        
        // change text label text size when settings updated
        cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        
        cell.accessoryType = .disclosureIndicator
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingName = (tableView.cellForRow(at: indexPath) as! UISettingsTableViewCell).getCellTextLabel().text!
        
        switch settingName {
            case "Text Size":
                let textSizeVC = TextSizeViewController()
                let navigationVC = UINavigationController(rootViewController: textSizeVC)
                self.present(navigationVC, animated: true)
            case "Notifications": break
                
            default: break
        }
    }
}



extension SettingsTabViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData.getKey(for: section)
    }
}


extension SettingsTabViewController: UITableViewDelegate {
    
}
