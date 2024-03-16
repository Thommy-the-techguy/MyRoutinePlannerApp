//
//  TodayTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class TodayTabViewController: UIViewController {
    //TODO: 1) Add reminder when editing + remain switch on when entering editing if reminder was added before [x]
    //      2) Remove reminder when editing if it was added and switch now is turned off [x]
    //      3) Change reminder date if dragged or edited to another day [x?]
    //      4) Think about how to improve diversity of identifiers, so you can add dublicate messages []
    //      5) Fix can't set reminder less then current time but the day isn't today []
    //      6) When searching and dragging reminder image doesn't want to remove (Because of Thread that removes invalid reminders) []
    //      7) Fix issue when opening edit of the cell and reminder time isn't what it was set before []
    
    // MARK: fonts to try later: "Noteworthy-Bold", "Noteworthy-Light", "Baskerville-SemiBoldItalic", "Baskerville-BoldItalic", "Baskerville-Italic"
    
    
    var tableView: UITableView! = nil

    var activityViewController: UIActivityViewController?
    var selectedRowIndexPath: IndexPath?
    
    var currentTextSizePreference = Storage.textSizePreference
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Today"
        configuredTitleLabel.textAlignment = .center
        
        let fontSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(fontSize))
        
        return configuredTitleLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name("TabSwitched"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewDataAsync), name: Notification.Name("ReloadData"), object: nil)
        
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // set view title for navPanel
//        title = "Today"
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
        
        // add
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewActivity))
        
        // share
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(shareViewAppear))
        
        // func for tableView configuration
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.post(Notification(name: Notification.Name("TabSwitched")))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func configureTableView() {
        // configure UITableView
        tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 20
        
        self.tableView.register(UICustomTableViewCell.self, forCellReuseIdentifier: UICustomTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.dragDelegate = self
        
        view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ])
    }
    
    func makeValueNilForTodayKeyIfNoActivities() {
        print("called", "Today")
        print("\(String(describing: Storage.inboxData["Today"]?.count))")
        
        if Storage.inboxData["Today"]?.count == 0 {
            Storage.inboxData["Today"] = nil
        }
    }

    // MARK: - #selectors
    
    @objc private func addNewActivity() {
        let newActivityVC = AddActivityViewController()
        newActivityVC.delegate = self
        let newActivityNavigationController = UINavigationController(rootViewController: newActivityVC)
        newActivityNavigationController.modalPresentationStyle = .formSheet
        present(newActivityNavigationController, animated: true)
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

extension TodayTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.inboxData["Today"]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UICustomTableViewCell.identifier, for: indexPath) as! UICustomTableViewCell
        
        cell.delegate = self
        
        cell.backgroundColor = .white
        
        cell.setText((Storage.inboxData["Today"]?.getKey(for: indexPath.row))!)
        cell.setDate((Storage.inboxData["Today"]?.getValue(for: indexPath.row))!)
        
        let imageSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        
        // change text label text size when settings updated
        cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))

        // change text label date text size when settings updated
        cell.getCellDateLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        // change buttons sizes
        let checkButtonImage = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(Int(imageSize))))?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        cell.getCheckButton().setImage(checkButtonImage, for: .normal)
        
        
        // TODO: set notifications
        let accessoryButton = UIButton()
        accessoryButton.frame = CGRect(x: 0, y: 0, width: Int(imageSize), height: Int(imageSize)) // replace magic constants
        
        let reminderButtonImage = UIImage(systemName: "bell.badge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(Int(imageSize))))?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        accessoryButton.setImage(reminderButtonImage, for: .normal)
        
        accessoryButton.setImage(UIImage(systemName: "bell.badge.fill"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(cancelReminderWithIdentifier(sender: )), for: .touchUpInside)
        
        cell.accessoryView = accessoryButton
        
        if (Storage.inboxData["Today"]?.getFlag(for: indexPath.row))! {
            cell.accessoryView?.isHidden = false
        } else {
            cell.accessoryView?.isHidden = true
        }
        
        
        return cell
    }
    
    @objc private func cancelReminderWithIdentifier(sender: UIButton) {
        let cell = sender.superview as? UICustomTableViewCell
        let cellText = (cell?.getCellTextLabel().text)!
        let reminderIdentifier = cellText + "-notification"
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        Storage.inboxData["Today"]?.setFlag(for: (cell?.indexPath?.row)!, withReminder: false)
        
        cell?.accessoryView?.isHidden = true
    }

    
    // makes so the rows can be deleted
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    private func openEditView(initialTextViewText: String, initialFlag: Bool) {
        let editActivityVC = AddActivityWithDateViewController(initialTextViewText: initialTextViewText, initialTitle: "Edit Task", initialFlag: initialFlag)
        editActivityVC.delegate = self
        let editActivityNavigationController = UINavigationController(rootViewController: editActivityVC)
        editActivityNavigationController.modalPresentationStyle = .formSheet
        present(editActivityNavigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editButton = UIContextualAction(style: .normal, title: "Edit", handler: { [unowned self] (contextualAction, view, boolValue) in
            self.selectedRowIndexPath = indexPath
            
            let (textViewText, _, flag) = (Storage.inboxData["Today"]?.getKeyAndValue(for: indexPath.row))!
            
            // remove notification so it won't double when changing task text
            let cell = tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
            cancelNotification(cell: cell)
            
            self.openEditView(initialTextViewText: textViewText, initialFlag: flag)
        })
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { (contextualAction, view, boolValue) in
            
            let cell = tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
            self.cancelNotification(cell: cell)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Storage.inboxData["Today"]?.removeKeyAndValue(for: indexPath.row)
            self.makeValueNilForTodayKeyIfNoActivities()
            tableView.endUpdates()
    
            
            self.reloadDataWithDelay(0.3)
            print(Storage.inboxData["Today"] as Any)
        })

        let swipeActions = UISwipeActionsConfiguration(actions: [editButton, deleteButton])
        
        return swipeActions
    }
    
    // allows to dragAndDrop selected tableCell
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // swapping two items with drag and drop
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceRowIndex = sourceIndexPath.row
        let destinationRowIndex = destinationIndexPath.row
        
        
        let temp = Storage.inboxData["Today"]?.getKeyAndValue(for: sourceRowIndex)
        let destinationKeyAndValue = Storage.inboxData["Today"]?.getKeyAndValue(for: destinationRowIndex)
        
        
        Storage.inboxData["Today"]?.setKeyAndValue(for: sourceRowIndex, key: (destinationKeyAndValue?.key)!, value: (destinationKeyAndValue?.value)!, withReminder: (destinationKeyAndValue?.flag)!)
        Storage.inboxData["Today"]?.setKeyAndValue(for: destinationRowIndex, key: (temp?.key)!, value: (temp?.value)!, withReminder: (temp?.flag)!)
        
        
        print(Storage.inboxData["Today"] as Any)
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
    
    // MARK: UITableViewDataSource extension #selectors
        
    @objc func reloadDataWithDelay(_ delay: TimeInterval) {
        perform(#selector(reloadTableViewData), with: nil, afterDelay: delay)
    }
}

extension TodayTabViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = Storage.inboxData["Today"]?.getKey(for: indexPath.row)
        return [dragItem]
    }
}

extension TodayTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRowIndexPath = indexPath
        print("Row at \(indexPath.row) has been selected")
    }
}

extension TodayTabViewController: CustomTableViewCellDelegate {
    func removeCheckedRow(sender: UIButton, indexPath: IndexPath) {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        
        let cell = self.tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
        cancelNotification(cell: cell)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        Storage.inboxData["Today"]?.removeKeyAndValue(for: indexPath.row)
        makeValueNilForTodayKeyIfNoActivities()
        self.tableView.endUpdates()
        
        print(Storage.inboxData["Today"] ?? "nil")
    }
    
    func cancelNotification(cell: UICustomTableViewCell) {
        let cellText = cell.getCellTextLabel().text!
        let reminderIdentifier = cellText + "-notification"
        
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        Storage.inboxData["Today"]?.setFlag(for: (cell.indexPath?.row)!, withReminder: false)
        
        cell.accessoryView?.isHidden = true
    }
}

extension TodayTabViewController: AddActivityDelegate {
    func saveNewTask(_ newTask: String, taskDate: Date, withReminder: Bool) {
        guard var keyValuePairs = Storage.inboxData["Today"] else {
            
            Storage.inboxData["Today"] = KeyValuePairsWithFlag(
                arrayOfKeys: [newTask],
                arrayOfValues: [taskDate],
                arrayOfFlags: [withReminder]
            )

            
            
            self.tableView.reloadData()
            
            if withReminder {
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                cell?.accessoryView?.isHidden = false
            }
            
            return
        }
        
        keyValuePairs.append(key: newTask, value: taskDate, withReminder: withReminder)
        Storage.inboxData["Today"] = keyValuePairs
        
        self.tableView.reloadData()
    }
    
    func editSelectedTask(taskText: String, taskDate: Date, withReminder: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let taskDateInString = dateFormatter.string(from: taskDate)
        let todayDateInString = dateFormatter.string(from: Date())
        
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!
        let tomorrowDateInString = dateFormatter.string(from: tomorrowDate)
        
       
        if taskText == Storage.inboxData["Today"]?.getKey(for: (self.selectedRowIndexPath?.row)!) && taskDateInString == todayDateInString && withReminder == Storage.inboxData["Today"]?.getFlag(for: (self.selectedRowIndexPath?.row)!){
            return
        }
        
        var keyToInsert: String
        
        switch taskDateInString {
            case todayDateInString:
                keyToInsert = "Today"
                print(keyToInsert)
            case tomorrowDateInString:
                keyToInsert = "Tomorrow"
                print(keyToInsert)
            default:
                keyToInsert = taskDateInString
                print(keyToInsert)
        }
        
        print("Passed")
        
        guard Storage.inboxData[keyToInsert] != nil else {
            
            Storage.inboxData[keyToInsert] = KeyValuePairsWithFlag(
                arrayOfKeys: [taskText],
                arrayOfValues: [taskDate],
                arrayOfFlags: [withReminder]
            )
            
            Storage.inboxData["Today"]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
            
            makeValueNilForTodayKeyIfNoActivities()
            
            self.tableView.reloadData()
            
            return
        }
        
        let selectedRowIndex = (self.selectedRowIndexPath?.row)!
        Storage.inboxData["Today"]?.removeKeyAndValue(for: selectedRowIndex)
        
        if taskDateInString != todayDateInString {
            Storage.inboxData[taskDateInString]?.append(key: taskText, value: taskDate, withReminder: withReminder)
        } else if taskDateInString == todayDateInString {
            Storage.inboxData["Today"]?.insert(at: selectedRowIndex, key: taskText, value: taskDate, withReminder: withReminder)
            
            if withReminder {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!)
                cell?.accessoryView?.isHidden = false
            } else {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!) as! UICustomTableViewCell
                cancelNotification(cell: cell)
            }
        }
        
        makeValueNilForTodayKeyIfNoActivities()
        
        self.tableView.reloadData()
    }
}
