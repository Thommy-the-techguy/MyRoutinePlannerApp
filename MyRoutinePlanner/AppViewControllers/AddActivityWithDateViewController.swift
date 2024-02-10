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
    
    private func setupUI() {
        setupView()
        configureTextView()
        configureContentView()
        configureScrollView()

        
        contentView.addSubview(datePicker)
        contentView.addSubview(textView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        

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
            delegate?.saveNewTask(self.textView.text, taskDate: datePicker.date)
            dismiss(animated: true)
        }
    }
    
    @objc private func editTask() {
        // TODO: add new task logic
        let alertController = UIAlertController(title: "Error", message: "You have to write something first in order to save it!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        if self.textView.text == "" || self.textView.text == nil || self.textView.text == self.placeholderText {
            self.present(alertController, animated: true)
        } else {
            delegate?.editSelectedTask(taskText: self.textView.text, taskDate: datePicker.date)
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
