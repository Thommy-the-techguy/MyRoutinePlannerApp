//
//  Storage.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 1.02.24.
//

import UIKit

class Storage: NSObject {
    static var inboxData: [String:CustomKeyValuePairs<String, Date>] = [:]
    
    override init() {
        super.init()
        
        // add notification observer for starting app
        NotificationCenter.default.addObserver(self, selector: #selector(readData), name: Notification.Name("AppLoaded"), object: nil)
        
        // add notification observer for terminating app
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: Notification.Name("AppAboutToTerminate"), object: nil)
    }
    
    // process app termination
    @objc private func saveData() {
        print("STORAGE SAVE")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Storage.inboxData) {
            UserDefaults.standard.set(encoded, forKey: "TodayTasks")
            print(String(data: encoded, encoding: .utf8) ?? "No data aqcuired!")
        } else {
            print("An encoding error has ocurred!")
        }
    }
    
    // process readingSavedData when scene will load
    @objc func readData() {
        print("STORAGE READ")
        if let savedData = UserDefaults.standard.object(forKey: "TodayTasks") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode([String:CustomKeyValuePairs<String, Date>].self, from: savedData) {
                Storage.inboxData = loadedData
                
//                self.tableView.reloadData()
                
                print("data has been loaded.\nStorage Data: \(Storage.inboxData)")
            }
        }
    }
}
