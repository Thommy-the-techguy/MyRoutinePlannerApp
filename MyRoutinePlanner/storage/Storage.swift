//
//  Storage.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 1.02.24.
//

import UIKit

final class Storage: NSObject {
    static var inboxData: [String:KeyValuePairsWithFlag<String, Date>] = [:]
    
    static var textSizePreference: Float = 17.0
    
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
            if tomorrowTasks != nil {
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
        
        saveTextSizePreferences(encoder: encoder, keyToSaveUnder: "TextSizePreferences")
    }
    
    private func saveTextSizePreferences(encoder: JSONEncoder, keyToSaveUnder: String) {
        if let encoded = try? encoder.encode(Storage.textSizePreference) {
            UserDefaults.standard.set(encoded, forKey: keyToSaveUnder)
            print(String(data: encoded, encoding: .utf8) ?? "No text size data aqcuired!")
        } else {
            print("An encoding error with text size preferences has ocurred!")
        }
    }
    
    private func readTextSizePreferences(decoder: JSONDecoder, keyToUse: String) {
        if let savedTextSizePreference = UserDefaults.standard.object(forKey: keyToUse) as? Data {
            if let loadedData = try? decoder.decode(Float.self, from: savedTextSizePreference) {
                Storage.textSizePreference = loadedData
                
                
                print("Text size preferences have been loaded.\nStorage Data: \(Storage.textSizePreference)")
            }
        }
    }
    
    // process readingSavedData when scene will load
    @objc func readData() {
        print("STORAGE READ")
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.object(forKey: "TodayTasks") as? Data {
            if let loadedData = try? decoder.decode([String:KeyValuePairsWithFlag<String, Date>].self, from: savedData) {
                Storage.inboxData = loadedData
                
                
                print("data has been loaded.\nStorage Data: \(Storage.inboxData)")
            }
        }
        
        readTextSizePreferences(decoder: decoder, keyToUse: "TextSizePreferences")
        
        print("REMOVING INVALID TASKS")
        removeInvalidTasks()
        removeInvalidReminders()
    }
    
    
    
    func removeInvalidReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [unowned self] (notificationRequests) in
            var identifiers: [String] = []
            var dates: [Date] = []
            var messages: [String] = []
            
            print("\n\nidentifiers:\(identifiers)\ndates:\(dates)\nmessages\(messages)\n\n\n")
            
            //              customKeyValuePairs
            //                       ^
            //                       |
            for value in Storage.inboxData.values {
                for i in 0..<value.count {
                    if value.getFlag(for: i) {
                        let identifier = "\(value.getKey(for: i))-notification" // message + -notification
                        identifiers.append(identifier)
                        dates.append(value.getValue(for: i))
                        messages.append(value.getKey(for: i))
                    }
                }
            }
            
            print("\n\nidentifiers:\(identifiers)\ndates:\(dates)\nmessages\(messages)\n\n\n")
            
            var identifiersForRemoval: [String] = []
            var messagesForRemoval: [String] = []
            var datesForRemoval: [Date] = []
            for i in 0..<identifiers.count {
                print("date: \(dates[i])\ncurrentDate: \(Date())")
                if !(notificationRequests.contains(where: { (request) in
                    return request.identifier == identifiers[i]
                } )) {
                    identifiersForRemoval.append(identifiers[i])
                    messagesForRemoval.append(messages[i])
                    datesForRemoval.append(dates[i])
                }
            }
            
            print("\n\nidentifiersForRemoval:\(identifiersForRemoval)")
            
            for (key, value) in Storage.inboxData {
                for i in 0..<value.count {
                    let (text, date, flag) = value.getKeyAndValue(for: i)
                    if messagesForRemoval.contains(text) && datesForRemoval.contains(date) && flag == true {
                        Storage.inboxData[key]?.setKeyAndValue(for: i, key: text, value: date, withReminder: false)
                        print("\n\n\nREMOVING REMINDER \(i) \(key) \(date)\n\n\n")
                    }
                }
            }
            
            if !identifiersForRemoval.isEmpty {
                postReloadDataNotification()
                print("notification posted")
            }
        }
    }
    
    func postReloadDataNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("ReloadData")))
    }
}
