import Foundation

final class TaskStorage {

    static let shared = TaskStorage()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var tasksURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("tasks.json")
    }

    private init() {}

    func loadTasks() -> [Task] {
        guard let url = tasksURL, fileManager.fileExists(atPath: url.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([Task].self, from: data)
        } catch {
            return []
        }
    }

    func saveTasks(_ tasks: [Task]) {
        guard let url = tasksURL else { return }
        do {
            let data = try encoder.encode(tasks)
            try data.write(to: url)
        } catch {
        }
    }
}
