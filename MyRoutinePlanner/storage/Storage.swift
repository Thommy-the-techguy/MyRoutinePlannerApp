//
//  Storage.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 1.02.24.
//

import UIKit

final class Storage: NSObject {
    static var inboxData: [String:KeyValuePairsWithFlag<String, Date, Priority>] = [:]
//    static var inboxData: KeyValuePairsWithFlag<String, KeyValuePairsWithFlag<String, Date>> = KeyValuePairsWithFlag()
    
    static var completedTasksData: CodableKeyValuePairs<String, Date> = CodableKeyValuePairs()
    
    static var textSizePreference: Float = 17.0
    
    static var morningNotificationPreference: [String] = ["false", "nil"] // couldn't find any better for now, 1st - isPreffered, 2nd - Date()
//    static var morningNotificationPreference: Bool = false
//    static var morningNotificationTime: Date?
    
    static var eveningNotificationPreference: [String] = ["false", "nil"]
//    static var eveningNotificationPreference: Bool = false
//    static var eveningNotificationTime: Date?
    
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
    
    private func rearrangeTasks() {
        for (key, values) in Storage.inboxData {
            let checkedDate = values.getValue(for: 0)
            
            if !checkIfTaskIsValidByDate(checkedDate) {
                Storage.inboxData[key] = nil
            } else {
                let dateKey = determineDateKey(checkedDate)
                
                if dateKey == "Today" {
                    Storage.inboxData["Today"] = Storage.inboxData[key]
                    Storage.inboxData[key] = nil
                } else if dateKey == "Tomorrow" {
                    Storage.inboxData["Tomorrow"] = Storage.inboxData[key]
                    Storage.inboxData[key] = nil
                }
            }
            
        }
    }
    
    private func determineDateKey(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let dateString = dateFormatter.string(from: date)
        let todayDateString = dateFormatter.string(from: Date())
        let tomorrowDateString = dateFormatter.string(from: (Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!))
        
        switch dateString {
            case todayDateString:
                return "Today"
            case tomorrowDateString:
                return "Tomorrow"
            default:
                return dateString
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
    @objc func saveData() {
        print("STORAGE SAVE")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Storage.inboxData) {
            UserDefaults.standard.set(encoded, forKey: "TodayTasks")
            print(String(data: encoded, encoding: .utf8) ?? "No data aqcuired!")
        } else {
            print("An encoding error has ocurred!")
        }
        
        saveUserData(encoder: encoder, keyToSaveUnder: "TextSizePreferences", dataToSave: Storage.textSizePreference)
        saveUserData(encoder: encoder, keyToSaveUnder: "CompletedTasks", dataToSave: Storage.completedTasksData)
        
        saveUserData(encoder: encoder, keyToSaveUnder: "MorningNotificationPreference", dataToSave: Storage.morningNotificationPreference)
        
        saveUserData(encoder: encoder, keyToSaveUnder: "EveningNotificationPreference", dataToSave: Storage.eveningNotificationPreference)
    }
    
    private func saveUserData(encoder: JSONEncoder, keyToSaveUnder: String, dataToSave: Savable) {
        if let encoded = try? encoder.encode(dataToSave) {
            UserDefaults.standard.set(encoded, forKey: keyToSaveUnder)
            print(String(data: encoded, encoding: .utf8) ?? "No data aqcuired!")
        } else {
            print("An encoding error with text size preferences has ocurred!")
        }
    }
    
    private func readMorningNotificationPreferences(decoder: JSONDecoder, keyToUse: String) {
        if let savedNotificationPreference = UserDefaults.standard.object(forKey: keyToUse) as? Data {
            if let loadedData = try? decoder.decode([String].self, from: savedNotificationPreference) {
                if !loadedData.isEmpty {
                    Storage.morningNotificationPreference = loadedData
                } else {
                    Storage.morningNotificationPreference = ["false", "nil"]
                }
                
                
                
                print("Morning notification preferences had been loaded.\nStorage Data: \(Storage.morningNotificationPreference)")
            }
            
            print()
        }
    }
    
    private func readEveningNotificationPreferences(decoder: JSONDecoder, keyToUse: String) {
        if let savedNotificationPreference = UserDefaults.standard.object(forKey: keyToUse) as? Data {
            if let loadedData = try? decoder.decode([String].self, from: savedNotificationPreference) {
                if !loadedData.isEmpty {
                    Storage.eveningNotificationPreference = loadedData
                } else {
                    Storage.eveningNotificationPreference = ["false", "nil"]
                }
                
                
                
                print("Evening notification preferences had been loaded.\nStorage Data: \(Storage.eveningNotificationPreference)")
            }
        }
    }
    
    private func readTextSizePreferences(decoder: JSONDecoder, keyToUse: String) {
        if let savedTextSizePreference = UserDefaults.standard.object(forKey: keyToUse) as? Data {
            if let loadedData = try? decoder.decode(Float.self, from: savedTextSizePreference) {
                Storage.textSizePreference = loadedData
                
                
                print("Text size preferences had been loaded.\nStorage Data: \(Storage.textSizePreference)")
            }
        }
    }
    
    private func readCompletedTasks(decoder: JSONDecoder, keyToUse: String) {
        if let savedTextSizePreference = UserDefaults.standard.object(forKey: keyToUse) as? Data {
            if let loadedData = try? decoder.decode(CodableKeyValuePairs<String, Date>.self, from: savedTextSizePreference) {
                Storage.completedTasksData = loadedData
                
                
                print("Completed tasks had been loaded.\nStorage Data: \(Storage.textSizePreference)")
            }
        }
    }
    
    // process readingSavedData when scene will load
    @objc func readData() {
        print("STORAGE READ")
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.object(forKey: "TodayTasks") as? Data {
            if let loadedData = try? decoder.decode([String:KeyValuePairsWithFlag<String, Date, Priority>].self, from: savedData) {
                Storage.inboxData = loadedData
                
                
                print("data has been loaded.\nStorage Data: \(Storage.inboxData)")
            }
        }
        
        readTextSizePreferences(decoder: decoder, keyToUse: "TextSizePreferences")
        readCompletedTasks(decoder: decoder, keyToUse: "CompletedTasks")
        readMorningNotificationPreferences(decoder: decoder, keyToUse: "MorningNotificationPreference")
        readEveningNotificationPreferences(decoder: decoder, keyToUse: "EveningNotificationPreference")
        
        print("REMOVING INVALID TASKS")
//        removeInvalidTasks()
        rearrangeTasks()
        removeInvalidReminders()
        
        print("CLEANING COMPLETED TASKS")
        cleanUpCompletedTasks()
        
        DispatchQueue.main.async { [unowned self] in
            saveData()
        }
    }
    
    // if completed tasks array has length > 100 performs cleanup on boot of an app
    private func cleanUpCompletedTasks() {
        DispatchQueue.main.async {
            if Storage.completedTasksData.count > 100 {
                for _ in 0...80 {
                    Storage.completedTasksData.removeKeyAndValue(for: 0)
                }
            }
        }
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
                    if value.getReminder(for: i) != nil {
                        let identifier = (value.getReminder(for: i)?.reminderIdentifier)!
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
                if !notificationRequests.contains(where: { (request) in
                    return request.identifier == identifiers[i]
                } ) {
                    identifiersForRemoval.append(identifiers[i])
                    messagesForRemoval.append(messages[i])
                    datesForRemoval.append(dates[i])
                }
            }
            
            print("\n\nSTORAGE:\(Storage.inboxData)")
            print("\n\nidentifiersForRemoval:\(identifiersForRemoval)")
            
            for (key, value) in Storage.inboxData {
                for i in 0..<value.count {
                    let (text, date, reminder, priority) = value.getKeyAndValue(for: i)
                    if messagesForRemoval.contains(text) && datesForRemoval.contains(date) && (reminder != nil) {
                        Storage.inboxData[key]?.setKeyAndValue(for: i, key: text, value: date, withReminder: nil, priority: priority)
                        print("\n\n\nREMOVING REMINDER \(i) \(key) \(date)\n\n\n")
                    }
                }
            }
            
            print("\n\n\n\n\nidentifiers:\(notificationRequests.debugDescription)\n\n\n\n\n")
            
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
