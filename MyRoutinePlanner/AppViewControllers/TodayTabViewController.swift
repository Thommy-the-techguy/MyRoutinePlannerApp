//
//  TodayTabViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class TodayTabViewController: UIViewController {
    
    var tableView: UITableView? = nil
    var data = ["mars", "earth", "jupiter", "venus", "saturn"]

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

        // configure UITableView
        let navBarPlusStatusBarHeight = (navigationController?.navigationBar.frame.height)! + self.statusBarHeight
        let tabBarHeight = (tabBarController?.tabBar.frame.height)!
        let tableViewHeight = view.frame.height - (navBarPlusStatusBarHeight + tabBarHeight)
        
        tableView = UITableView(frame: CGRect(x: 0.0, y: navBarPlusStatusBarHeight, width: view.frame.width, height: tableViewHeight))
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.dataSource = self
        tableView?.dragDelegate = self
        
        view.addSubview(tableView!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - #selectors
    
    @objc func addNewActivity() {
        //TODO: - add activity
//        data.append("smth new")
//        tableView?.beginUpdates()
//        tableView?.insertRows(at: [IndexPath.init(row: data.count - 1, section: 0)], with: .automatic)
//        tableView?.endUpdates()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row). \(data[indexPath.row])"
        cell.textLabel?.numberOfLines = 0
        
        let checkbox = UICellAccessoryCheckbox(indexPath: indexPath)
        checkbox.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        checkbox.setImage(UIImage(systemName: "circle"), for: .normal)
        checkbox.addTarget(self, action: #selector(checkCheckbox(sender: )), for: .touchUpInside)
        
        cell.accessoryView = checkbox
        
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
    
            perform(#selector(reloadSectionsWithDelay), with: nil, afterDelay: TimeInterval(0.3))
            print(data)
        }
    }
    
    // adds space when overflow in the row happens
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // allows to dragAndDrop selected tableCell
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // swapping two items with drag and drop
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = data[sourceIndexPath.row]
        data[sourceIndexPath.row] = data[destinationIndexPath.row]
        data[destinationIndexPath.row] = temp
        perform(#selector(reloadSectionsWithDelay), with: nil, afterDelay: TimeInterval(0.0))
        print(data)
    }
    
    // MARK: UITableViewDataSource extension #selectors
    @objc func checkCheckbox(sender: UICellAccessoryCheckbox) {
        sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        perform(#selector(removeCheckedRow), with: sender, afterDelay: TimeInterval(0.5))
    }
    
    @objc func removeCheckedRow(buttonInRow: UICellAccessoryCheckbox) {
        tableView?.beginUpdates()
        tableView?.deleteRows(at: [buttonInRow.indexPath!], with: .left)
        data.remove(at: (buttonInRow.indexPath?.row)!)
        tableView?.endUpdates()
        
        perform(#selector(reloadSectionsWithDelay), with: nil, afterDelay: TimeInterval(0.3))
        
        print(data)
    }
    
    @objc func reloadSectionsWithDelay() {
        tableView?.reloadSections(IndexSet(integersIn: 0..<1), with: .none)
    }
}

extension TodayTabViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = data[indexPath.row]
        return [dragItem]
    }
}
