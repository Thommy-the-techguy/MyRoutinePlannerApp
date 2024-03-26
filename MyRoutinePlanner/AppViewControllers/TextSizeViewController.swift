//
//  TextSizeViewController.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 15.03.24.
//

import UIKit

class TextSizeViewController: UIViewController {
    let defaultTextSize = 17.0
//    var currentTextSize: Double = {
//        return Storage.textSizePreference
//    }()
    
    let textSizeLabel: UILabel = {
        let configuredLabel = UILabel()
        configuredLabel.text = "App's text size will change to your preferred reading size below."
        configuredLabel.textAlignment = .center
        configuredLabel.numberOfLines = 0
        configuredLabel.font = .systemFont(ofSize: CGFloat(Storage.textSizePreference))
        
        return configuredLabel
    }()
    
    let viewControllerTitleLabel: UILabel = {
        let configuredTitleLabel = UILabel()
        configuredTitleLabel.text = "Text Size"
        configuredTitleLabel.textAlignment = .center
        
        let textSize = Storage.textSizePreference < 17.0 ? 17.0 : Storage.textSizePreference
        configuredTitleLabel.font = .boldSystemFont(ofSize: CGFloat(textSize))
        
        return configuredTitleLabel
    }()
    
    let textSizeSlider: UISlider = {
        let configuredSlider = UISlider()
        configuredSlider.minimumValue = 10
        configuredSlider.maximumValue = 24
        configuredSlider.backgroundColor = .white
        configuredSlider.minimumTrackTintColor = .gray
        configuredSlider.maximumTrackTintColor = .gray
        configuredSlider.value = Storage.textSizePreference
        configuredSlider.addTarget(self, action: #selector(changeTextSize(sender: )), for: .valueChanged)
        
        let imageSmall = UIImage(systemName: "textformat.size.smaller", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25.0))?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let imageBig = UIImage(systemName: "textformat.size.smaller", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35.0))?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        configuredSlider.minimumValueImage = imageSmall
        configuredSlider.maximumValueImage = imageBig
        
        return configuredSlider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    private func setupUI() {
        
        setupView()
        
        view.addSubview(textSizeLabel)
        view.addSubview(textSizeSlider)
        
        self.textSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textSizeLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20.0),
            textSizeLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            textSizeLabel.bottomAnchor.constraint(equalTo: textSizeLabel.topAnchor, constant: 100.0),
            textSizeLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            
            
            textSizeSlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15.0),
            textSizeSlider.topAnchor.constraint(equalTo: textSizeSlider.bottomAnchor, constant: -70.0),
            textSizeSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            textSizeSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ])
        
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewAndSaveChangesIfPresent))
        
//        self.title = "Text Size"
        //title
        navigationController?.navigationBar.topItem?.titleView = viewControllerTitleLabel
    }
    
    
    @objc private func dismissViewAndSaveChangesIfPresent() {
        if Storage.textSizePreference != self.textSizeSlider.value {
            Storage.textSizePreference = self.textSizeSlider.value
            DispatchQueue.main.async {
                Storage().saveData()
            }
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name("ReloadData")))
        self.dismiss(animated: true)
    }
    
    @objc private func changeTextSize(sender: UISlider) {
        let newSize = sender.value
        textSizeLabel.font = .systemFont(ofSize: CGFloat(newSize))
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
