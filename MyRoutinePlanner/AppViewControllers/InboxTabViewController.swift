//
//  InboxTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class InboxTabViewController: UIViewController {
    // TODO: - maybe create class Storage to share data with today tab and maybe delete old tasks
    // when today will pass Tomorrow CustomKeyValuePairs -> Today : CustomKeyValuePairs
    // (day after tommorow) Fri CustomKeyValuePairs -> Tomorrow : CustomKeyValuePairs
    // (day after tommorow) Fri = nil
    
//    var inboxData: [String:CustomKeyValuePairs<String, Date>] = [:]
    var inboxData: [String:CustomKeyValuePairs<String, Date>] = [
        "Today" : CustomKeyValuePairs(arrayOfKeys: ["today1", "today2", "today3"], arrayOfValues: [Date(), Date(), Date()]),
        
        "Tomorrow" : CustomKeyValuePairs(arrayOfKeys: ["tomorrow1", "tomorrow2", "tomorrow3", "tomorrow4", "tomorrow5"], arrayOfValues: [
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!, Calendar.current.date(byAdding: .day, value: 1, to: Date())!, Calendar.current.date(byAdding: .day, value: 1, to: Date())!, Calendar.current.date(byAdding: .day, value: 1, to: Date())!, Calendar.current.date(byAdding: .day, value: 1, to: Date())!]),
        
        "Fri" : CustomKeyValuePairs(arrayOfKeys: ["26 smth1", "26 smth2", "26 smth3", "26 smth4"], arrayOfValues: [
            Calendar.current.date(byAdding: .day, value: 2, to: Date())!, Calendar.current.date(byAdding: .day, value: 2, to: Date())!, Calendar.current.date(byAdding: .day, value: 2, to: Date())!, Calendar.current.date(byAdding: .day, value: 2, to: Date())!])
    ]
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        
    }
    
    private func setupView() {
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        
        title = "Inbox"
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewActivity))
    }
    
    private func configureTableView() {
        tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UICustomTableViewCell.self, forCellReuseIdentifier: UICustomTableViewCell.identifier)
    }

    private func setupUI() {
        setupView()
        configureTableView()
        
        
        self.view.addSubview(tableView)
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
    
    
    // MARK: - #selectors
    
    @objc private func addNewActivity() {
        let navVC = UINavigationController(rootViewController: AddActivityWithDateViewController())
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
    }
    

}


extension InboxTabViewController: UITableViewDelegate {
    
}


extension InboxTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.inboxData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arrayOfDataDictKeys = Array(self.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return (self.inboxData[currentKey]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UICustomTableViewCell.identifier, for: indexPath) as! UICustomTableViewCell
        
        let section = indexPath.section
        let indexOfCell = indexPath.row
        
        let arrayOfDataDictKeys = Array(self.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        let message = self.inboxData[currentKey]?.getKey(for: indexOfCell)
        let date = self.inboxData[currentKey]?.getValue(for: indexOfCell)
        
        // MARK: - maybe not even necessary
        if let message, let date {
            cell.setText(message)
            cell.setDate(date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let arrayOfDataDictKeys = Array(self.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return currentKey
    }
}
