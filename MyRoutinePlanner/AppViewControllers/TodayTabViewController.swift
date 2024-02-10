//
//  TodayTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class TodayTabViewController: UIViewController {
    
    var tableView: UITableView! = nil

    var activityViewController: UIActivityViewController?
    var selectedRowIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: Notification.Name("TabSwitched"), object: nil)
        
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // set view title for navPanel
        title = "Today"
        
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
        self.tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
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
        
        
        return cell
    }
    
    // makes so the rows can be deleted
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tableView.beginUpdates()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            Storage.inboxData["Today"]?.removeKeyAndValue(for: indexPath.row)
//            makeValueNilForTodayKeyIfNoActivities()
//            tableView.endUpdates()
//    
//            
//            reloadDataWithDelay(0.3)
//            print(Storage.inboxData["Today"] as Any)
//        }
    }
    
    private func openEditView(initialTextViewText: String) {
        let editActivityVC = AddActivityWithDateViewController(initialTextViewText: initialTextViewText, initialTitle: "Edit Task")
        editActivityVC.delegate = self
        let editActivityNavigationController = UINavigationController(rootViewController: editActivityVC)
        editActivityNavigationController.modalPresentationStyle = .formSheet
        present(editActivityNavigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editButton = UIContextualAction(style: .normal, title: "Edit", handler: { (contextualAction, view, boolValue) in
            self.selectedRowIndexPath = indexPath
            self.openEditView(initialTextViewText: (Storage.inboxData["Today"]?.getKey(for: indexPath.row))!)
        })
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { (contextualAction, view, boolValue) in
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
        
        
        Storage.inboxData["Today"]?.setKeyAndValue(for: sourceRowIndex, key: (destinationKeyAndValue?.key)!, value: (destinationKeyAndValue?.value)!)
        Storage.inboxData["Today"]?.setKeyAndValue(for: destinationRowIndex, key: (temp?.key)!, value: (temp?.value)!)
        
        
        print(Storage.inboxData["Today"] as Any)
    }
    
    @objc func reloadTableViewData() {
        self.tableView.reloadData()
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
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        Storage.inboxData["Today"]?.removeKeyAndValue(for: indexPath.row)
        makeValueNilForTodayKeyIfNoActivities()
        self.tableView.endUpdates()
        
        print(Storage.inboxData["Today"] ?? "nil")
    }
}

extension TodayTabViewController: AddActivityDelegate {
    func saveNewTask(_ newTask: String, taskDate: Date) {
        guard var keyValuePairs = Storage.inboxData["Today"] else {
            Storage.inboxData["Today"] = CustomKeyValuePairs(
                arrayOfKeys: [newTask],
                arrayOfValues: [taskDate]
            )
            
            self.tableView.reloadData()
            
            return
        }
        
        keyValuePairs.append(key: newTask, value: taskDate)
        Storage.inboxData["Today"] = keyValuePairs
        
        self.tableView.reloadData()
    }
    
    func editSelectedTask(taskText: String, taskDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let taskDateInString = dateFormatter.string(from: taskDate)
        let todayDateInString = dateFormatter.string(from: Date())
        
       
        if taskText == Storage.inboxData["Today"]?.getKey(for: (self.selectedRowIndexPath?.row)!) && taskDateInString == todayDateInString {
            return
        }
        
        
        guard var taskDateKeyValuePairs = Storage.inboxData[taskDateInString] else {
            let tomorrowDate = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: Date())!
            let tomorrowDateInString = dateFormatter.string(from: tomorrowDate)
            
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
            
            Storage.inboxData[key] = CustomKeyValuePairs(
                arrayOfKeys: [taskText],
                arrayOfValues: [taskDate]
            )
            
            Storage.inboxData["Today"]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
            
            makeValueNilForTodayKeyIfNoActivities()
            
            self.tableView.reloadData()
            
            return
        }
        
        
        Storage.inboxData["Today"]?.removeKeyAndValue(for: (self.selectedRowIndexPath?.row)!)
        
        if taskDateInString != todayDateInString {
            Storage.inboxData[taskDateInString]?.append(key: taskText, value: taskDate)
        } else if taskDateInString == todayDateInString {
            Storage.inboxData["Today"]?.insert(at: (self.selectedRowIndexPath?.row)!, key: taskText, value: taskDate)
        }
        
        makeValueNilForTodayKeyIfNoActivities()
        
        self.tableView.reloadData()
    }
}
