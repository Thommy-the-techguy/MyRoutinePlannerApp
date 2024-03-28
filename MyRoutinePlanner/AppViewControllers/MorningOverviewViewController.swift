//
//  MorningOverviewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 27.03.24.
//

import UIKit

class MorningOverviewViewController: UIViewController {
    var isPreffered: Bool! = Bool(Storage.morningNotificationPreference[0])
    var prefferedTime: Date? = {
        let dateFormatter = DateFormatter()
        let storageDate: String = Storage.morningNotificationPreference[1]
        
        if storageDate != "nil" {
            let timeComponentsInString = storageDate.split(separator: " ")[0].split(separator: ":")
            let hour = Int(timeComponentsInString[0])
            let minute = Int(timeComponentsInString[1])
            
            let timeComponents = DateComponents(hour: hour, minute: minute)
            let time = Calendar.current.date(from: timeComponents)
            
            return time
        } else {
            return nil
        }
    }()
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Morning task overview"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()
    
    var tableView: UITableView!
    
    let tableViewData = ["Morning overview", "Send notification at"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        setupView()
        configureTableView()
        
        view.addSubview(self.tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
        ])
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 20
        
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MorningOverviewCell")
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissView))
        
        //title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
    }
    
    @objc private func dismissView() {
        let storagePreference = Bool(Storage.morningNotificationPreference[0])!
        let storageTime = Storage.morningNotificationPreference[1]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .full
        
        let timeToSave = dateFormatter.string(from: prefferedTime!)
        
        if isPreffered != storagePreference || storageTime != timeToSave {
            if isPreffered {
                print("saving time: \(timeToSave)")
                Storage.morningNotificationPreference = [String(isPreffered), timeToSave]
            } else {
                Storage.morningNotificationPreference = [String(isPreffered), "nil"]
            }
            
            DispatchQueue.main.async {
                Storage().saveData()
            }
        }
        
        
        self.dismiss(animated: true)
    }
}

extension MorningOverviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MorningOverviewCell", for: indexPath)
        
        cell.textLabel?.text = tableViewData[indexPath.row]
        
        if indexPath.row == 0 {
            let uiSwitch: UISwitch = {
                let configuredUISwitch = UISwitch()
                configuredUISwitch.setOn(isPreffered, animated: true)
                
                configuredUISwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
                
                return configuredUISwitch
            }()
            
            
            cell.accessoryView = uiSwitch
        } else if indexPath.row == 1 {
            let timePicker: UIDatePicker = {
                let configuredDatePicker = UIDatePicker()
                configuredDatePicker.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
                configuredDatePicker.datePickerMode = .time
                
                var dateComponents = DateComponents(hour: 8, minute: 0)
                var startTime = Calendar.current.date(from: dateComponents)!

                if prefferedTime != nil {
                    startTime = prefferedTime!
                } else {
                    prefferedTime = startTime
                }

                configuredDatePicker.date = prefferedTime!
                
                dateComponents = DateComponents(hour: 4, minute: 0)
                let minDate = Calendar.current.date(from: dateComponents)
                configuredDatePicker.minimumDate = minDate
                
                dateComponents = DateComponents(hour: 11, minute: 59)
                let maxTime = Calendar.current.date(from: dateComponents)
                configuredDatePicker.maximumDate = maxTime
                
                
                
                configuredDatePicker.addTarget(self, action: #selector(timeChanged(sender: )), for: .valueChanged)
                
                
                
                return configuredDatePicker
            }()
            
            cell.accessoryView = timePicker
        }
        
        // change text label text size when settings updated
        let textSize = Storage.textSizePreference > 20.0 ? 20.0 : Storage.textSizePreference
        cell.textLabel?.font = .systemFont(ofSize: CGFloat(textSize))
        
        return cell
    }
    
    @objc private func switchChanged() {
        isPreffered = isPreffered ? false : true
        
        let notificationComponents = Calendar.current.dateComponents([.hour, .minute], from: prefferedTime!)
        
        removeNotificationIfPrefferenceIsOff()
        postNotificationWithTime(hour: notificationComponents.hour!, minute: notificationComponents.minute!)
    }
    
    @objc private func timeChanged(sender: UIDatePicker) {
        prefferedTime = sender.date
        print("prefferedTime: \(prefferedTime)")
        let notificationComponents = Calendar.current.dateComponents([.hour, .minute], from: prefferedTime!)
        
        postNotificationWithTime(hour: notificationComponents.hour!, minute: notificationComponents.minute!)
    }
    
    private func postNotificationWithTime(hour: Int, minute: Int) {
        if isPreffered {
            DispatchQueue.main.async { [unowned self] in
                addMorningNotification(hour: hour, minute: minute)
            }
        }
    }
    
    private func removeNotificationIfPrefferenceIsOff() {
        if !isPreffered {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                let identifiers: [String] = ["morning-notification"]
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        }
    }
    
    private func addMorningNotification(hour: Int, minute: Int) {
        let identifier = "morning-notification"
        let title = "Time to check your tasks"
        let body = "Good mornin'! Don't forget to check your tasks for today!"
        let hour = hour
        let minute = minute
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
}

extension MorningOverviewViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension MorningOverviewViewController: UITableViewDelegate {
    
}
