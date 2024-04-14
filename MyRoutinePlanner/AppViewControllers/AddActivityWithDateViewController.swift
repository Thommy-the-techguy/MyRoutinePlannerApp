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
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Add Activity"
        configuredTitleLabel.textAlignment = .center
        
        let fontSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(fontSize))
        
        return configuredTitleLabel
    }()
    
    let fontSize = Storage.textSizePreference
    
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
    
    var withReminder: Reminder? = nil
    
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
    
    init(initialTextViewText: String, initialTitle: String, initialFlag: Reminder?) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.withReminder = initialFlag
        // TODO: when moving to another date remain previous time
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String, initialDate: Date, initialFlag: Reminder?) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.datePicker.date = initialDate
        self.withReminder = initialFlag
        // TODO: when moving to another date remain previous time
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String, initialFlag: Reminder?, initialPriority: Priority) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.withReminder = initialFlag
        self.priorityPicker.selectRow(Int(initialPriority.priorityLevel) - 1, inComponent: 0, animated: false)
        // TODO: when moving to another date remain previous time
        super.init(nibName: nil, bundle: nil)
    }
    
    init(initialTextViewText: String, initialTitle: String, initialDate: Date, initialFlag: Reminder?, initialPriority: Priority) {
        self.initialText = initialTextViewText
        self.initialTitle = initialTitle
        self.datePicker.date = initialDate
        self.withReminder = initialFlag
        self.priorityPicker.selectRow(Int(initialPriority.priorityLevel) - 1, inComponent: 0, animated: false)
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
    
    private func setupSwitchControls() {
        if withReminder != nil {
            notificationSwitchControl.isOn = true
            self.notificationOptionView.isHidden = false
        }
        
        if priorityPicker.selectedInteger != 4 {
            prioritySwitchControl.isOn = true
            priorityOptionView.isHidden = false
        }
        
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
        
        let currentDateFormattedInString = dateFormatter.string(from: self.datePicker.date)
        let currentDateFormatted = dateFormatter.date(from: currentDateFormattedInString)
        
        let calendar = Calendar.current
        let selectedDateComponents = calendar.dateComponents([.day, .month, .year], from: currentDateFormatted!)
        
        let selectedDateTimeConponents = calendar.dateComponents([.hour, .minute], from: self.timePicker.date)
        
        let reminderDate = DateComponents(calendar: calendar, year: selectedDateComponents.year, month: selectedDateComponents.month, day: selectedDateComponents.day, hour: selectedDateTimeConponents.hour, minute: selectedDateTimeConponents.minute).date!
        let reminderIdentifier = "\(self.textView.text!)-\(Date().timeIntervalSince1970)-notification"
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.reminderDate = reminderDate
        reminder.reminderIdentifier = reminderIdentifier
        
        return reminder
    }
    
    private func setupNotificationToggleView() {
        notificationToggleView.addSubview(notificationSwitchControlLabel)
        notificationToggleView.addSubview(notificationSwitchControl)
    }
    
    private func setupNotificationOptionView() {
        notificationOptionView.addSubview(timePickerLabel)
        notificationOptionView.addSubview(timePicker)
    }
    
    private func setupPriorityToggleView() {
        priorityToggleView.addSubview(prioritySwitchControlLabel)
        priorityToggleView.addSubview(prioritySwitchControl)
    }
    
    private func setupPriorityOptionView() {
        priorityOptionView.addSubview(priorityPickerLabel)
        priorityOptionView.addSubview(priorityPicker)
    }
    
    private func configureTextView() {
        textView = UITextView()
        
        textView.text = (self.initialText == nil ? placeholderText : self.initialText)
        textView.textColor = (self.initialText == nil ? .lightGray : .black)
        textView.font = .systemFont(ofSize: CGFloat(fontSize))
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
        setMinimumDateForTimePicker()
        setCurrentTimeForTimePicker()
        
        self.datePicker.addTarget(self, action: #selector(onDateValueChanged), for: .valueChanged)
    }
    
    private func setCurrentTimeForTimePicker() {
        print(withReminder != nil)
        print(withReminder?.reminderDate)
        timePicker.date = (withReminder != nil) ? (withReminder?.reminderDate)! : Date()
    }
    
    private func setMinimumDateForTimePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        
        let currentDateFormattedInString = dateFormatter.string(from: self.datePicker.date)
        let todayDateFormattedInString = dateFormatter.string(from: Date())
        
        let currentDate = dateFormatter.date(from: currentDateFormattedInString)
        let todayDate = dateFormatter.date(from: todayDateFormattedInString)
        
        if todayDate == currentDate {
            self.timePicker.minimumDate = Date()
        } else {
            self.timePicker.minimumDate = nil
        }
    }
    
    @objc private func onDateValueChanged() {
        setMinimumDateForTimePicker()
    }
    
    private func setupUI() {
        setupView()
        configureTextView()
        configureContentView()
        configureScrollView()
        setupSwitchControls()
        setupNotificationToggleView()
        setupNotificationOptionView()
        setupPriorityToggleView()
        setupPriorityOptionView()
        setupTimePicker()

        
        contentView.addSubview(datePicker)
        contentView.addSubview(textView)
        contentView.addSubview(notificationToggleView)
        contentView.addSubview(notificationOptionView)
        contentView.addSubview(priorityToggleView)
        contentView.addSubview(priorityOptionView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
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
            
            
            notificationSwitchControlLabel.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor),
            notificationSwitchControlLabel.trailingAnchor.constraint(equalTo: self.notificationSwitchControl.leadingAnchor),
            notificationSwitchControlLabel.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            notificationSwitchControlLabel.leadingAnchor.constraint(equalTo: self.notificationToggleView.leadingAnchor, constant: 10.0),
            
            
            notificationSwitchControl.topAnchor.constraint(equalTo: self.notificationToggleView.topAnchor, constant: 7.5),
            notificationSwitchControl.trailingAnchor.constraint(equalTo: self.notificationToggleView.trailingAnchor, constant: -10.0),
            notificationSwitchControl.bottomAnchor.constraint(equalTo: self.notificationToggleView.bottomAnchor),
            notificationSwitchControl.leadingAnchor.constraint(equalTo: self.notificationSwitchControlLabel.trailingAnchor),
            
            
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
            
            
            
            
            priorityToggleView.topAnchor.constraint(equalTo: self.notificationOptionView.bottomAnchor, constant: 15.0),
            priorityToggleView.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
            priorityToggleView.bottomAnchor.constraint(equalTo: self.priorityToggleView.topAnchor, constant: 45.0),
            priorityToggleView.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
            
            
            prioritySwitchControlLabel.topAnchor.constraint(equalTo: self.priorityToggleView.topAnchor),
            prioritySwitchControlLabel.trailingAnchor.constraint(equalTo: self.priorityToggleView.trailingAnchor, constant: -10.0),
            prioritySwitchControlLabel.bottomAnchor.constraint(equalTo: self.priorityToggleView.bottomAnchor),
            prioritySwitchControlLabel.leadingAnchor.constraint(equalTo: self.priorityToggleView.leadingAnchor, constant: 10.0),
            
            
            prioritySwitchControl.topAnchor.constraint(equalTo: self.priorityToggleView.topAnchor, constant: 7.5),
            prioritySwitchControl.trailingAnchor.constraint(equalTo: self.priorityToggleView.trailingAnchor, constant: -10.0),
            prioritySwitchControl.bottomAnchor.constraint(equalTo: self.priorityToggleView.bottomAnchor, constant: -7.5),
            prioritySwitchControl.widthAnchor.constraint(equalToConstant: 50.0),
            
            
            priorityOptionView.topAnchor.constraint(equalTo: self.priorityToggleView.bottomAnchor, constant: 15.0),
            priorityOptionView.trailingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
            priorityOptionView.bottomAnchor.constraint(equalTo: self.priorityOptionView.topAnchor, constant: 45.0),
            priorityOptionView.leadingAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
            
            
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
            task.taskDate = datePicker.date
            task.taskReminderRel = withReminder
            task.taskPriorityRel = priority
            
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
            let reminderDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: (withReminder?.reminderDate)!)
            
            dispatchNotification(identifier: (withReminder?.reminderIdentifier)!, title: "Reminder", body: "Don't forget to do: " + self.textView.text, day: (reminderDateComponents.day)!, month: (reminderDateComponents.month)!, year: (reminderDateComponents.year)!, hour: (reminderDateComponents.hour)!, minute: (reminderDateComponents.minute)!)
            
            self.withReminder = nil
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
        dateComponents.year = year
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
            if let reminder = self.withReminder {
                let reminderIdentifier = reminder.reminderIdentifier
                self.withReminder = createReminder()
                self.withReminder?.reminderIdentifier = reminderIdentifier
            }
            
//            let priority = Priority(priorityLevel: priorityPicker.selectedInteger!)
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
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
            
            let priority = Priority(context: context)
            priority.priorityLevel = Int64(priorityPicker.selectedInteger!)
            priority.priorityColor = color.toHexString()
            print("SELECTED INTEGER: \(priorityPicker.selectedInteger)")
            
            let task = MyTask(context: context)
            task.taskTitle = self.textView.text
            task.taskDate = datePicker.date
            task.taskReminderRel = withReminder
            task.taskPriorityRel = priority
            
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
            
            delegate?.editSelectedTask(task)
            
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
