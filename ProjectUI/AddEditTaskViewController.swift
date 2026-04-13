import UIKit

final class AddEditTaskViewController: UIViewController {

    var existingTask: TodoTask?
    var onSave: ((TodoTask) -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleField: UITextField = {
        let f = UITextField()
        f.placeholder = "Task title"
        f.borderStyle = .roundedRect
        f.font = .systemFont(ofSize: 17)
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let typeLabel: UILabel = {
        let l = UILabel()
        l.text = "Task type"
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let typePicker: UIPickerView = {
        let p = UIPickerView()
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    private let dueLabel: UILabel = {
        let l = UILabel()
        l.text = "Due date & time"
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let datePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .dateAndTime
        p.preferredDatePickerStyle = .wheels
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    private let notesField: UITextField = {
        let f = UITextField()
        f.placeholder = "Notes (optional)"
        f.borderStyle = .roundedRect
        f.font = .systemFont(ofSize: 17)
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private var selectedType: TaskType = .personal

    override func viewDidLoad() {
        super.viewDidLoad()
        title = existingTask == nil ? "Add Task" : "Edit Task"
        view.backgroundColor = .systemBackground
        datePicker.tintColor = .systemBlue
        var saveConfig = UIButton.Configuration.filled()
        saveConfig.title = "Save"
        saveConfig.image = UIImage(systemName: "checkmark.circle.fill")
        saveConfig.imagePadding = 8
        saveConfig.baseBackgroundColor = .systemBlue
        saveConfig.baseForegroundColor = .white
        saveConfig.cornerStyle = .large
        saveConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 17, weight: .semibold)
            return out
        }
        saveButton.configuration = saveConfig
        typePicker.delegate = self
        typePicker.dataSource = self
        setupLayout()
        populateIfEditing()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleField)
        contentView.addSubview(typeLabel)
        contentView.addSubview(typePicker)
        contentView.addSubview(dueLabel)
        contentView.addSubview(datePicker)
        contentView.addSubview(notesField)
        contentView.addSubview(saveButton)

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

            titleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            typeLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 24),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            typePicker.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            typePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            typePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            typePicker.heightAnchor.constraint(equalToConstant: 120),

            dueLabel.topAnchor.constraint(equalTo: typePicker.bottomAnchor, constant: 24),
            dueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            datePicker.topAnchor.constraint(equalTo: dueLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            notesField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            notesField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            notesField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            notesField.heightAnchor.constraint(equalToConstant: 44),

            saveButton.topAnchor.constraint(equalTo: notesField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }

    private func populateIfEditing() {
        if existingTask == nil {
            datePicker.minimumDate = Date()
        }
        guard let task = existingTask else { return }
        titleField.text = task.title
        selectedType = task.taskType
        typePicker.selectRow(TaskType.allCases.firstIndex(of: task.taskType) ?? 0, inComponent: 0, animated: false)
        datePicker.date = task.dueDate
        notesField.text = task.notes
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let title = titleField.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Missing title", message: "Please enter a task title.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let task: TodoTask
        if let existing = existingTask {
            task = TodoTask(
                id: existing.id,
                title: title,
                taskType: selectedType,
                dueDate: datePicker.date,
                isCompleted: existing.isCompleted,
                notes: notesField.text?.isEmpty == true ? nil : notesField.text
            )
        } else {
            task = TodoTask(
                title: title,
                taskType: selectedType,
                dueDate: datePicker.date,
                notes: notesField.text?.isEmpty == true ? nil : notesField.text
            )
        }
        onSave?(task)
        if existingTask != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension AddEditTaskViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        TaskType.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        TaskType.allCases[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = TaskType.allCases[row]
    }
}
