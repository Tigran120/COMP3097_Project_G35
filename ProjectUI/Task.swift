import Foundation

enum TaskType: String, CaseIterable {
    case personal = "Personal"
    case work = "Work"
    case shopping = "Shopping"
    case other = "Other"
}

enum TaskDueStatus {
    case overdue
    case dueSoon
    case upcoming
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var taskType: TaskType
    var dueDate: Date
    var isCompleted: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        title: String,
        taskType: TaskType = .personal,
        dueDate: Date,
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.taskType = taskType
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.notes = notes
    }

    static func dueStatus(for dueDate: Date) -> TaskDueStatus {
        let now = Date()
        let oneDay: TimeInterval = 24 * 60 * 60
        if dueDate < now { return .overdue }
        if dueDate.timeIntervalSince(now) <= oneDay { return .dueSoon }
        return .upcoming
    }
}
