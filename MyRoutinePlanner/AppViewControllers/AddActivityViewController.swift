//
//  AddActivityViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 15.01.24.
//

import UIKit

class AddActivityViewController: UIViewController {
    
    let placeholderText = "I want to..."
    var textView: UITextView! = nil
    var withReminder: Reminder? = nil
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Add Activity"
        configuredTitleLabel.textAlignment = .center
        
        let fontSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(fontSize))
        
        return configuredTitleLabel
    }()
    
    let fontSize = Storage.textSizePreference
    
    let notificationToggleView: UIView = {
        let configuratedView = UIView()
        configuratedView.backgroundColor = .white
        configuratedView.layer.cornerRadius = 10.0
        
        return configuratedView
    }()
    let priorityToggleView: UIView = {
        let configuratedView = UIView()
        configuratedView.backgroundColor = .white
        configuratedView.layer.cornerRadius = 10.0
        
        return configuratedView
    }()
    let timePicker: UIDatePicker = {
        let configuredTimePicker = UIDatePicker()
        configuredTimePicker.datePickerMode = .time
        configuredTimePicker.minimumDate = Date()
        
        return configuredTimePicker
    }()
    let priorityPicker: IntegerPickerView = {
        let configuredIntegerPicker = IntegerPickerView()
        configuredIntegerPicker.numbers = [1, 2, 3, 4]
        configuredIntegerPicker.selectRow(3, inComponent: 0, animated: false)
        configuredIntegerPicker.layer.borderWidth = 0
        
        return configuredIntegerPicker
    }()
    let timePickerLabel: UILabel = {
        let configuredLabel = UILabel()
        configuredLabel.text = "Time:"
        
        let fontSize = Storage.textSizePreference
        configuredLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        
        return configuredLabel
    }()
    let priorityPickerLabel: UILabel = {
        let configuratedLabel = UILabel()
        configuratedLabel.text = "Priority:"
        
        let fontSize = Storage.textSizePreference
        configuratedLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        
        return configuratedLabel
    }()
    let notificationOptionView: UIView = {
        let configuratedView = UIView()
        configuratedView.backgroundColor = .white
        configuratedView.layer.cornerRadius = 10.0
        configuratedView.isHidden = true
        
        return configuratedView
    }()
    let priorityOptionView: UIView = {
        let configuratedView = UIView()
        configuratedView.backgroundColor = .white
        configuratedView.layer.cornerRadius = 10.0
        configuratedView.isHidden = true
        
        return configuratedView
    }()
    let notificationSwitchControlLabel: UILabel = {
        let configuredLabel = UILabel()
        configuredLabel.text = "Send notification"
        
        let fontSize = Storage.textSizePreference
        configuredLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        
        return configuredLabel
    }()
    var notificationSwitchControl: UISwitch = {
        let configuredSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        configuredSwitch.isOn = false
        
        return configuredSwitch
    }()
    let prioritySwitchControlLabel: UILabel = {
        let configuredLabel = UILabel()
        configuredLabel.text = "Set priority"
        
        let fontSize = Storage.textSizePreference
        configuredLabel.font = .systemFont(ofSize: CGFloat(fontSize))
        
        return configuredLabel
    }()
    var prioritySwitchControl: UISwitch = {
        let configuredSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        configuredSwitch.isOn = false
        
        return configuredSwitch
    }()
    
    weak var delegate: AddActivityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupView() {
        //title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
        
        view.backgroundColor = .systemGray6
        
        // navButtons config
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(addNewTask))
    }
    
    
    private func setupSwitchControls() {
        notificationSwitchControl.addTarget(self, action: #selector(showReminderTimePicker(sender: )), for: .valueChanged)
        prioritySwitchControl.addTarget(self, action: #selector(showPriorityIntegerPicker(sender:)), for: .valueChanged)
    }
    
    @objc private func showReminderTimePicker(sender: UISwitch) {
        if sender.isOn {
            self.notificationOptionView.isHidden = false
            self.withReminder = createReminder()
        } else {
            self.notificationOptionView.isHidden = true
            self.withReminder = nil
        }
    }
    
    @objc private func showPriorityIntegerPicker(sender: UISwitch) {
        if sender.isOn {
            self.priorityOptionView.isHidden = false
        } else {
            self.priorityOptionView.isHidden = true
        }
    }
    
    private func createReminder() -> Reminder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let currentDateFormattedInString = dateFormatter.string(from: Date())
        let currentDateFormatted = dateFormatter.date(from: currentDateFormattedInString)
        
        let calendar = Calendar.current
        let selectedDateComponents = calendar.dateComponents([.day, .month, .year], from: currentDateFormatted!)
        
        let selectedDateTimeConponents = calendar.dateComponents([.hour, .minute], from: self.timePicker.date)
        
        let reminderDate = DateComponents(calendar: calendar, year: selectedDateComponents.year, month: selectedDateComponents.month, day: selectedDateComponents.day, hour: selectedDateTimeConponents.hour, minute: selectedDateTimeConponents.minute).date!
        let reminderIdentifier = "\(self.textView.text!)-\(Date().timeIntervalSince1970)-notification"
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let reminder = Reminder(context: context)
        reminder.reminderIdentifier = reminderIdentifier
        reminder.reminderDate = reminderDate
        
        return reminder
    }
    
    private func setupNotificationToggleView() {
        view.addSubview(notificationToggleView)
        notificationToggleView.addSubview(notificationSwitchControlLabel)
        notificationToggleView.addSubview(notificationSwitchControl)
    }
    
    private func setupNotificationOptionView() {
        view.addSubview(notificationOptionView)
        notificationOptionView.addSubview(timePickerLabel)
        notificationOptionView.addSubview(timePicker)
    }
    
    private func setupPriorityToggleView() {
        view.addSubview(priorityToggleView)
        priorityToggleView.addSubview(prioritySwitchControlLabel)
        priorityToggleView.addSubview(prioritySwitchControl)
    }
    
    private func setupPriorityOptionView() {
        view.addSubview(priorityOptionView)
        priorityOptionView.addSubview(priorityPickerLabel)
        priorityOptionView.addSubview(priorityPicker)
    }
    
    private func setupTextView() {
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.delegate = self
        
        // making placeholder
        textView.text = placeholderText
        textView.textColor = .lightGray
        textView.font = .systemFont(ofSize: CGFloat(fontSize))
        textView.backgroundColor = .white

        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.cornerRadius = 10.0
        
        view.addSubview(textView)
    }
    
    private func setupUI() {
        setupView()
        setupTextView()
        setupSwitchControls()
        setupNotificationToggleView()
        setupNotificationOptionView()
        setupPriorityToggleView()
        setupPriorityOptionView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        notificationToggleView.translatesAutoresizingMaskIntoConstraints = false
        notificationSwitchControl.translatesAutoresizingMaskIntoConstraints = false
        notificationSwitchControlLabel.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePickerLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationOptionView.translatesAutoresizingMaskIntoConstraints = false
        
        priorityToggleView.translatesAutoresizingMaskIntoConstraints = false
        prioritySwitchControl.translatesAutoresizingMaskIntoConstraints = false
        prioritySwitchControlLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityPicker.translatesAutoresizingMaskIntoConstraints = false
        priorityPickerLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityOptionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 120.0),
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            notificationToggleView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 40.0),
            notificationToggleView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            notificationToggleView.bottomAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 45.0),
            notificationToggleView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            notificationSwitchControlLabel.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor),
            notificationSwitchControlLabel.trailingAnchor.constraint(equalTo: self.notificationSwitchControl.leadingAnchor),
            notificationSwitchControlLabel.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            notificationSwitchControlLabel.leadingAnchor.constraint(equalTo: self.notificationToggleView.leadingAnchor, constant: 10.0),
            
            
            notificationSwitchControl.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 7.5),
            notificationSwitchControl.trailingAnchor.constraint(equalTo: self.notificationToggleView.trailingAnchor, constant: -10.0),
            notificationSwitchControl.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            notificationSwitchControl.leadingAnchor.constraint(equalTo: self.notificationSwitchControlLabel.trailingAnchor),
            
            
            notificationOptionView.topAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor, constant: 15.0),
            notificationOptionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            notificationOptionView.bottomAnchor.constraint(equalTo: self.notificationOptionView.topAnchor, constant: 45.0),
            notificationOptionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            timePickerLabel.topAnchor.constraint(equalTo: self.notificationOptionView.topAnchor),
            timePickerLabel.trailingAnchor.constraint(equalTo: self.timePicker.leadingAnchor),
            timePickerLabel.bottomAnchor.constraint(equalTo: self.notificationOptionView.bottomAnchor),
            timePickerLabel.leadingAnchor.constraint(equalTo: self.notificationOptionView.leadingAnchor, constant: 10.0),

            
            timePicker.topAnchor.constraint(equalTo: self.notificationOptionView.topAnchor),
            timePicker.trailingAnchor.constraint(equalTo: self.notificationOptionView.trailingAnchor, constant: -10.0),
            timePicker.bottomAnchor.constraint(equalTo: self.notificationOptionView.bottomAnchor),
            timePicker.leadingAnchor.constraint(equalTo: self.timePickerLabel.trailingAnchor),
            
            
            
            priorityToggleView.topAnchor.constraint(equalTo: self.notificationOptionView.bottomAnchor, constant: 15.0),
            priorityToggleView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            priorityToggleView.bottomAnchor.constraint(equalTo: self.priorityToggleView.topAnchor, constant: 45.0),
            priorityToggleView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            prioritySwitchControlLabel.topAnchor.constraint(equalTo: self.priorityToggleView.topAnchor),
            prioritySwitchControlLabel.trailingAnchor.constraint(equalTo: self.priorityToggleView.trailingAnchor, constant: -10.0),
            prioritySwitchControlLabel.bottomAnchor.constraint(equalTo: self.priorityToggleView.bottomAnchor),
            prioritySwitchControlLabel.leadingAnchor.constraint(equalTo: self.priorityToggleView.leadingAnchor, constant: 10.0),
            
            
            prioritySwitchControl.topAnchor.constraint(equalTo: self.priorityToggleView.topAnchor, constant: 7.5),
            prioritySwitchControl.trailingAnchor.constraint(equalTo: self.priorityToggleView.trailingAnchor, constant: -10.0),
            prioritySwitchControl.bottomAnchor.constraint(equalTo: self.priorityToggleView.bottomAnchor, constant: -7.5),
            prioritySwitchControl.widthAnchor.constraint(equalToConstant: 50.0),
            
            
            priorityOptionView.topAnchor.constraint(equalTo: self.priorityToggleView.bottomAnchor, constant: 15.0),
            priorityOptionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            priorityOptionView.bottomAnchor.constraint(equalTo: self.priorityOptionView.topAnchor, constant: 45.0),
            priorityOptionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            priorityPickerLabel.topAnchor.constraint(equalTo: self.priorityOptionView.topAnchor),
            priorityPickerLabel.trailingAnchor.constraint(equalTo: self.priorityPicker.leadingAnchor),
            priorityPickerLabel.bottomAnchor.constraint(equalTo: self.priorityOptionView.bottomAnchor),
            priorityPickerLabel.leadingAnchor.constraint(equalTo: self.priorityOptionView.leadingAnchor, constant: 10.0),

            
            priorityPicker.topAnchor.constraint(equalTo: self.priorityOptionView.topAnchor),
            priorityPicker.trailingAnchor.constraint(equalTo: self.priorityOptionView.trailingAnchor),
            priorityPicker.bottomAnchor.constraint(equalTo: self.priorityOptionView.bottomAnchor),
            priorityPicker.leadingAnchor.constraint(equalTo: self.priorityPickerLabel.trailingAnchor),
            priorityPicker.widthAnchor.constraint(equalToConstant: 100.0),
        ])
    }
    
    // MARK: - #selectors
    @objc func closeView() {
        dismiss(animated: true)
    }
    
    @objc func addNewTask() {
        // TODO: - implement new task addition
        let alertController = UIAlertController(title: "Error", message: "You have to write something first in order to save it!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        if self.textView.text == "" || self.textView.text == nil || self.textView.text == self.placeholderText {
            self.present(alertController, animated: true)
        } else {
            if !self.notificationOptionView.isHidden {
                withReminder = createReminder()
            }
            
            var color: UIColor = .gray
            switch priorityPicker.selectedInteger {
                case 1:
                    color = .red
                case 2:
                    color = .orange
                case 3:
                    color = .blue
                default:
                    color = .gray
            }
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let priority = Priority(context: context)
            priority.priorityLevel = Int64(priorityPicker.selectedInteger!)
            priority.priorityColor = color.toHexString()
            
            let task = MyTask(context: context)
            task.taskTitle = self.textView.text
            task.taskDate = Date()
            task.taskReminderRel = withReminder
            task.taskPriorityRel = priority
            task.taskOrderIndex = Storage.storageData["Today"]?.count != nil ? Int64((Storage.storageData["Today"]?.count)!) : 0
            
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
            
            delegate?.saveNewTask(task)
            
            addReminder()
            dismiss(animated: true)
        }
    }
    
    private func addReminder() {
        if self.withReminder != nil {
            let calendar = Calendar.current
            let reminderDateComponents = calendar.dateComponents([.hour, .minute], from: (withReminder?.reminderDate)!)
            
            dispatchNotification(identifier: (withReminder?.reminderIdentifier)!, title: "Reminder", body: "Don't forget to do: " + self.textView.text, hour: (reminderDateComponents.hour)!, minute: (reminderDateComponents.minute)!)
            
            self.withReminder = nil
        }
    }
    
    func dispatchNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let identifier = identifier
        let title = title
        let body = body
        let hour = hour
        let minute = minute
        let isDaily = false
        
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


extension AddActivityViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .black
    }
}
