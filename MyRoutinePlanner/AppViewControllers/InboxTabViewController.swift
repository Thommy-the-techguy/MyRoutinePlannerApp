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
        print("Section Index To Remove\(String(describing: Storage.inboxData[currentKey]?.count))")
        
        if Storage.inboxData[currentKey]?.count == 0 {
            Storage.inboxData[currentKey] = nil
            self.tableView.beginUpdates()
            self.tableView.deleteSections([sectionIndex], with: .left)
            self.tableView.endUpdates()
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

    }
    
    private func openEditView(initialTextViewText: String, initialDate: Date) {
        let editActivityVC = AddActivityWithDateViewController(initialTextViewText: initialTextViewText, initialTitle: "Edit Task", initialDate: initialDate)
        editActivityVC.delegate = self
        let editActivityNavigationController = UINavigationController(rootViewController: editActivityVC)
        editActivityNavigationController.modalPresentationStyle = .formSheet
        present(editActivityNavigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editButton = UIContextualAction(style: .normal, title: "Edit", handler: { (contextualAction, view, boolValue) in
            let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            self.selectedRowIndexPath = indexPath
            
            let (initialText, initialDate) = (Storage.inboxData[currentKey]?.getKeyAndValue(for: indexPath.row))!
            
            self.openEditView(initialTextViewText: initialText, initialDate: initialDate)
        })
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { (contextualAction, view, boolValue) in
            let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: indexPath.row)
            self.deleteSectionIfNoActivities(sectionIndex: indexPath.section)
            tableView.endUpdates()
            
            
            self.reloadDataWithDelay(0.3)
        })

        let swipeActions = UISwipeActionsConfiguration(actions: [editButton, deleteButton])
        
        return swipeActions
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
            
//            self.tableView.performBatchUpdates({ () in
//                self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
//                deleteSectionIfNoActivities(sectionIndex: sourceSection)
//                tableView.reloadData()
//            })
//            self.tableView.beginUpdates()
//            
//            self.tableView.endUpdates()
            
            
        } else {
            let temp = Storage.inboxData[currentKey]?.getKeyAndValue(for: sourceRowIndex)
            let destinationKeyAndValue = Storage.inboxData[destinationKey]?.getKeyAndValue(for: destinationRowIndex)
            
            
            Storage.inboxData[currentKey]?.setKeyAndValue(for: sourceRowIndex, key: (destinationKeyAndValue?.key)!, value: (destinationKeyAndValue?.value)!)
            Storage.inboxData[destinationKey]?.setKeyAndValue(for: destinationRowIndex, key: (temp?.key)!, value: (temp?.value)!)
            
            
//            self.tableView.performBatchUpdates({ () in
//                self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
//                tableView.reloadData()
//            })
//            self.tableView.beginUpdates()
//
//            self.tableView.endUpdates()
        }
        
        // TODO: - maybe do it with delay
        self.tableView.performBatchUpdates({ () in
//            deleteSectionIfNoActivities(sectionIndex: sourceSection)
            tableView.reloadData()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.deleteSectionIfNoActivities(sectionIndex: sourceSection)
            self.tableView.reloadData()
        }
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
//        deleteSectionIfNoActivities(sectionIndex: indexPath.section)
        self.tableView.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.deleteSectionIfNoActivities(sectionIndex: indexPath.section)
            self.tableView.reloadData()
        }
        
        print(Storage.inboxData)
    }
}


extension InboxTabViewController: AddActivityDelegate {
    func editSelectedTask(taskText: String, taskDate: Date) {
        let sectionIndex = (self.selectedRowIndexPath?.section)!
        print(sectionIndex)
        var arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[sectionIndex]
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!
        
        let tomorrowDateInString = dateFormatter.string(from: tomorrowDate)
        let taskDateInString = dateFormatter.string(from: taskDate)
        let todayDateInString = dateFormatter.string(from: Date())
        let currentDateInString = dateFormatter.string(from: (Storage.inboxData[currentKey]?.getValue(for: 0))!)
        
        
        // TODO: here
        if taskText == Storage.inboxData[currentKey]?.getKey(for: (self.selectedRowIndexPath?.row)!) && taskDateInString == currentDateInString {
            return
        }
        
        
        
        var key: String
        switch taskDateInString {
            case todayDateInString:
                key = "Today"
                print(key)
            case tomorrowDateInString:
                key = "Tomorrow"
                print(key)
            default:
                key = taskDateInString
                print(key)
        }
        
        
        guard var taskDateKeyValuePairs = Storage.inboxData[key] else {
            
            
            Storage.inboxData[key] = CustomKeyValuePairs(
                arrayOfKeys: [taskText],
                arrayOfValues: [taskDate]
            )
            
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
            
            arrayOfDataDictKeys = Array(Storage.inboxData.keys)
            
            
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteSectionIfNoActivities(sectionIndex: sectionIndex)
                self.tableView.reloadData()
            }
            
            return
        }
        
        
        print("\n\n\nhere\n\n\n")
        if taskDateInString != currentDateInString {
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
            Storage.inboxData[key]?.append(key: taskText, value: taskDate)
            
            
        } else if taskDateInString == currentDateInString {
            Storage.inboxData[currentKey]?.insert(at: (self.selectedRowIndexPath?.row)!, key: taskText, value: taskDate)
        }

        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.deleteSectionIfNoActivities(sectionIndex: sectionIndex)
            self.tableView.reloadData()
        }
    }
    
    func saveNewTask(_ newTask: String, taskDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full

        let taskDateStringRepresentation = dateFormatter.string(from: taskDate)
        let todayDateStringRepresentation = dateFormatter.string(from: Date())
        let tomorrowDateStringRepresentation = dateFormatter.string(from: Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!)
        
        
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
        

        Storage.inboxData[keyToInsert]?.append(key: newTask, value: taskDate)

        
        self.tableView.reloadData()
    }
}
