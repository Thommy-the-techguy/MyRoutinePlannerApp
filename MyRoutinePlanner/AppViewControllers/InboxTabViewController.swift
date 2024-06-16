//
//  InboxTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class InboxTabViewController: UIViewController {    
    var tableView: UITableView!
    var activityViewController: UIActivityViewController?
    var selectedRowIndexPath: IndexPath?
    var searchBar: UISearchBar!
    
    var filteredData: [String:[MyTask]] = [:]
    var searching = false
    
    var currentTextSizePreference = Storage.textSizePreference
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Inbox"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name("TabSwitched"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewDataAsync), name: Notification.Name("ReloadData"), object: nil)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.post(Notification(name: Notification.Name("TabSwitched")))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    private func setupView() {
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewActivity))
        
        // share
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(shareViewAppear))
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 20
        
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.delegate = self
        tableView.register(UICustomTableViewCell.self, forCellReuseIdentifier: "InboxCell")
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }

    private func setupUI() {
        setupView()
        configureTableView()
        setupSearchBar()
        
        
        self.view.addSubview(tableView)
        self.view.addSubview(searchBar)
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: self.searchBar.topAnchor, constant: 40.0),
            
            tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
    
    func deleteSectionIfNoActivities(sectionIndex: Int) {
        var sectionsToRemove: [String] = []

        for (sectionKey, sectionData) in Storage.storageData {
            if sectionData.count == 0 {
                sectionsToRemove.append(sectionKey)
            }
        }

        // Remove empty sections from Storage.inboxData and filteredData
        for sectionKey in sectionsToRemove {
            Storage.storageData.removeValue(forKey: sectionKey)
            filteredData.removeValue(forKey: sectionKey)
        }

        // Update table view to reflect changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
            tableView.beginUpdates()
            let indexSetToRemove = IndexSet(sectionsToRemove.compactMap { sectionKey in
                Array(Storage.storageData.keys).firstIndex(of: sectionKey)
            })
            
            self.tableView.deleteSections(indexSetToRemove, with: .automatic)
            tableView.endUpdates()
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
        
        
        let arrayOfDataDictKeys = Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = Storage.storageData[currentKey]?[rowIndex]
        
        
        return [dragItem]
    }
}


extension InboxTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searching ? filteredData.count : Storage.storageData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return searching ? (filteredData[currentKey]?.count)! : (Storage.storageData[currentKey]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! UICustomTableViewCell // don't change the identifier!!!
        
        
        cell.delegate = self
        
        
        let section = indexPath.section
        let indexOfCell = indexPath.row
        
        
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        let message = searching ? filteredData[currentKey]?[indexOfCell].taskTitle : Storage.storageData[currentKey]?[indexOfCell].taskTitle
        let date = searching ? filteredData[currentKey]?[indexOfCell].taskDate : Storage.storageData[currentKey]?[indexOfCell].taskDate
        
        
        let imageSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        
        
        let taskPriority = Storage.storageData[currentKey]?[indexPath.row].taskPriorityRel
        let color = UIColor(hexString: (taskPriority?.priorityColor)!)
        
        let buttonsColor = color
        // MARK: - maybe not even necessary
        if let message, let date {
            cell.setText(message)
            cell.setDate(date)
            
            // change text label text size when settings updated
            cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
            
            // change text label date text size when settings updated
            cell.getCellDateLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
            
            // change buttons sizes
            
            let checkButtonImage = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(Int(imageSize))))?.withTintColor(buttonsColor, renderingMode: .alwaysOriginal)
            
            cell.getCheckButton().setImage(checkButtonImage, for: .normal)
        }
        
        // setting reminder button
        let accessoryButton = UIButton()
        accessoryButton.frame = CGRect(x: 0, y: 0, width: Int(imageSize), height: Int(imageSize)) // replace magic constants

        let reminderButtonImage = UIImage(systemName: "bell.badge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(imageSize)))?.withTintColor(buttonsColor, renderingMode: .alwaysOriginal)

        accessoryButton.setImage(reminderButtonImage, for: .normal)

        accessoryButton.addTarget(self, action: #selector(cancelReminderWithIdentifier(sender: )), for: .touchUpInside)
        
        cell.accessoryView = accessoryButton
        
        
        let reminder = Storage.storageData[currentKey]?[indexPath.row].taskReminderRel
        
        if searching ? (filteredData[currentKey]?[indexPath.row].taskReminderRel != nil) : reminder != nil {
            cell.accessoryView?.isHidden = false
        } else {
            cell.accessoryView?.isHidden = true
        }
        
        return cell
    }
    
    @objc private func cancelReminderWithIdentifier(sender: UIButton) {
        let cell = sender.superview as? UICustomTableViewCell
        
        let section = (cell?.indexPath?.section)!
        let arrayOfDataDictKeys = Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        let reminder = Storage.storageData[currentKey]?[(cell?.indexPath?.row)!].taskReminderRel
        let reminderIdentifier = reminder?.reminderIdentifier
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
//        Storage.inboxData[currentKey]?.setReminder(for: (cell?.indexPath?.row)!, withReminder: nil)
        if let task = Storage.storageData[currentKey]?[(cell?.indexPath?.row)!] {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // Assuming `taskReminderRel` is the relationship between Task and Reminder
            if let reminder = task.taskReminderRel {
                // Remove the reminder from the task
                task.taskReminderRel = nil
                
                // Delete the reminder from Core Data
                context.delete(reminder)
                
                // Save the context
                do {
                    try context.save()
                } catch {
                    print("Error saving context: \(error.localizedDescription)")
                }
            }
        }
        
        cell?.accessoryView?.isHidden = true
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return currentKey
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        let textSize = Storage.textSizePreference > 21.0 ? 21.0 : Storage.textSizePreference
        
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(textSize))
        header.textLabel?.frame = header.bounds
        header.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    private func openEditView(initialTextViewText: String, initialDate: Date, initialFlag: Reminder?, initialPriority: Priority, initialTaskOrderIndex: Int) {
        let editActivityVC = AddActivityWithDateViewController(initialTextViewText: initialTextViewText, initialTitle: "Edit Task", initialDate: initialDate, initialFlag: initialFlag, initialPriority: initialPriority, initialTaskOrderIndex: initialTaskOrderIndex)
        editActivityVC.delegate = self
        let editActivityNavigationController = UINavigationController(rootViewController: editActivityVC)
        editActivityNavigationController.modalPresentationStyle = .formSheet
        present(editActivityNavigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editButton = UIContextualAction(style: .normal, title: "Edit", handler: { [unowned self] (contextualAction, view, boolValue) in
            let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            self.selectedRowIndexPath = indexPath
            
            let task = Storage.storageData[currentKey]?[indexPath.row]
            let initialText = (task?.taskTitle)!
            let initialDate = (task?.taskDate)!
            let reminder = task?.taskReminderRel
            let priority = (task?.taskPriorityRel)!
            let orderIndex = (task?.taskOrderIndex)!
            
            self.openEditView(initialTextViewText: initialText, initialDate: initialDate, initialFlag: reminder, initialPriority: priority, initialTaskOrderIndex: Int(orderIndex))
        })
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { [unowned self] (contextualAction, view, boolValue) in
            let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            let task = Storage.storageData[currentKey]?[indexPath.row]
            
            updateIndices(sectionKey: currentKey, removedIndex: Int((task?.taskOrderIndex)!))
            
            let cell = tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
            self.cancelNotification(cell: cell)
            
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Storage.storageData[currentKey]?.remove(at: indexPath.row)
            filteredData[currentKey]?.remove(at: indexPath.row)
            tableView.endUpdates()
            

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteSectionIfNoActivities(sectionIndex: indexPath.section)
                self.tableView.reloadData()
            }
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                context.delete(task!)
                
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
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
        
        
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[sourceSection]
        let destinationKey: String = arrayOfDataDictKeys[destinationSection]
        
        
        if sourceSection != destinationSection {
            let task = Storage.storageData[currentKey]?[sourceRowIndex]
            
            // MARK: - force unwrapping?
            let destinationDate = Storage.storageData[destinationKey]?[0].taskDate
            
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: destinationDate!)
            
            task?.taskDate = Calendar.current.date(from: dateComponents)!
            updateIndices(sectionKey: currentKey, removedIndex: Int((task?.taskOrderIndex)!))
            task?.taskOrderIndex = Storage.storageData[destinationKey]?.count != nil ? Int64((Storage.storageData[destinationKey]?.count)!) : 0
            
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
            
            // remove notification when moved to another section
            let cell = self.tableView.cellForRow(at: sourceIndexPath) as! UICustomTableViewCell
            cancelNotification(cell: cell)
            
            
            Storage.storageData[destinationKey]?.append(task!)
            Storage.storageData[currentKey]?.remove(at: sourceRowIndex)
            
            filteredData[destinationKey]?.append(task!)
            filteredData[currentKey]?.remove(at: sourceRowIndex)
            
        } else {
            let temp = Storage.storageData[currentKey]?[sourceRowIndex]
            let tempTaskOrderIndex = temp?.taskOrderIndex
            let destinationKeyAndValue = Storage.storageData[destinationKey]?[destinationRowIndex]
            let destinationTaskOrderIndex = destinationKeyAndValue?.taskOrderIndex
            
            
            destinationKeyAndValue?.taskOrderIndex = tempTaskOrderIndex! // swap orderIndexes for CoreData
            temp?.taskOrderIndex = destinationTaskOrderIndex!
            
            
            Storage.storageData[currentKey]?[sourceRowIndex] = destinationKeyAndValue!
            Storage.storageData[destinationKey]?[destinationRowIndex] = temp!
            
            
            filteredData[currentKey]?[sourceRowIndex] = destinationKeyAndValue!
            filteredData[destinationKey]?[destinationRowIndex] = temp!
            
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
        }
        
        // TODO: - maybe do it with delay
        self.tableView.performBatchUpdates({ () in
            tableView.reloadData()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.deleteSectionIfNoActivities(sectionIndex: sourceSection)
            self.tableView.reloadData()
        }
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
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
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[indexPath.section]
        print("current key: \(currentKey) row: \(indexPath.row) section: \(indexPath.section)")
        
        
        let priority = Storage.storageData[currentKey]?[indexPath.row].taskPriorityRel
        let color = UIColor(hexString: (priority?.priorityColor)!)
        
        // checked circle color set
        let buttonsColor = color
        
        let imageSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        
        let checkButtonImage = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(imageSize)))?.withTintColor(buttonsColor, renderingMode: .alwaysOriginal)
        
        sender.setImage(checkButtonImage, for: .normal)
        
        let cell = self.tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
        cancelNotification(cell: cell)
        
        
        self.tableView.beginUpdates()
        
        let task = Storage.storageData[currentKey]?[indexPath.row]
        let completedTask = Storage.storageData[currentKey]?[indexPath.row].taskTitle
        let timeOfCompletion = Date()
        
        updateIndices(sectionKey: currentKey, removedIndex: Int((task?.taskOrderIndex)!))
        
        Storage.completedTasksData.append(key: completedTask!, value: timeOfCompletion)
        Storage.storageData[currentKey]?.remove(at: indexPath.row)
        filteredData[currentKey]?.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        self.tableView.endUpdates()
        
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
            context.delete(task!)
            
            try context.save()
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            deleteSectionIfNoActivities(sectionIndex: indexPath.section)
            
            tableView.reloadData()
        }
        
        print(Storage.storageData)
        print("Completed Tasks: \(Storage.completedTasksData)")
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
    }
    
    func cancelNotification(cell: UICustomTableViewCell) {
        let section = (cell.indexPath?.section)!
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        let reminder = Storage.storageData[currentKey]?[(cell.indexPath?.row)!].taskReminderRel
        let reminderIdentifier = reminder?.reminderIdentifier
        
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        if let task = Storage.storageData[currentKey]?[(cell.indexPath?.row)!] {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // Assuming `taskReminderRel` is the relationship between Task and Reminder
            if let reminder = task.taskReminderRel {
                // Remove the reminder from the task
                task.taskReminderRel = nil
                
                // Delete the reminder from Core Data
                context.delete(reminder)
                
                // Save the context
                do {
                    try context.save()
                } catch {
                    print("Error saving context: \(error.localizedDescription)")
                }
            }
        }
        
        cell.accessoryView?.isHidden = true
    }
}


extension InboxTabViewController: AddActivityDelegate {
    func editSelectedTask(_ editedTask: MyTask) {
        let sectionIndex = (self.selectedRowIndexPath?.section)!
        print(sectionIndex)
        var arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
        let currentKey: String = arrayOfDataDictKeys[sectionIndex]
        print("current key: \(currentKey)")
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!
        
        let tomorrowDateInString = dateFormatter.string(from: tomorrowDate)
        let taskDateInString = dateFormatter.string(from: (editedTask.taskDate)!)
        let todayDateInString = dateFormatter.string(from: Date())
        let currentDateInString = dateFormatter.string(from: (Storage.storageData[currentKey]?[0].taskDate)!)
        
        
        // TODO: here
        let task = Storage.storageData[currentKey]?[(self.selectedRowIndexPath?.row)!]
        
        if task == editedTask {
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
        
        
        guard Storage.storageData[key] != nil else {
            Storage.storageData[key] = [editedTask]

            updateIndices(sectionKey: currentKey, removedIndex: Int((task?.taskOrderIndex)!))
            
            Storage.storageData[currentKey]?.remove(at: (self.selectedRowIndexPath?.row)!)
            filteredData[currentKey]?.remove(at: (self.selectedRowIndexPath?.row)!)

            do { // deletes initial copy of a task (AddActivityVCWithDate creats the new one)
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                context.delete(task!)
                
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
            
            // updating arrayOfDataDictKeys
            arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.storageData.keys)
            
            let updatedSectionIndex = arrayOfDataDictKeys.firstIndex(of: currentKey)!
            
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("should remove section \(sectionIndex)\nupdated section index: \(updatedSectionIndex)")
                self.deleteSectionIfNoActivities(sectionIndex: updatedSectionIndex)
                self.tableView.reloadData()
            }
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
            
            return
        }
        
        
        print("\n\n\nhere\n\n\n")
        
        if taskDateInString != currentDateInString {
            updateIndices(sectionKey: currentKey, removedIndex: Int((task?.taskOrderIndex)!))
            
            Storage.storageData[currentKey]?.remove(at: (self.selectedRowIndexPath?.row)!)
            filteredData[currentKey]?.remove(at: (self.selectedRowIndexPath?.row)!)
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                context.delete(task!)
                
                try context.save()
            } catch {
                print("Saving error: editSelectedTask 545")
            }
            
            Storage.storageData[key]?.append(editedTask)
            filteredData[key]?.append(editedTask)
        } else if taskDateInString == currentDateInString {
            if editedTask.taskReminderRel != nil {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!)
                cell?.accessoryView?.isHidden = false
            } else {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!) as! UICustomTableViewCell
                cancelNotification(cell: cell)
            }
            
            Storage.storageData[currentKey]?.remove(at: (self.selectedRowIndexPath?.row)!)
            filteredData[currentKey]?.remove(at: (self.selectedRowIndexPath?.row)!)
            
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                context.delete(task!)
                
                try context.save()
            } catch {
                print("Saving error: editSelectedTask 545")
            }
            
            
            Storage.storageData[currentKey]?.insert(editedTask, at: (self.selectedRowIndexPath?.row)!)
            filteredData[currentKey]?.insert(editedTask, at: (self.selectedRowIndexPath?.row)!)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("should remove section with index \(sectionIndex)")
            self.deleteSectionIfNoActivities(sectionIndex: sectionIndex)
            self.tableView.reloadData()
        }
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
    }
    
    func saveNewTask(_ newTask: MyTask) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full

        let taskDateStringRepresentation = dateFormatter.string(from: (newTask.taskDate)!)
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
        
        
        guard Storage.storageData[keyToInsert] != nil else {
            Storage.storageData[keyToInsert] = [newTask]
            
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
            
            return
        }
        

        Storage.storageData[keyToInsert]?.append(newTask)

        
        self.tableView.reloadData()
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
    }
}



extension InboxTabViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            searching = false
            filteredData = [:]
            self.tableView.reloadData()
            print("empty")
        } else {
            searching = true
            
            filteredData = Storage.storageData.filter({ (key: String, value: [MyTask]) in
    
                return key.range(of: searchText, options: .caseInsensitive) != nil
            })
            self.tableView.reloadData()
        }
        
    }
}

extension InboxTabViewController {
    private func updateIndices(sectionKey: String, removedIndex: Int) {
        if let tasks = Storage.storageData[sectionKey] {
            if tasks.count > removedIndex {
                for i in removedIndex + 1..<tasks.count {
                    tasks[i].taskOrderIndex -= 1
                }
            }
        }
    }
}
