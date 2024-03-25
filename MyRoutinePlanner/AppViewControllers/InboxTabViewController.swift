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
    
    var filteredData: [String:KeyValuePairsWithFlag<String, Date>] = [:]
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
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[sectionIndex]
        
        print("called", currentKey)
        print("Section Index To Remove\(String(describing: Storage.inboxData[currentKey]?.count))")
        
        if Storage.inboxData[currentKey]?.count == 0 {
            Storage.inboxData[currentKey] = nil
            filteredData[currentKey] = nil
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
        return searching ? filteredData.count : Storage.inboxData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return searching ? (filteredData[currentKey]?.count)! : (Storage.inboxData[currentKey]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! UICustomTableViewCell // don't change the identifier!!!
        
        
        cell.delegate = self
        
        
        let section = indexPath.section
        let indexOfCell = indexPath.row
        
        
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        let message = searching ? filteredData[currentKey]?.getKey(for: indexOfCell) : Storage.inboxData[currentKey]?.getKey(for: indexOfCell)
        let date = searching ? filteredData[currentKey]?.getValue(for: indexOfCell) : Storage.inboxData[currentKey]?.getValue(for: indexOfCell)
        
        
        let imageSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        
        
        // MARK: - maybe not even necessary
        if let message, let date {
            cell.setText(message)
            cell.setDate(date)
            
            // change text label text size when settings updated
            cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
            
            // change text label date text size when settings updated
            cell.getCellDateLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
            
            // change buttons sizes
            let checkButtonImage = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(Int(imageSize))))?.withTintColor(.gray, renderingMode: .alwaysOriginal)
            
            cell.getCheckButton().setImage(checkButtonImage, for: .normal)
        }
        
        // setting reminder button
        let accessoryButton = UIButton()
        accessoryButton.frame = CGRect(x: 0, y: 0, width: Int(imageSize), height: Int(imageSize)) // replace magic constants

        let reminderButtonImage = UIImage(systemName: "bell.badge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(Int(imageSize))))?.withTintColor(.gray, renderingMode: .alwaysOriginal)
//        accessoryButton.setImage(UIImage(systemName: "bell.badge.fill"), for: .normal)
        accessoryButton.setImage(reminderButtonImage, for: .normal)

        accessoryButton.addTarget(self, action: #selector(cancelReminderWithIdentifier(sender: )), for: .touchUpInside)
        
        cell.accessoryView = accessoryButton
        
        if searching ? (filteredData[currentKey]?.getReminder(for: indexPath.row) != nil) : (Storage.inboxData[currentKey]?.getReminder(for: indexPath.row) != nil) {
            cell.accessoryView?.isHidden = false
        } else {
            cell.accessoryView?.isHidden = true
        }
        
        return cell
    }
    
    @objc private func cancelReminderWithIdentifier(sender: UIButton) {
        let cell = sender.superview as? UICustomTableViewCell
        let reminder = Storage.inboxData["Today"]?.getReminder(for: (cell?.indexPath?.row)!)
        let reminderIdentifier = reminder?.reminderIdentifier
        
        let section = (cell?.indexPath?.section)!
        let arrayOfDataDictKeys = Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        Storage.inboxData[currentKey]?.setReminder(for: (cell?.indexPath?.row)!, withReminder: nil)
        
        cell?.accessoryView?.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        return currentKey
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.textColor = UIColor.red
        
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
    
    private func openEditView(initialTextViewText: String, initialDate: Date, initialFlag: Reminder?) {
        let editActivityVC = AddActivityWithDateViewController(initialTextViewText: initialTextViewText, initialTitle: "Edit Task", initialDate: initialDate, initialFlag: initialFlag)
        editActivityVC.delegate = self
        let editActivityNavigationController = UINavigationController(rootViewController: editActivityVC)
        editActivityNavigationController.modalPresentationStyle = .formSheet
        present(editActivityNavigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editButton = UIContextualAction(style: .normal, title: "Edit", handler: { [unowned self] (contextualAction, view, boolValue) in
            let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            self.selectedRowIndexPath = indexPath
            
            let (initialText, initialDate, reminder) = (Storage.inboxData[currentKey]?.getKeyAndValue(for: indexPath.row))!
            
            self.openEditView(initialTextViewText: initialText, initialDate: initialDate, initialFlag: reminder)
        })
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { [unowned self] (contextualAction, view, boolValue) in
            let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
            let currentKey: String = arrayOfDataDictKeys[indexPath.section]
            
            
            let cell = tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
            self.cancelNotification(cell: cell)
            
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: indexPath.row)
            filteredData[currentKey]?.removeKeyAndValue(for: indexPath.row)
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
        
        
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[sourceSection]
        let destinationKey: String = arrayOfDataDictKeys[destinationSection]
        
        
        if sourceSection != destinationSection {
            var keyAndValueToAppend = Storage.inboxData[currentKey]?.getKeyAndValue(for: sourceRowIndex)
            
            // MARK: - force unwrapping?
            let destinationDate = Storage.inboxData[destinationKey]?.getValue(for: 0)
            
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: destinationDate!)
            
            keyAndValueToAppend?.value = Calendar.current.date(from: dateComponents)!
            
            
            // remove notification when moved to another section
            let cell = self.tableView.cellForRow(at: sourceIndexPath) as! UICustomTableViewCell
            cancelNotification(cell: cell)
            
            
            Storage.inboxData[destinationKey]?.append(key: (keyAndValueToAppend?.key)!, value: (keyAndValueToAppend?.value)!, withReminder: keyAndValueToAppend?.reminder)
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: sourceRowIndex)
            
            filteredData[destinationKey]?.append(key: (keyAndValueToAppend?.key)!, value: (keyAndValueToAppend?.value)!, withReminder: keyAndValueToAppend?.reminder)
            filteredData[currentKey]?.removeKeyAndValue(for: sourceRowIndex)
            
        } else {
            let temp = Storage.inboxData[currentKey]?.getKeyAndValue(for: sourceRowIndex)
            let destinationKeyAndValue = Storage.inboxData[destinationKey]?.getKeyAndValue(for: destinationRowIndex)
            
            
            Storage.inboxData[currentKey]?.setKeyAndValue(for: sourceRowIndex, key: (destinationKeyAndValue?.key)!, value: (destinationKeyAndValue?.value)!, withReminder: destinationKeyAndValue?.reminder)
            Storage.inboxData[destinationKey]?.setKeyAndValue(for: destinationRowIndex, key: (temp?.key)!, value: (temp?.value)!, withReminder: temp?.reminder)
            
            
            filteredData[currentKey]?.setKeyAndValue(for: sourceRowIndex, key: (destinationKeyAndValue?.key)!, value: (destinationKeyAndValue?.value)!, withReminder: destinationKeyAndValue?.reminder)
            filteredData[destinationKey]?.setKeyAndValue(for: destinationRowIndex, key: (temp?.key)!, value: (temp?.value)!, withReminder: temp?.reminder)
        }
        
        // TODO: - maybe do it with delay
        self.tableView.performBatchUpdates({ () in
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
        // TODO: Implement colors and checkmark.circle of color according to Storage.data
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[indexPath.section]
        print("current key: \(currentKey) row: \(indexPath.row) section: \(indexPath.section)")
        let cell = self.tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
        cancelNotification(cell: cell)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        Storage.inboxData[currentKey]?.removeKeyAndValue(for: indexPath.row)
        filteredData[currentKey]?.removeKeyAndValue(for: indexPath.row)
        self.tableView.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.deleteSectionIfNoActivities(sectionIndex: indexPath.section)
            self.tableView.reloadData()
        }
        
        print(Storage.inboxData)
    }
    
    func cancelNotification(cell: UICustomTableViewCell) {
//        let cellText = cell.getCellTextLabel().text!
//        let sectionKey = (self.tableView.headerView(forSection: (cell.indexPath?.section)!)?.textLabel?.text)!
//        let taskIndex = cell.indexPath?.row
        
        let section = (cell.indexPath?.section)!
        let arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[section]
        
        let reminder = Storage.inboxData[currentKey]?.getReminder(for: (cell.indexPath?.row)!)
        let reminderIdentifier = reminder?.reminderIdentifier
        
//        print("current key: \(currentKey)")
//        print("current key: \(reminderIdentifier)")
//        print("current key: \(Storage.inboxData[currentKey])")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        Storage.inboxData[currentKey]?.setReminder(for: (cell.indexPath?.row)!, withReminder: nil)
        filteredData[currentKey]?.setReminder(for: (cell.indexPath?.row)!, withReminder: nil)
        
        cell.accessoryView?.isHidden = true
    }
}


extension InboxTabViewController: AddActivityDelegate {
    func editSelectedTask(taskText: String, taskDate: Date, withReminder: Reminder?) {
        let sectionIndex = (self.selectedRowIndexPath?.section)!
        print(sectionIndex)
        var arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
        let currentKey: String = arrayOfDataDictKeys[sectionIndex]
        print("current key: \(currentKey)")
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!
        
        let tomorrowDateInString = dateFormatter.string(from: tomorrowDate)
        let taskDateInString = dateFormatter.string(from: taskDate)
        let todayDateInString = dateFormatter.string(from: Date())
        let currentDateInString = dateFormatter.string(from: (Storage.inboxData[currentKey]?.getValue(for: 0))!)
        
        
        // TODO: here
        if taskText == Storage.inboxData[currentKey]?.getKey(for: (self.selectedRowIndexPath?.row)!) && taskDateInString == currentDateInString && withReminder == Storage.inboxData[currentKey]?.getReminder(for: (self.selectedRowIndexPath?.row)!) {
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
        
        
        guard Storage.inboxData[key] != nil else {
            
            Storage.inboxData[key] = KeyValuePairsWithFlag(
                arrayOfKeys: [taskText],
                arrayOfValues: [taskDate],
                arrayOfReminders: [withReminder]
            )
            
            Storage.inboxData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
            filteredData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
            
            // updating arrayOfDataDictKeys
            arrayOfDataDictKeys = searching ? Array(filteredData.keys) : Array(Storage.inboxData.keys)
            
            let updatedSectionIndex = arrayOfDataDictKeys.firstIndex(of: currentKey)!
            
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("should remove section \(sectionIndex)\nupdated section index: \(updatedSectionIndex)")
                self.deleteSectionIfNoActivities(sectionIndex: updatedSectionIndex)
                self.tableView.reloadData()
            }
            
            return
        }
        
        
        print("\n\n\nhere\n\n\n")
//        Storage.inboxData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
//        filteredData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
        let cell = self.tableView.cellForRow(at: selectedRowIndexPath!) as! UICustomTableViewCell
        cancelNotification(cell: cell)
        
        Storage.inboxData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
        filteredData[currentKey]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
        
        if taskDateInString != currentDateInString {
            Storage.inboxData[key]?.append(key: taskText, value: taskDate, withReminder: withReminder)
            filteredData[key]?.append(key: taskText, value: taskDate, withReminder: withReminder)
        } else if taskDateInString == currentDateInString {
            Storage.inboxData[currentKey]?.insert(at: (self.selectedRowIndexPath?.row)!, key: taskText, value: taskDate, withReminder: withReminder)
            filteredData[currentKey]?.insert(at: (self.selectedRowIndexPath?.row)!, key: taskText, value: taskDate, withReminder: withReminder)
            
            if withReminder != nil {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!)
                cell?.accessoryView?.isHidden = false
            } else {
//                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!) as! UICustomTableViewCell
//                cancelNotification(cell: cell)
            }
        }
        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("should remove section with index \(sectionIndex)")
            self.deleteSectionIfNoActivities(sectionIndex: sectionIndex)
            self.tableView.reloadData()
        }
    }
    
    func saveNewTask(_ newTask: String, taskDate: Date, withReminder: Reminder?) {
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
        
        
        guard Storage.inboxData[keyToInsert] != nil else {
            
            Storage.inboxData[keyToInsert] = KeyValuePairsWithFlag(
                arrayOfKeys: [newTask],
                arrayOfValues: [taskDate],
                arrayOfReminders: [withReminder]
            )
            
            self.tableView.reloadData()
            
            return
        }
        

        Storage.inboxData[keyToInsert]?.append(key: newTask, value: taskDate, withReminder: withReminder)

        
        self.tableView.reloadData()
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
            
            filteredData = Storage.inboxData.filter({ (key: String, value: KeyValuePairsWithFlag<String, Date>) in
    
                return key.range(of: searchText, options: .caseInsensitive) != nil
            })
            self.tableView.reloadData()
        }
        
    }
}
