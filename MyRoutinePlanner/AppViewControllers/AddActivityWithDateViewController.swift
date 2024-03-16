//
//  AddActivityWithDateViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 21.01.24.
//

import UIKit

class AddActivityWithDateViewController: UIViewController {
    
    let placeholderText = "I want to..."
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    
    var datePicker: UIDatePicker = {
        let configuredDatePicker = UIDatePicker()
        configuredDatePicker.minimumDate = Date()
        configuredDatePicker.date = Date()
        configuredDatePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            configuredDatePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
    
        return configuredDatePicker
    }()
    
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
    
    var scrollView: UIScrollView!
    
    var contentView: UIView!
    
    var textView: UITextView!
    
    var initialText: String?
    
    var initialTitle: String?
    
    weak var delegate: AddActivityDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String) {
        self.initialText = initialTextViewText
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String, initialDate: Date) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.datePicker.date = initialDate
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String, initialFlag: Bool) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.withReminder = initialFlag
        // TODO: when moving to another date remain previous time
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String, initialDate: Date, initialFlag: Bool) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.datePicker.date = initialDate
        self.withReminder = initialFlag
        // TODO: when moving to another date remain previous time
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
               
        setupUI()
    }
    

    private func setupView() {
        view.backgroundColor = .systemGray6
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeView))
        
        if initialTitle == "Edit Task" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTask))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addNewTask))
        }
        
        
        title = (self.initialTitle == nil ? "Add Activity" : self.initialTitle)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupSwitchControl() {
        if withReminder {
            switchControl.isOn = true
            self.notificationOptionView.isHidden = false
        }
        
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
//        view.addSubview(notificationToggleView)
        notificationToggleView.addSubview(switchControlLabel)
        notificationToggleView.addSubview(switchControl)
    }
    
    private func setupNotificationOptionView() {
//        view.addSubview(notificationOptionView)
        notificationOptionView.addSubview(timePickerLabel)
        notificationOptionView.addSubview(timePicker)
    }
    
    private func configureTextView() {
        textView = UITextView()
        
        textView.text = (self.initialText == nil ? placeholderText : self.initialText)
        textView.textColor = (self.initialText == nil ? .lightGray : .black)
        textView.font = .systemFont(ofSize: 21)
        textView.layer.cornerRadius = 10.0
        textView.delegate = self
    }
    
    private func configureScrollView() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGray6
        scrollView.isScrollEnabled = true
        scrollView.bounces = true
    }
    
    private func configureContentView() {
        contentView = UIView()
    }
    
    private func setupTimePicker() {
        self.datePicker.addTarget(self, action: #selector(onDateValueChanged), for: .valueChanged)
    }
    
    @objc private func onDateValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        
        let stringToday = dateFormatter.string(from: Date())
        let stringChosen = dateFormatter.string(from: self.datePicker.date)
        
        if stringToday == stringChosen {
            self.timePicker.minimumDate = Date()
        } else {
            self.timePicker.minimumDate = nil
        }
    }
    
    private func setupUI() {
        setupView()
        configureTextView()
        configureContentView()
        configureScrollView()
        setupSwitchControl()
        setupNotificationToggleView()
        setupNotificationOptionView()
        setupTimePicker()

        
        contentView.addSubview(datePicker)
        contentView.addSubview(textView)
        contentView.addSubview(notificationToggleView)
        contentView.addSubview(notificationOptionView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        notificationToggleView.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControlLabel.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePickerLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationOptionView.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            
            
            contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor),
            
            
            datePicker.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            datePicker.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: self.textView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
            
            
            textView.topAnchor.constraint(equalTo: self.datePicker.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: self.datePicker.bottomAnchor, constant: 70.0),
            textView.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
            
            
            notificationToggleView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 40.0),
            notificationToggleView.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
            notificationToggleView.bottomAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 45.0),
            notificationToggleView.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
            
            
            switchControlLabel.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor),
            switchControlLabel.trailingAnchor.constraint(equalTo: self.switchControl.leadingAnchor),
            switchControlLabel.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            switchControlLabel.leadingAnchor.constraint(equalTo: self.notificationToggleView.leadingAnchor, constant: 10.0),
            
            
            switchControl.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 7.5),
            switchControl.trailingAnchor.constraint(equalTo: self.notificationToggleView.trailingAnchor, constant: -10.0),
            switchControl.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            switchControl.leadingAnchor.constraint(equalTo: self.switchControlLabel.trailingAnchor),
            
            
            notificationOptionView.topAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor, constant: 15.0),
            notificationOptionView.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
            notificationOptionView.bottomAnchor.constraint(equalTo: self.notificationOptionView.topAnchor, constant: 45.0),
            notificationOptionView.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
            
            
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
    
    
    // TODO: maybe change to protocol
    @objc private func closeView() {
        dismiss(animated: true)
    }
    
    // add new task with date
    @objc private func addNewTask() {
        // TODO: add new task logic
        let alertController = UIAlertController(title: "Error", message: "You have to write something first in order to save it!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        if self.textView.text == "" || self.textView.text == nil || self.textView.text == self.placeholderText {
            self.present(alertController, animated: true)
        } else {
            delegate?.saveNewTask(self.textView.text, taskDate: datePicker.date, withReminder: withReminder)
            addReminder()
            dismiss(animated: true)
        }
    }
    
    private func addReminder() {
        if self.withReminder == true {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            let stringDate = dateFormatter.string(from: self.datePicker.date)
            let stringTime = dateFormatter.string(from: self.timePicker.date)
            
            print("stringDate: \(stringDate)")
            
            let dateComponents: [Substring] = (stringDate.split(separator: ",").first?.split(separator: "."))!
            
            let day: Int = Int(dateComponents[0])!
            let month: Int = Int(dateComponents[1])!
            let year: Int = Int(dateComponents[2])!
            
            let timeComponents: [Substring] = (stringTime.split(separator: ",").last?.split(separator: ":"))!
            
            let hour = Int(timeComponents[0].trimmingCharacters(in: .whitespaces))!
            let minute = Int(timeComponents[1])!

            print("date: \(day)/\(month)/\(year), \(hour):\(minute)")
            
            let reminderIdentifier = "\(self.textView.text!)-notification"
            print(reminderIdentifier)
            
            dispatchNotification(identifier: reminderIdentifier, title: "Reminder", body: "Don't forget to do: " + self.textView.text, day: day, month: month, year: year, hour: hour, minute: minute)
            
            self.withReminder = false
        }
    }
    
    func dispatchNotification(identifier: String, title: String, body: String, day: Int, month: Int, year: Int, hour: Int, minute: Int) {
        let identifier = identifier
        let title = title
        let body = body
        let day = day
        let month = month
        let year = year
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
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year + 2000
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
    
    @objc private func editTask() {
        // TODO: add new task logic
        let alertController = UIAlertController(title: "Error", message: "You have to write something first in order to save it!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        if self.textView.text == "" || self.textView.text == nil || self.textView.text == self.placeholderText {
            self.present(alertController, animated: true)
        } else {
            delegate?.editSelectedTask(taskText: self.textView.text, taskDate: datePicker.date, withReminder: withReminder)
            addReminder()
            dismiss(animated: true)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
          // if keyboard size is not available for some reason, dont do anything
          return
        }

        scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height), animated: true)
      }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



extension AddActivityWithDateViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
        
        NotificationCenter.default.post(Notification(name: UIResponder.keyboardWillShowNotification))
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        NotificationCenter.default.post(Notification(name: UIResponder.keyboardWillHideNotification))
        
        if textView.text.isEmpty {
            textView.text = self.placeholderText
            textView.textColor = .lightGray
        }
        
        return true
    }
}
