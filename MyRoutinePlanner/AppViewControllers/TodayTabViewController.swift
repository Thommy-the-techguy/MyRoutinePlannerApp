//
//  TodayTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class TodayTabViewController: UIViewController {
    
    var tableView: UITableView! = nil
    var data = ["marsoiuewirjwlkfjdslkfjls jkfjsljfiuweroiwejlf sjdlfj ksdjrieuwor jlksdj flwuero jdsfj flwueroi uwsdkjfluweor jflsdjf weuirwerjlkfsjd oiwerj lsdjf uwioerj fsdlkjf uoiewr ", "earth", "jupiter", "venus", "saturn"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // setting view's background color
        view.backgroundColor = .white
        
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
//        let navBarPlusStatusBarHeight = (navigationController?.navigationBar.frame.height)! + self.statusBarHeight
//        let tabBarHeight = (tabBarController?.tabBar.frame.height)!
//        let tableViewHeight = view.frame.height - (navBarPlusStatusBarHeight + tabBarHeight)
//        
//        tableView = UITableView(frame: CGRect(x: 0.0, y: navBarPlusStatusBarHeight, width: view.frame.width, height: tableViewHeight))
        self.tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))

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
    
    @objc func addNewActivity() {
        //TODO: - add activity
        let newActivityVC = AddActivityViewController()
        newActivityVC.modalPresentationStyle = .formSheet
        present(newActivityVC, animated: true)
    }
}

extension TodayTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UICustomTableViewCell.identifier, for: indexPath) as! UICustomTableViewCell
        cell.setText(data[indexPath.row])
        
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
            data.remove(at: indexPath.row)
            tableView.endUpdates()
    
            
            reloadDataWithDelay(0.3)
            print(data)
        }
    }
    
//    // adds space when overflow in the row happens
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        print((tableView.cellForRow(at: indexPath) as! UICustomTableViewCell).labelSize.height)
////        return UITableView.automaticDimension
//        return UITableView.automaticDimension
//    }
    
    // allows to dragAndDrop selected tableCell
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // swapping two items with drag and drop
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = data[sourceIndexPath.row]
        data[sourceIndexPath.row] = data[destinationIndexPath.row]
        data[destinationIndexPath.row] = temp
        tableView.reloadData()
        print(data)
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
        dragItem.localObject = data[indexPath.row]
        return [dragItem]
    }
}

extension TodayTabViewController: CustomTableViewCellDelegate {
    func removeCheckedRow(sender: UIButton, indexPath: IndexPath) {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.data.remove(at: indexPath.row)
        self.tableView.endUpdates()
        
        print(data)
    }
}
