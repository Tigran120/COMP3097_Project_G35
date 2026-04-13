import Foundation

enum TaskType: String, CaseIterable, Codable {
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

struct TodoTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var taskType: TaskType
    var dueDate: Date
    var isCompleted: Bool
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case id, title, taskType, dueDate, isCompleted, notes
    }

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

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        taskType = try c.decode(TaskType.self, forKey: .taskType)
        dueDate = try c.decode(Date.self, forKey: .dueDate)
        isCompleted = try c.decode(Bool.self, forKey: .isCompleted)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(taskType, forKey: .taskType)
        try c.encode(dueDate, forKey: .dueDate)
        try c.encode(isCompleted, forKey: .isCompleted)
        try c.encodeIfPresent(notes, forKey: .notes)
    }

    static func dueStatus(for dueDate: Date) -> TaskDueStatus {
        let now = Date()
        let oneDay: TimeInterval = 24 * 60 * 60
        if dueDate < now { return .overdue }
        if dueDate.timeIntervalSince(now) <= oneDay { return .dueSoon }
        return .upcoming
    }
}
