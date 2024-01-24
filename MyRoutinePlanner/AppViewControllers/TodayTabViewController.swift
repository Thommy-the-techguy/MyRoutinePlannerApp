//
//  TodayTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class TodayTabViewController: UIViewController {
    
    var tableView: UITableView! = nil
    var newDataWithDate: CustomKeyValuePairs<String, Date> = CustomKeyValuePairs()/*CustomKeyValuePairs(
        arrayOfKeys: [
            "marsoiuewirjwlkfjdslkfjls jkfjsljfiuweroiwejlf sjdlfj ksdjrieuwor jlksdj flwuero jdsfj flwueroi uwsdkjfluweor jflsdjf weuirwerjlkfsjd oiwerj lsdjf uwioerj fsdlkjf uoiewr ",
                      "earth",
                      "jupiter",
                      "venus",
                      "saturn"
        ],
        arrayOfValues: [
            Date(),
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 4, to: Date())!
        ]
    )*/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add notification observer for starting app
        NotificationCenter.default.addObserver(self, selector: #selector(readData), name: Notification.Name("AppLoaded"), object: nil)
        
        // add notification observer for terminating app
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: Notification.Name("AppAboutToTerminate"), object: nil)
        
        // setting view's background color
        view.backgroundColor = .systemGray6
        
        // scroll edge initialization for navBar
        navigationController?.navigationBar.scrollEdgeAppearance = .init()
        
        // set view title for navPanel
        title = "Today"
        
        // add
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewActivity))
        
        // func for tableView configuration
        configureTableView()
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
        self.tableView.dataSource = self
        self.tableView.dragDelegate = self
        UICustomTableViewCell.delegate = self
        
        view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ])
    }

    // MARK: - #selectors
    
    @objc private func addNewActivity() {
        let newActivityVC = AddActivityViewController()
        newActivityVC.delegate = self
        let newActivityNavigationController = UINavigationController(rootViewController: newActivityVC)
        newActivityNavigationController.modalPresentationStyle = .formSheet
        present(newActivityNavigationController, animated: true)
    }
    
    
    // process app termination
    @objc private func saveData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.newDataWithDate) {
            UserDefaults.standard.set(encoded, forKey: "TodayTasks")
            print(String(data: encoded, encoding: .utf8) ?? "No data aqcuired!")
        } else {
            print("An encoding error has ocurred!")
        }
    }
    
    // process readingSavedData when scene will load
    @objc func readData() {
        if let savedData = UserDefaults.standard.object(forKey: "TodayTasks") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(CustomKeyValuePairs<String, Date>.self, from: savedData) {
                self.newDataWithDate = loadedData
                
                self.tableView.reloadData()
                
                print("data has been loaded.")
            }
        }
    }
}

extension TodayTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newDataWithDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UICustomTableViewCell.identifier, for: indexPath) as! UICustomTableViewCell
        cell.backgroundColor = .white
        cell.setText(newDataWithDate.getKey(for: indexPath.row))
        cell.setDate(newDataWithDate.getValue(for: indexPath.row))
        
        
        return cell
    }
    
    // makes so the rows can be deleted
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            newDataWithDate.removeKeyAndValue(for: indexPath.row)
            tableView.endUpdates()
    
            
            reloadDataWithDelay(0.3)
            print(newDataWithDate)
        }
    }
    
    // allows to dragAndDrop selected tableCell
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // swapping two items with drag and drop
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = newDataWithDate.getKeyAndValue(for: sourceIndexPath.row)
        newDataWithDate.setKeyAndValue(for: sourceIndexPath.row, key: newDataWithDate.getKey(for: destinationIndexPath.row), value: newDataWithDate.getValue(for: destinationIndexPath.row))
        newDataWithDate.setKeyAndValue(for: destinationIndexPath.row, key: temp.key, value: temp.value)
        tableView.reloadData()
        print(newDataWithDate)
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
        dragItem.localObject = newDataWithDate.getKey(for: indexPath.row)
        return [dragItem]
    }
}

extension TodayTabViewController: CustomTableViewCellDelegate {
    func removeCheckedRow(sender: UIButton, indexPath: IndexPath) {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.newDataWithDate.removeKeyAndValue(for: indexPath.row)
        self.tableView.endUpdates()
        
        print(newDataWithDate)
    }
}

extension TodayTabViewController: AddActivityDelegate {
    func saveNewTask(_ newTask: String, taskDate: Date) {
        self.newDataWithDate.append(key: newTask, value: taskDate)
        self.tableView.reloadData()
    }
}
