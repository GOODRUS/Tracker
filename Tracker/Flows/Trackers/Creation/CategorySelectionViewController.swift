//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - CategorySelectionViewController

final class CategorySelectionViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: CategorySelectionDelegate?

    private var categories: [String] = [
        "Важное",
        "Домашний уют",
        "Работа",
        "Учёба"
    ]

    // MARK: - UI

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor(red: 0.22, green: 0.49, blue: 0.91, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Категория"

        setupTableView()
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        addButton.addAction(UIAction { [weak self] _ in
            self?.addButtonTapped()
        }, for: .touchUpInside)
    }

    // MARK: - Actions

   private func addButtonTapped() {
        let alert = UIAlertController(
            title: "Новая категория",
            message: "Введите название категории",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Название категории"
        }

        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)

        let createAction = UIAlertAction(title: "Готово", style: .default) { [weak self] _ in
            guard
                let self,
                let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces),
                !text.isEmpty
            else { return }

            self.categories.append(text)
            self.tableView.reloadData()
        }

        createAction.isEnabled = false

        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields?.first,
            queue: .main
        ) { notification in
            let textField = notification.object as? UITextField
            let text = textField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            createAction.isEnabled = !text.isEmpty
        }

        alert.addAction(cancelAction)
        alert.addAction(createAction)

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategorySelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.row]
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategorySelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selected = categories[indexPath.row]
        delegate?.didSelectCategory(selected)
        dismiss(animated: true)
    }
}
