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
    
    weak var delegate: AddActivityDelegate?
    

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addNewTask))
        
        
        title = "Add Activity"
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func configureTextView() {
        textView = UITextView()
        
        textView.text = placeholderText
        textView.textColor = .lightGray
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
