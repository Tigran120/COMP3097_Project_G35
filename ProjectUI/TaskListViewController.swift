import UIKit

final class TaskListViewController: UIViewController {

    private var tasks: [TodoTask] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refresh = UIRefreshControl()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private var emptyPulseStarted = false

    private let emptyStateView: UIStackView = {
        let image = UIImageView(image: UIImage(systemName: "tray.chevron.open"))
        image.tintColor = .systemBlue
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 72),
            image.heightAnchor.constraint(equalToConstant: 72)
        ])
        let title = UILabel()
        title.text = "No tasks yet"
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textColor = .label
        title.textAlignment = .center
        let subtitle = UILabel()
        subtitle.text = "Tap + in the corner to add your first task."
        subtitle.font = .systemFont(ofSize: 15, weight: .regular)
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [image, title, subtitle])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always
        setupEmptyState()
        setupTableView()
        setupRefresh()
        setupAddButton()
        applyStoredTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
        applyStoredTasks()
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

    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupRefresh() {
        refresh.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    @objc private func refreshTriggered() {
        applyStoredTasks()
        refresh.endRefreshing()
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Add task"
    }

    private func loadTasks() {
        tasks = TaskStorage.shared.loadTasks()
    }

    private func sortTasks() {
        tasks.sort { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return lhs.isCompleted == false && rhs.isCompleted == true
            }
            return lhs.dueDate < rhs.dueDate
        }
    }

    private func applyStoredTasks() {
        loadTasks()
        sortTasks()
        tableView.reloadData()
        let isEmpty = tasks.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isScrollEnabled = !isEmpty
        if isEmpty {
            if !emptyPulseStarted {
                emptyPulseStarted = true
                pulseEmptyStateIcon()
            }
        } else {
            emptyPulseStarted = false
            if let icon = emptyStateView.arrangedSubviews.first as? UIImageView {
                icon.layer.removeAllAnimations()
                icon.transform = .identity
            }
        }
    }

    private func pulseEmptyStateIcon() {
        guard let icon = emptyStateView.arrangedSubviews.first as? UIImageView else { return }
        icon.layer.removeAllAnimations()
        icon.transform = .identity
        UIView.animate(
            withDuration: 1.25,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction]
        ) {
            icon.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }
    }

    private func persistTasks() {
        TaskStorage.shared.saveTasks(tasks)
    }

    @objc private func addTapped() {
        let addVC = AddEditTaskViewController()
        addVC.onSave = { [weak self] task in
            self?.tasks.append(task)
            self?.sortTasks()
            self?.persistTasks()
            self?.applyStoredTasks()
        }
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }

    func openTaskDetail(_ task: TodoTask, at index: Int) {
        let detailVC = TaskDetailViewController(task: task, taskIndex: index)
        detailVC.onUpdate = { [weak self] updated in
            guard let self = self, index < self.tasks.count else { return }
            self.tasks[index] = updated
            self.sortTasks()
            self.persistTasks()
            self.applyStoredTasks()
        }
        detailVC.onDelete = { [weak self] in
            guard let self = self, index < self.tasks.count else { return }
            self.tasks.remove(at: index)
            self.persistTasks()
            self.applyStoredTasks()
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
        let status = TodoTask.dueStatus(for: task.dueDate)
        cell.configure(task: task, status: status)
        cell.onToggleComplete = { [weak self] in
            guard let self = self else { return }
            self.impactFeedback.impactOccurred()
            self.tasks[indexPath.row].isCompleted.toggle()
            self.sortTasks()
            self.persistTasks()
            self.applyStoredTasks()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectionFeedback.selectionChanged()
        openTaskDetail(tasks[indexPath.row], at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self = self else {
                done(false)
                return
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.tasks.remove(at: indexPath.row)
            self.persistTasks()
            self.applyStoredTasks()
            done(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
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

    private let typePill: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textAlignment = .center
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
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
        s.spacing = 4
        s.alignment = .fill
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        checkboxButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        let pillRow = UIStackView(arrangedSubviews: [typePill, UIView()])
        pillRow.axis = .horizontal
        pillRow.alignment = .center
        textStack.addArrangedSubview(pillRow)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(dueLabel)
        stack.addArrangedSubview(checkboxButton)
        stack.addArrangedSubview(indicatorView)
        stack.addArrangedSubview(textStack)
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
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

    func configure(task: TodoTask, status: TaskDueStatus) {
        if task.isCompleted {
            let s = NSMutableAttributedString(string: task.title)
            let full = NSRange(location: 0, length: (task.title as NSString).length)
            s.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: full)
            s.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: full)
            titleLabel.attributedText = s
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = task.title
        }
        titleLabel.alpha = task.isCompleted ? 0.85 : 1
        typePill.text = "  \(task.taskType.rawValue)  "
        switch task.taskType {
        case .other:
            typePill.backgroundColor = .secondarySystemFill
            typePill.textColor = .secondaryLabel
        default:
            typePill.backgroundColor = task.taskType.listAccentColor.withAlphaComponent(0.9)
            typePill.textColor = .white
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dueLabel.text = formatter.string(from: task.dueDate)
        checkboxButton.isSelected = task.isCompleted
        if task.isCompleted {
            indicatorView.backgroundColor = .tertiaryLabel
        } else {
            switch status {
            case .overdue:   indicatorView.backgroundColor = .systemRed
            case .dueSoon:   indicatorView.backgroundColor = .systemYellow
            case .upcoming:  indicatorView.backgroundColor = .systemGreen
            }
        }
    }
}

extension TaskType {
    fileprivate var listAccentColor: UIColor {
        switch self {
        case .personal: return .systemIndigo
        case .work: return .systemBlue
        case .shopping: return .systemOrange
        case .other: return .systemGray
        }
    }
}
