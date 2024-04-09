//
//  Task.swift
//

import UIKit

// The Task model
struct Task {

    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    var createdDate: Date = Date()

    // An id (Universal Unique Identifier) used to identify a task.
    var id: String = UUID().uuidString
}

// MARK: - Task + UserDefaults
import Foundation

// Assuming Task struct definition is above

// MARK: - Task + UserDefaults
extension Task:Codable {

    // Key used to save tasks in UserDefaults
    private static let tasksKey = "tasks"

    // Save an array of tasks to UserDefaults
    static func save(_ tasks: [Task]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: tasksKey)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }

    // Retrieve an array of saved tasks from UserDefaults
    static func getTasks() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: tasksKey) else { return [] }
        do {
            return try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("Error retrieving tasks: \(error)")
            return []
        }
    }

    // Add a new task or update an existing task
    func save() {
        var tasks = Task.getTasks()
        
        if let index = tasks.firstIndex(where: { $0.id == self.id }) {
            // Task exists, update it
            tasks[index] = self
        } else {
            // New task, add it
            tasks.append(self)
        }
        
        Task.save(tasks)
    }
}
