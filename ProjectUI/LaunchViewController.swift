import UIKit

final class LaunchViewController: UIViewController {

    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Task Manager"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamNamesLabel: UILabel = {
        let label = UILabel()
        label.text = "Tigran Khachaturyan\nKarim Karabayev"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToTaskList()
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(appTitleLabel)
        view.addSubview(teamNamesLabel)

        NSLayoutConstraint.activate([
            appTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            appTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            appTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),

            teamNamesLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 32),
            teamNamesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            teamNamesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func navigateToTaskList() {
        let taskListVC = TaskListViewController()
        if let nav = navigationController {
            nav.setViewControllers([taskListVC], animated: true)
            nav.setNavigationBarHidden(false, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: taskListVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}
