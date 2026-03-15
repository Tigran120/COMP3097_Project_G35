import UIKit

final class TaskListViewController: UIViewController {

    private var tasks: [Task] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        setupAddButton()
        loadTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseId)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
    }

    private func loadTasks() {
        tasks = TaskStorage.shared.loadTasks()
    }

    private func persistTasks() {
        TaskStorage.shared.saveTasks(tasks)
    }

    @objc private func addTapped() {
        let addVC = AddEditTaskViewController()
        addVC.onSave = { [weak self] task in
            self?.tasks.append(task)
            self?.persistTasks()
            self?.tableView.reloadData()
        }
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }

    func openTaskDetail(_ task: Task, at index: Int) {
        let detailVC = TaskDetailViewController(task: task, taskIndex: index)
        detailVC.onUpdate = { [weak self] updated in
            guard let self = self, index < self.tasks.count else { return }
            self.tasks[index] = updated
            self.persistTasks()
            self.tableView.reloadData()
        }
        detailVC.onDelete = { [weak self] in
            guard let self = self, index < self.tasks.count else { return }
            self.tasks.remove(at: index)
            self.persistTasks()
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.reuseId, for: indexPath) as! TaskListCell
        let task = tasks[indexPath.row]
        let status = Task.dueStatus(for: task.dueDate)
        cell.configure(task: task, status: status)
        cell.onToggleComplete = { [weak self] in
            guard let self = self else { return }
            self.tasks[indexPath.row].isCompleted.toggle()
            self.persistTasks()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openTaskDetail(tasks[indexPath.row], at: indexPath.row)
    }
}

final class TaskListCell: UITableViewCell {

    static let reuseId = "TaskListCell"

    var onToggleComplete: (() -> Void)?

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let checkboxButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "circle"), for: .normal)
        b.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        b.tintColor = .systemGreen
        return b
    }()

    private let indicatorView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: 10),
            v.heightAnchor.constraint(equalToConstant: 10)
        ])
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .medium)
        l.textColor = .label
        l.numberOfLines = 1
        return l
    }()

    private let dueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        return l
    }()

    private let textStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        checkboxButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(dueLabel)
        stack.addArrangedSubview(checkboxButton)
        stack.addArrangedSubview(indicatorView)
        stack.addArrangedSubview(textStack)
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggleTapped() {
        onToggleComplete?()
    }

    func configure(task: Task, status: TaskDueStatus) {
        titleLabel.text = task.title
        titleLabel.alpha = task.isCompleted ? 0.5 : 1
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dueLabel.text = formatter.string(from: task.dueDate)
        checkboxButton.isSelected = task.isCompleted
        switch status {
        case .overdue:   indicatorView.backgroundColor = .systemRed
        case .dueSoon:   indicatorView.backgroundColor = .systemYellow
        case .upcoming:  indicatorView.backgroundColor = .systemGreen
        }
    }
}
