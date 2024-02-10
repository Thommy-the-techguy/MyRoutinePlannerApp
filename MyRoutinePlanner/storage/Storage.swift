//
//  Storage.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 1.02.24.
//

import UIKit

final class Storage: NSObject {
    static var inboxData: [String:CustomKeyValuePairs<String, Date>] = [:]
    
    override init() {
        super.init()
        
        // add notification observer for starting app
        NotificationCenter.default.addObserver(self, selector: #selector(readData), name: Notification.Name("AppLoaded"), object: nil)
        
        // add notification observer for terminating app
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: Notification.Name("AppAboutToTerminate"), object: nil)
    }
    
    private func checkIfTaskIsValidByDate(_ date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        
        let dateInString = dateFormatter.string(from: date)
        let todayDateInString = dateFormatter.string(from: Date())
        
        let dateWithoutTime = dateFormatter.date(from: dateInString)!
        let todayDateWithoutTime = dateFormatter.date(from: todayDateInString)!
        
        if dateWithoutTime < todayDateWithoutTime {
            return false
        }
        
        return true
    }
    
    private func removeInvalidTasks() {
        let todayTasks = Storage.inboxData["Today"]
        let tomorrowTasks = Storage.inboxData["Tomorrow"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let dayAfterTomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!
        let dayAfterTomorrowInString = dateFormatter.string(from: dayAfterTomorrow)
        
        let dayAfterTomorrowTasks = Storage.inboxData[dayAfterTomorrowInString]
        
        if let todayTasks {
            if let tomorrowTasks {
                if checkIfTaskIsValidByDate(todayTasks.getValue(for: 0)) == false {
                    moveTommorowToToday()
                    return
                }
            } else {
                if checkIfTaskIsValidByDate(todayTasks.getValue(for: 0)) == false {
                    removeTodayTasks()
                    return
                }
            }
            
        } else if let tomorrowTasks {
            let todayDateInString = dateFormatter.string(from: Date())
            let todayDateWithoutTime = dateFormatter.date(from: todayDateInString)
            
            let tomorrowDateInString = dateFormatter.string(from: tomorrowTasks.getValue(for: 0))
            let tomorrowDateWithoutTime = dateFormatter.date(from: tomorrowDateInString)
            
            
            if todayTasks == nil && tomorrowDateWithoutTime == todayDateWithoutTime {
                moveTommorowToToday()
                return
            }
        } else if let dayAfterTomorrowTasks {
            moveTommorowToToday()
            return
        }
    }
    
    private func removeTodayTasks() {
        Storage.inboxData["Today"] = nil
    }
    
    private func moveTommorowToToday() {
        Storage.inboxData["Today"] = Storage.inboxData["Tomorrow"]
        
        let (dayAfterTomorrowIsPresent, tomorrowDateKey) = checkIfDayAfterTomorrowIsPresent()
        if dayAfterTomorrowIsPresent {
            Storage.inboxData["Tomorrow"] = Storage.inboxData[tomorrowDateKey]
            Storage.inboxData[tomorrowDateKey] = nil
        } else {
            Storage.inboxData["Tomorrow"] = nil
        }
    }
    
    private func checkIfDayAfterTomorrowIsPresent() -> (isPresent: Bool, tomorrowDateKey: String) {
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        
        let tomorrowDateString = dateFormatter.string(from: tomorrowDate)
        
        return (isPresent: Storage.inboxData[tomorrowDateString] != nil, tomorrowDateKey: tomorrowDateString)
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
                
                
                print("data has been loaded.\nStorage Data: \(Storage.inboxData)")
            }
        }
        
        print("REMOVING INVALID TASKS")
        removeInvalidTasks()
    }
}
