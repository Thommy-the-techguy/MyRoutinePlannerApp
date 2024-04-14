//
//  Storage.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 1.02.24.
//

import UIKit
import CoreData

final class Storage: NSObject {
    static var storageData: [String:[MyTask]] = [:]
    static var tasks: [MyTask] = []
    
    static var completedTasksData: CodableKeyValuePairs<String, Date> = CodableKeyValuePairs()
    
    static var textSizePreference: Float = 17.0
    static var morningNotificationPreference: [String] = ["false", "nil"] // couldn't find any
    static var eveningNotificationPreference: [String] = ["false", "nil"]
    
    override init() {
        super.init()
        
        // add notification observer for starting app
        NotificationCenter.default.addObserver(self, selector: #selector(readData), name: Notification.Name("AppLoaded"), object: nil)
        
        // add notification observer for terminating app
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: Notification.Name("AppAboutToTerminate"), object: nil)
    }
    
    func fetchTasks() {
        // Создание запроса на получение всех объектов Task
        let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["taskReminderRel", "taskPriorityRel"]
        fetchRequest.returnsObjectsAsFaults = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let todayDateStringWOTime = dateFormatter.string(from: Date())
        let todayDateWOTime = dateFormatter.date(from: todayDateStringWOTime)!
        
        deleteTasksLessThanGivenDateFromDB(todayDateWOTime)
        
        do {
            // Получение результатов запроса
            Storage.tasks = try context.fetch(fetchRequest)
                        
            // Вывод результатов
            for task in Storage.tasks {
                let taskDateStringWOTime = dateFormatter.string(from: task.taskDate!)
                let todayDateStringWOTime = dateFormatter.string(from: Date())
                let tomorrowDateStringWOTime = dateFormatter.string(from: Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!)
                
                if taskDateStringWOTime == todayDateStringWOTime {
                    appendOrAddTaskByKey("Today", task: task)
                } else if taskDateStringWOTime == tomorrowDateStringWOTime {
                    appendOrAddTaskByKey("Tomorrow", task: task)
                } else {
                    appendOrAddTaskByKey(taskDateStringWOTime, task: task)
                }
                
                print("Название задачи: \(task.taskTitle ?? "")\nДата задачи: \(task.taskDate)")
                if let reminder = task.taskReminderRel {
                    print("Reminder: \(String(describing: reminder.reminderDate))\n\(reminder.reminderIdentifier)")
                }
                if let priority = task.taskPriorityRel {
                    print("Priority: \(priority.priorityLevel)\n\(priority.priorityColor)")
                }
                
                print(Storage.tasks)
                // Другие свойства задачи
            }
        } catch {
            print("Ошибка при получении задач из CoreData: \(error.localizedDescription)")
        }
    }
    
    private func appendOrAddTaskByKey(_ key: String, task: MyTask) {
        if let todayTasks = Storage.storageData[key] {
            Storage.storageData[key]?.append(task)
        } else {
            Storage.storageData[key] = [task]
        }
    }
    
    private func deleteTasksLessThanGivenDateFromDB(_ date: Date) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "taskDate < %@", date as CVarArg)
        
        do {
            let tasksToDelete = try context.fetch(fetchRequest)
            
            for task in tasksToDelete {
                context.delete(task)
            }
            
            try context.save()
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
        }
    }
    
    private func saveTaskToDB(taskTitle: String, taskDate: Date) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Создание новой сущности Task
        let taskEntity = NSEntityDescription.entity(forEntityName: "MyTask", in: context)!
        let task = NSManagedObject(entity: taskEntity, insertInto: context)

        // Установка значений для атрибутов сущности Task
        task.setValue(taskTitle, forKey: "taskTitle")
        task.setValue(taskDate, forKey: "taskDate")

        // Сохранение контекста CoreData
        do {
            try context.save()
            print("Данные успешно сохранены в CoreData")
        } catch {
            print("Ошибка при сохранении данных: \(error)")
        }
    }
    
    private func checkIfDayAfterTomorrowIsPresent() -> (isPresent: Bool, tomorrowDateKey: String) {
        let tomorrowDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        
        let tomorrowDateString = dateFormatter.string(from: tomorrowDate)
        
        return (isPresent: Storage.storageData[tomorrowDateString] != nil, tomorrowDateKey: tomorrowDateString)
    }
    
    // process app termination
    @objc func saveData() {
        print("STORAGE SAVE")
        let encoder = JSONEncoder()
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
        readTextSizePreferences(decoder: decoder, keyToUse: "TextSizePreferences")
        readCompletedTasks(decoder: decoder, keyToUse: "CompletedTasks")
        readMorningNotificationPreferences(decoder: decoder, keyToUse: "MorningNotificationPreference")
        readEveningNotificationPreferences(decoder: decoder, keyToUse: "EveningNotificationPreference")
        
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
            var identifiersForRemoval: [String] = []
            
            for tasks in Storage.storageData.values {
                for i in 0..<tasks.count {
                    if let reminder: Reminder = tasks[i].taskReminderRel {
                        if reminder.reminderDate! < Date() {
                            identifiersForRemoval.append(reminder.reminderIdentifier!)
                            
                            do {
                                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                
                                context.delete(reminder)
                                
                                try context.save()
                            } catch {
                                print("Failed to save context: removeInvalidReminders, Line: 265")
                            }
                        }
                    }
                }
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersForRemoval)
            
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
