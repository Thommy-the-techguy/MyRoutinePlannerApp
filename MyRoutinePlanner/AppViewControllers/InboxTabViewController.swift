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
    
    var tableView: UITableView!
    var activityViewController: UIActivityViewController?
    var selectedRowIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name("TabSwitched"), object: nil)
        
        setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.post(Notification(name: Notification.Name("TabSwitched")))
    }
    
    private func setupView() {
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        title = "Inbox"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewActivity))
        
        // share
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(shareViewAppear))
    }
    
    private func configureTableView() {
        tableView = UITableView()
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 20
        
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.delegate = self
        tableView.register(UICustomTableViewCell.self, forCellReuseIdentifier: "InboxCell")
    }

    private func setupUI() {
        setupView()
        configureTableView()
        
        
        self.view.addSubview(tableView)
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
    
    func deleteSectionIfNoActivities(sectionIndex: Int) {
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[sectionIndex]
        
        print("called", currentKey)
        print("\(String(describing: Storage.inboxData[currentKey]?.count))")
        
        if Storage.inboxData[currentKey]?.count == 0 {
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .left)
            Storage.inboxData[currentKey] = nil
        }
    }
    
    // MARK: - #selectors
    
    @objc private func addNewActivity() {
        let vc = AddActivityWithDateViewController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
    }
    
    // share note functionality
    
    @objc func shareViewAppear() {
        if let selectedRowIndexPath = self.selectedRowIndexPath {
            let selectedCell = tableView.cellForRow(at: selectedRowIndexPath) as! UICustomTableViewCell
            let cellLabel = selectedCell.getCellTextLabel()
            let cellDate = selectedCell.getCellDateLabel()
            
            activityViewController = UIActivityViewController(activityItems: [cellLabel.text ?? "", cellDate.text ?? ""], applicationActivities: nil)
            self.present(activityViewController!, animated: true)
        } else {
            print("No row selected.")
        }
    }
}


extension InboxTabViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let section = indexPath.section
        let rowIndex = indexPath.row
        
        
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = Storage.inboxData[currentKey]?.getKeyAndValue(for: rowIndex)
        
        
        return [dragItem]
    }
}


extension InboxTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Storage.inboxData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return (Storage.inboxData[currentKey]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! UICustomTableViewCell
        
        
        cell.delegate = self
        
        
        let section = indexPath.section
        let indexOfCell = indexPath.row
        
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        let message = Storage.inboxData[currentKey]?.getKey(for: indexOfCell)
        let date = Storage.inboxData[currentKey]?.getValue(for: indexOfCell)
        
        // MARK: - maybe not even necessary
        if let message, let date {
            cell.setText(message)
            cell.setDate(date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return currentKey
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: indexPath.row)
            deleteSectionIfNoActivities(sectionIndex: indexPath.section)
            tableView.endUpdates()
            
            
            reloadDataWithDelay(0.3)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceSection = sourceIndexPath.section
        let destinationSection = destinationIndexPath.section
        
        let sourceRowIndex = sourceIndexPath.row
        let destinationRowIndex = destinationIndexPath.row
        
        
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[sourceSection]
        let destinationKey: String = arrayOfDataDictKeys[destinationSection]
        
        
        if sourceSection != destinationSection {
            var keyAndValueToAppend = Storage.inboxData[currentKey]?.getKeyAndValue(for: sourceRowIndex)
            
            // MARK: - force unwrapping?
            let destinationDate = Storage.inboxData[destinationKey]?.getValue(for: 0)
            
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: destinationDate!)
            
            keyAndValueToAppend?.value = Calendar.current.date(from: dateComponents)!
            
            
            Storage.inboxData[destinationKey]?.append(key: (keyAndValueToAppend?.key)!, value: (keyAndValueToAppend?.value)!)
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: sourceRowIndex)
        } else {
            let temp = Storage.inboxData[currentKey]?.getKeyAndValue(for: sourceRowIndex)
            let destinationKeyAndValue = Storage.inboxData[destinationKey]?.getKeyAndValue(for: destinationRowIndex)
            
            
            Storage.inboxData[currentKey]?.setKeyAndValue(for: sourceRowIndex, key: (destinationKeyAndValue?.key)!, value: (destinationKeyAndValue?.value)!)
            Storage.inboxData[destinationKey]?.setKeyAndValue(for: destinationRowIndex, key: (temp?.key)!, value: (temp?.value)!)
        }
        
        
        deleteSectionIfNoActivities(sectionIndex: sourceSection)
        
        // TODO: - maybe do it with delay
        tableView.reloadData()
    }
    
    @objc func reloadTableViewData() {
        self.tableView.reloadData()
    }
    
    @objc func reloadDataWithDelay(_ delay: TimeInterval) {
        perform(#selector(reloadTableViewData), with: nil, afterDelay: delay)
        
    }
}


extension InboxTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRowIndexPath = indexPath
        print("Row at (section: \(indexPath.section), row: \(indexPath.row) has been selected")
    }
}



extension InboxTabViewController: CustomTableViewCellDelegate {
    func removeCheckedRow(sender: UIButton, indexPath: IndexPath) {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[indexPath.section]
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        Storage.inboxData[currentKey]?.removeKeyAndValue(for: indexPath.row)
        deleteSectionIfNoActivities(sectionIndex: indexPath.section)
        self.tableView.endUpdates()
        
        print(Storage.inboxData)
    }
}


extension InboxTabViewController: AddActivityDelegate {
    func saveNewTask(_ newTask: String, taskDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full

        let taskDateStringRepresentation = dateFormatter.string(from: taskDate)
        let todayDateStringRepresentation = dateFormatter.string(from: Date())
        let tomorrowDateStringRepresentation = dateFormatter.string(from: Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!)
        
//        print("tdsr: \(taskDateStringRepresentation)")
        var keyToInsert: String
        switch taskDateStringRepresentation {
            case todayDateStringRepresentation:
                keyToInsert = "Today"
                print(keyToInsert)
            case tomorrowDateStringRepresentation:
                keyToInsert = "Tomorrow"
                print(keyToInsert)
            default:
                keyToInsert = taskDateStringRepresentation
                print(keyToInsert)
        }
        
        guard var keyValuePairs = Storage.inboxData[keyToInsert] else {
            Storage.inboxData[keyToInsert] = CustomKeyValuePairs(
                arrayOfKeys: [newTask],
                arrayOfValues: [taskDate]
            )
            
            self.tableView.reloadData()
            
            return
        }
        
        keyValuePairs.append(key: newTask, value: taskDate)
        Storage.inboxData[keyToInsert] = keyValuePairs
        
        self.tableView.reloadData()
    }
}
