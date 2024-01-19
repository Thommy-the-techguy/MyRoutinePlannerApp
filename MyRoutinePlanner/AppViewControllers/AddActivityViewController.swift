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
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 180.0),
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
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
            delegate?.saveNewTask(self.textView.text, taskDate: Date())
        }
        
        dismiss(animated: true)
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
