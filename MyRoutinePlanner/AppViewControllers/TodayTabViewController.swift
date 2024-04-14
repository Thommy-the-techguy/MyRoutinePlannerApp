//
//  TodayTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit
import CoreData

class TodayTabViewController: UIViewController {
    //TODO: 1) Change reminder date if dragged or edited to another day (current behavour: when dragged dissapearse, when edited moves to another date) [x?] !!!
    //      2) When searching and dragging reminder image doesn't want to remove (Because of Thread that removes invalid reminders) [] !
    
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
        print("\(String(describing: Storage.storageData["Today"]?.count))")
        
        if Storage.storageData["Today"]?.count == 0 {
            Storage.storageData["Today"] = nil
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
        return Storage.storageData["Today"]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UICustomTableViewCell.identifier, for: indexPath) as! UICustomTableViewCell
        
        cell.delegate = self
        
        cell.backgroundColor = .white
        
        
        print("\n\n\nToday Tasks: \(Storage.tasks)\n\n\n")
        cell.setText((Storage.storageData["Today"]?[indexPath.row].taskTitle))
        cell.setDate((Storage.storageData["Today"]?[indexPath.row].taskDate))
        
        let imageSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        
        // change text label text size when settings updated
        cell.getCellTextLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))

        // change text label date text size when settings updated
        cell.getCellDateLabel().font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        // change buttons sizes
        let buttonsColor: UIColor = UIColor(hexString: (Storage.storageData["Today"]?[indexPath.row].taskPriorityRel?.priorityColor ?? "#00000")) ?? .gray
        
        let checkButtonImage = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(imageSize)))?.withTintColor(buttonsColor, renderingMode: .alwaysOriginal)
        cell.getCheckButton().setImage(checkButtonImage, for: .normal)
        
        
        // TODO: set notifications
        let accessoryButton = UIButton()
        accessoryButton.frame = CGRect(x: 0, y: 0, width: Int(imageSize), height: Int(imageSize)) // replace magic constants
        
        let reminderButtonImage = UIImage(systemName: "bell.badge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(Int(imageSize))))?.withTintColor(buttonsColor, renderingMode: .alwaysOriginal)
        accessoryButton.setImage(reminderButtonImage, for: .normal)
        
        accessoryButton.addTarget(self, action: #selector(cancelReminderWithIdentifier(sender: )), for: .touchUpInside)
        
        cell.accessoryView = accessoryButton
        
        if Storage.storageData["Today"]?[indexPath.row].taskReminderRel != nil {
            cell.accessoryView?.isHidden = false
        } else {
            cell.accessoryView?.isHidden = true
        }
        
        
        return cell
    }
    
    @objc private func cancelReminderWithIdentifier(sender: UIButton) {
        let cell = sender.superview as? UICustomTableViewCell
//        let reminder = Storage.storageData["Today"]?.getReminder(for: (cell?.indexPath?.row)!)
//        let reminderIdentifier = reminder?.reminderIdentifier
        let reminderIdentifier = Storage.storageData["Today"]?[(cell?.indexPath?.row)!].taskReminderRel?.reminderIdentifier
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification: UNNotificationRequest in notificationRequests {
               if notification.identifier == reminderIdentifier {
                  identifiers.append(notification.identifier)
               }
           }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        if let task = Storage.storageData["Today"]?[(cell?.indexPath?.row)!] {
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
        //remove reminder from CoreData
        
        cell?.accessoryView?.isHidden = true
        
        // TODO: maybe needed
//        DispatchQueue.main.async {
//            Storage().saveData()
//        }
    }

    
    // makes so the rows can be deleted
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    private func openEditView(initialTextViewText: String, initialFlag: Reminder?, initialPriority: Priority) {
        let editActivityVC = AddActivityWithDateViewController(initialTextViewText: initialTextViewText, initialTitle: "Edit Task", initialFlag: initialFlag, initialPriority: initialPriority)
        editActivityVC.delegate = self
        let editActivityNavigationController = UINavigationController(rootViewController: editActivityVC)
        editActivityNavigationController.modalPresentationStyle = .formSheet
        present(editActivityNavigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editButton = UIContextualAction(style: .normal, title: "Edit", handler: { [unowned self] (contextualAction, view, boolValue) in
            self.selectedRowIndexPath = indexPath
            
            let task = Storage.storageData["Today"]?[indexPath.row]
            
            let textViewText = (task?.taskTitle)!
            let reminder: Reminder? = task?.taskReminderRel
            let priority = (task?.taskPriorityRel)!
            
            self.openEditView(initialTextViewText: textViewText, initialFlag: reminder, initialPriority: priority)
        })
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { (contextualAction, view, boolValue) in
            
            let cell = tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
            self.cancelNotification(cell: cell)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Storage.storageData["Today"]?.remove(at: indexPath.row)
            self.makeValueNilForTodayKeyIfNoActivities()
            tableView.endUpdates()
    
            
            self.reloadDataWithDelay(0.3)
            print(Storage.storageData["Today"] as Any)
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
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
        
        
        let temp = Storage.storageData["Today"]?[sourceRowIndex]
        let destinationValue = Storage.storageData["Today"]?[destinationRowIndex]
        
        
        Storage.storageData["Today"]?[sourceRowIndex] = destinationValue!
        Storage.storageData["Today"]?[destinationRowIndex] = temp!
        
        
        print(Storage.storageData["Today"] as Any)
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
        dragItem.localObject = Storage.storageData["Today"]?[indexPath.row].taskTitle
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
        // checked circle color set
        let task = Storage.storageData["Today"]?[indexPath.row]
        let taskPriority = task?.taskPriorityRel
        let color: UIColor = UIColor(hexString: (taskPriority?.priorityColor)!)!
        
        let buttonsColor = color
        
        let imageSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        
        let checkButtonImage = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(imageSize)))?.withTintColor(buttonsColor, renderingMode: .alwaysOriginal)
        
        sender.setImage(checkButtonImage, for: .normal)
        
        let cell = self.tableView.cellForRow(at: indexPath) as! UICustomTableViewCell
        cancelNotification(cell: cell)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        let completedTask = Storage.storageData["Today"]?[indexPath.row].taskTitle
        let timeOfCompletion = Date()
        Storage.completedTasksData.append(key: completedTask!, value: timeOfCompletion)
        Storage.storageData["Today"]?.remove(at: indexPath.row)
        makeValueNilForTodayKeyIfNoActivities()
        self.tableView.endUpdates()
        
        print(Storage.storageData["Today"] ?? "nil")
        print("Completed Tasks: \(Storage.completedTasksData)")
        
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
    }
    
    func cancelNotification(cell: UICustomTableViewCell) {
        let reminder = Storage.storageData["Today"]?[(cell.indexPath?.row)!].taskReminderRel
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
        
        if let task = Storage.storageData["Today"]?[(cell.indexPath?.row)!] {
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

extension TodayTabViewController: AddActivityDelegate {
    func saveNewTask(_ newTask: MyTask) {
        
        
        
        guard var tasks = Storage.storageData["Today"] else {
            
            Storage.storageData["Today"] = [newTask]
            
            self.tableView.reloadData()
            
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! UICustomTableViewCell
            
            if newTask.taskReminderRel != nil {
                cell.accessoryView?.isHidden = false
            }
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
            
            return
        }
        
        tasks.append(newTask)
        Storage.storageData["Today"] = tasks
        
        self.tableView.reloadData()
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
    }
    
    func editSelectedTask(_ editedTask: MyTask) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let taskDateInString = dateFormatter.string(from: editedTask.taskDate!)
        let todayDateInString = dateFormatter.string(from: Date())
        
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!
        let tomorrowDateInString = dateFormatter.string(from: tomorrowDate)
        
        let task = Storage.storageData["Today"]?[(self.selectedRowIndexPath?.row)!]
       
        if editedTask == task {
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
        
        guard Storage.storageData[keyToInsert] != nil else {
            
            Storage.storageData[keyToInsert] = [editedTask]
            
            Storage.storageData["Today"]?.remove(at: (self.selectedRowIndexPath?.row)!)
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                context.delete(task!)
                
                try context.save()
            } catch {
                print("Saving error: editSelectedTask 545")
            }
            
            makeValueNilForTodayKeyIfNoActivities()
            
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
            
            return
        }
        
        
        if taskDateInString != todayDateInString {
            Storage.storageData[taskDateInString]?.append(editedTask)
        } else if taskDateInString == todayDateInString {
            if editedTask.taskReminderRel != nil {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!)
                cell?.accessoryView?.isHidden = false
            } else {
                let cell = self.tableView.cellForRow(at: selectedRowIndexPath!) as! UICustomTableViewCell
                cancelNotification(cell: cell)
            }
            
            let selectedRowIndex = (self.selectedRowIndexPath?.row)!
            Storage.storageData["Today"]?.remove(at: selectedRowIndex)
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                context.delete(task!)
                
                try context.save()
            } catch {
                print("Saving error: editSelectedTask 545")
            }
            
            Storage.storageData["Today"]?.insert(editedTask, at: selectedRowIndex)
        }
        
        makeValueNilForTodayKeyIfNoActivities()
        
        self.tableView.reloadData()
        
        DispatchQueue.main.async {
            Storage().saveData()
        }
    }
}
