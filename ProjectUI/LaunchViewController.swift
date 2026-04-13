import UIKit

final class LaunchViewController: UIViewController {

    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor.systemBlue.withAlphaComponent(0.28).cgColor,
            UIColor.systemCyan.withAlphaComponent(0.12).cgColor,
            UIColor.systemBackground.cgColor
        ]
        g.locations = [0, 0.45, 1]
        g.startPoint = CGPoint(x: 0.2, y: 0)
        g.endPoint = CGPoint(x: 0.8, y: 1)
        return g
    }()

    private let heroIcon: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        v.tintColor = .systemBlue
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Task Manager"
        label.font = .systemFont(ofSize: 30, weight: .bold)
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
        view.layer.insertSublayer(gradientLayer, at: 0)
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToTaskList()
        }
    }

    private func playEntranceAnimation() {
        heroIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: -0.2)
        heroIcon.alpha = 0
        appTitleLabel.alpha = 0
        teamNamesLabel.alpha = 0
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.68,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut]
        ) {
            self.heroIcon.transform = .identity
            self.heroIcon.alpha = 1
            self.appTitleLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.45, delay: 0.2, options: [.curveEaseOut]) {
            self.teamNamesLabel.alpha = 1
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(heroIcon)
        view.addSubview(appTitleLabel)
        view.addSubview(teamNamesLabel)

        NSLayoutConstraint.activate([
            heroIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            heroIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            heroIcon.widthAnchor.constraint(equalToConstant: 92),
            heroIcon.heightAnchor.constraint(equalToConstant: 92),

            appTitleLabel.topAnchor.constraint(equalTo: heroIcon.bottomAnchor, constant: 20),
            appTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            appTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),

            teamNamesLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 28),
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
