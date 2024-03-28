//
//  SearchTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class CompletedTabViewController: UIViewController {
    var tableView: UITableView!
    
    var currentTextSizePreference = Storage.textSizePreference
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Completed"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // setting view's background image
        view.backgroundColor = .white
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewDataAsync), name: Notification.Name("ReloadData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name("TabSwitched"), object: nil)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.post(Notification(name: Notification.Name("TabSwitched")))
    }
    
    @objc func reloadTableViewData() {
        self.tableView.reloadData()
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
        tableView.delegate = self
        tableView.register(UICustomTableViewCell.self, forCellReuseIdentifier: "CompletedCell")
    }
    
    private func setupView() {
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
    }

}

extension CompletedTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.completedTasksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell", for: indexPath) as! UICustomTableViewCell
        
        cell.delegate = self
        
        let (text, date) = Storage.completedTasksData.getKeyAndValue(for: indexPath.row)
        
        cell.setText(text)
        cell.setDate(date)
        
        // change text label text size when settings updated
        cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        // change text label date text size when settings updated
        cell.getCellDateLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        cell.getCheckButton().isHidden = true
        if #available(iOS 15.0, *) {
            cell.getCellDateLabel().text = cell.getDate()?.formatted(date: .numeric, time: .shortened)
        } else {
            // Fallback on earlier versions
        }
        
        return cell
    }
}

extension CompletedTabViewController: UITableViewDelegate {
    
}

extension CompletedTabViewController: CustomTableViewCellDelegate {
    func removeCheckedRow(sender: UIButton, indexPath: IndexPath) {
        return
    }
}
