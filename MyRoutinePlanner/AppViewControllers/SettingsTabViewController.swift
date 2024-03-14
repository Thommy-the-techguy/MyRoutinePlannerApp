//
//  BrowseTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class SettingsTabViewController: UIViewController {
    var tableView: UITableView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // setting view's background color
        view.backgroundColor = .white
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        
        setupUI()
    }
    
    private func setupView() {
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        title = "Settings"
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! UISettingsTableViewCell // don't change the identifier!!!
        
        
        let image = UIImage(systemName: tableViewData.getValue(for: indexPath.section)[indexPath.row].iconName)!
        let text = tableViewData.getValue(for: indexPath.section)[indexPath.row].settingsText
        
        
        cell.setImage(image)
        cell.setText(text)
        cell.accessoryType = .disclosureIndicator
        
        
        return cell
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
