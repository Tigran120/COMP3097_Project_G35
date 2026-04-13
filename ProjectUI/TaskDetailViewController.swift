import UIKit

final class TaskDetailViewController: UIViewController {

    private var task: TodoTask
    private let taskIndex: Int
    var onUpdate: ((TodoTask) -> Void)?
    var onDelete: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .label
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let typeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let completedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let notesLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    init(task: TodoTask, taskIndex: Int) {
        self.task = task
        self.taskIndex = taskIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Task Details"
        view.backgroundColor = .systemBackground
        applyDetailButtonStyles()
        setupLayout()
        refreshDisplay()
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    private func applyDetailButtonStyles() {
        var editConfig = UIButton.Configuration.filled()
        editConfig.title = "Edit"
        editConfig.image = UIImage(systemName: "pencil")
        editConfig.imagePadding = 8
        editConfig.baseBackgroundColor = .systemBlue
        editConfig.baseForegroundColor = .white
        editConfig.cornerStyle = .large
        editConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 17, weight: .semibold)
            return out
        }
        editButton.configuration = editConfig

        var delConfig = UIButton.Configuration.filled()
        delConfig.title = "Delete"
        delConfig.image = UIImage(systemName: "trash")
        delConfig.imagePadding = 8
        delConfig.baseBackgroundColor = .systemRed
        delConfig.baseForegroundColor = .white
        delConfig.cornerStyle = .large
        delConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 17, weight: .semibold)
            return out
        }
        deleteButton.configuration = delConfig
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDisplay()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(dueLabel)
        contentView.addSubview(completedLabel)
        contentView.addSubview(notesLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)

        let padding: CGFloat = 20
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            typeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            dueLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            dueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            completedLabel.topAnchor.constraint(equalTo: dueLabel.bottomAnchor, constant: 8),
            completedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            notesLabel.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 16),
            notesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            notesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            editButton.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 32),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            editButton.heightAnchor.constraint(equalToConstant: 50),

            deleteButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 12),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }

    private func refreshDisplay() {
        titleLabel.text = task.title
        if task.isCompleted {
            statusLabel.text = "✓ Completed"
            statusLabel.textColor = .systemGreen
        } else {
            let status = TodoTask.dueStatus(for: task.dueDate)
            switch status {
            case .overdue:
                statusLabel.text = "🔴 Overdue"
                statusLabel.textColor = .systemRed
            case .dueSoon:
                statusLabel.text = "🟡 Due soon"
                statusLabel.textColor = .systemOrange
            case .upcoming:
                statusLabel.text = "🟢 Upcoming"
                statusLabel.textColor = .systemGreen
            }
        }
        typeLabel.text = "Type: \(task.taskType.rawValue)"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueLabel.text = "Due: \(formatter.string(from: task.dueDate))"
        completedLabel.text = task.isCompleted ? "Completed: Yes" : "Completed: No"
        notesLabel.text = task.notes.map { "Notes: \($0)" } ?? "Notes: —"
        notesLabel.isHidden = task.notes == nil || task.notes?.isEmpty == true
    }

    @objc private func editTapped() {
        let addVC = AddEditTaskViewController()
        addVC.existingTask = task
        addVC.onSave = { [weak self] updated in
            self?.task = updated
            self?.onUpdate?(updated)
            self?.refreshDisplay()
        }
        navigationController?.pushViewController(addVC, animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete task?",
            message: "This cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.onDelete?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
