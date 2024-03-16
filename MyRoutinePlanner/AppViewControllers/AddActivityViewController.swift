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
    var withReminder = false
    
    let notificationToggleView: UIView = {
        let configuratedView = UIView()
        configuratedView.backgroundColor = .white
        configuratedView.layer.cornerRadius = 10.0
        
        return configuratedView
    }()
    let timePicker: UIDatePicker = {
        let configuredTimePicker = UIDatePicker()
        configuredTimePicker.datePickerMode = .time
        configuredTimePicker.minimumDate = Date()
//        configuredTimePicker.isHidden = true
        
        return configuredTimePicker
    }()
    let timePickerLabel: UILabel = {
        let configuredLabel = UILabel()
        configuredLabel.text = "Time:"
        
        return configuredLabel
    }()
    let notificationOptionView: UIView = {
        let configuratedView = UIView()
        configuratedView.backgroundColor = .white
        configuratedView.layer.cornerRadius = 10.0
        configuratedView.isHidden = true
        
        return configuratedView
    }()
    let switchControlLabel: UILabel = {
        let configuredLabel = UILabel()
        configuredLabel.text = "Send notification"
        
        return configuredLabel
    }()
    var switchControl: UISwitch = {
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
        title = "Add Activity"
        
        view.backgroundColor = .systemGray6
        
        // navButtons config
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(addNewTask))
    }
    
    
    private func setupSwitchControl() {
        switchControl.addTarget(self, action: #selector(showReminderTimePicker(sender: )), for: .valueChanged)
    }
    
    @objc private func showReminderTimePicker(sender: UISwitch) {
        if sender.isOn {
            self.notificationOptionView.isHidden = false
            self.withReminder = true
        } else {
            self.notificationOptionView.isHidden = true
            self.withReminder = false
        }
    }
    
    private func setupNotificationToggleView() {
        view.addSubview(notificationToggleView)
        notificationToggleView.addSubview(switchControlLabel)
        notificationToggleView.addSubview(switchControl)
    }
    
    private func setupNotificationOptionView() {
        view.addSubview(notificationOptionView)
        notificationOptionView.addSubview(timePickerLabel)
        notificationOptionView.addSubview(timePicker)
    }
    
    private func setupTextView() {
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.delegate = self
        
        // making placeholder
        textView.text = placeholderText
        textView.textColor = .lightGray
        textView.font = .systemFont(ofSize: 21.0)
        textView.backgroundColor = .white
//        textView.backgroundColor = .red
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.cornerRadius = 10.0
        
        view.addSubview(textView)
    }
    
    private func setupUI() {
        setupView()
        setupTextView()
        setupSwitchControl()
        setupNotificationToggleView()
        setupNotificationOptionView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        notificationToggleView.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControlLabel.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePickerLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationOptionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 120.0),
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            notificationToggleView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 40.0),
            notificationToggleView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            notificationToggleView.bottomAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 45.0),
            notificationToggleView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            
            switchControlLabel.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor),
            switchControlLabel.trailingAnchor.constraint(equalTo: self.switchControl.leadingAnchor),
            switchControlLabel.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            switchControlLabel.leadingAnchor.constraint(equalTo: self.notificationToggleView.leadingAnchor, constant: 10.0),
            
            
            switchControl.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 7.5),
            switchControl.trailingAnchor.constraint(equalTo: self.notificationToggleView.trailingAnchor, constant: -10.0),
            switchControl.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            switchControl.leadingAnchor.constraint(equalTo: self.switchControlLabel.trailingAnchor),
            
            
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
            delegate?.saveNewTask(self.textView.text, taskDate: Date(), withReminder: self.withReminder)
            addReminder()
            dismiss(animated: true)
        }
    }
    
    private func addReminder() {
        if self.withReminder == true {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            let stringDate = dateFormatter.string(from: self.timePicker.date)
            
            let hour = Int((stringDate.split(separator: ":").first)!)!
            let minute = Int((stringDate.split(separator: ":").last)!)!
            
            let notificationIdentifier = "\(self.textView.text!)-notification"
            print("hour: \(hour)\nminute: \(minute)")
            print("notificationIdentifier: \(notificationIdentifier)")
            dispatchNotification(identifier: notificationIdentifier, title: "Reminder", body: "Don't forget to do: " + self.textView.text, hour: hour, minute: minute)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AddActivityViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .black
    }
}
