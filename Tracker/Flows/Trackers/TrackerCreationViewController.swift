//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - TrackerType

enum TrackerType {
    case habit
    case irregular
}

// MARK: - TrackerCreationViewController

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Delegates

    weak var creationDelegate: TrackerCreationDelegate?

    // MARK: - Properties
    
    private var selectedWeekdays: [Weekday] = [] {
        didSet {
            tableView.reloadData()
            updateCreateButtonState()
        }
    }

    private let trackerType: TrackerType

    // состояние
    private var trackerName: String = "" {
        didSet { updateCreateButtonState() }
    }
    private let characterLimit = 38
    private var selectedCategory: String? {
        didSet {
            tableView.reloadData()
            updateCreateButtonState()
        }
    }

    private var keyboardOffset: CGFloat = 0

    // MARK: - Init

    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let clearTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.96, green: 0.35, blue: 0.42, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        let red = UIColor(red: 0.96, green: 0.35, blue: 0.42, alpha: 1)
        button.setTitleColor(red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = red.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor.systemGray3   // disabled state
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupTitle()
        setupTableView()
        setupLayout()
        setupActions()
        setupKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear TrackerCreationViewController")
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - Schedule Text
    
    private func scheduleText() -> String? {
        guard !selectedWeekdays.isEmpty else { return nil }

        if selectedWeekdays.count == Weekday.allCases.count {
            return "Каждый день"
        }

        let shortNames: [Weekday: String] = [
            .monday: "Пн",
            .tuesday: "Вт",
            .wednesday: "Ср",
            .thursday: "Чт",
            .friday: "Пт",
            .saturday: "Сб",
            .sunday: "Вс"
        ]

        let sorted = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }
        let parts = sorted.compactMap { shortNames[$0] }
        return parts.joined(separator: ", ")
    }

    // MARK: - Setup

    private func setupTitle() {
        switch trackerType {
        case .habit:
            titleLabel.text = "Новая привычка"
        case .irregular:
            titleLabel.text = "Новое нерегулярное событие"
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(clearTextButton)
        view.addSubview(errorLabel)
        view.addSubview(tableBackgroundView)
        tableBackgroundView.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        let tableHeight: CGFloat = trackerType == .habit ? 150 : 75

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            clearTextButton.centerYAnchor.constraint(equalTo: nameTextField.centerYAnchor),
            clearTextButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor, constant: -12),
            clearTextButton.widthAnchor.constraint(equalToConstant: 20),
            clearTextButton.heightAnchor.constraint(equalToConstant: 20),

            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),

            tableBackgroundView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            tableBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableBackgroundView.heightAnchor.constraint(equalToConstant: tableHeight),

            tableView.topAnchor.constraint(equalTo: tableBackgroundView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableBackgroundView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableBackgroundView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableBackgroundView.bottomAnchor),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        clearTextButton.addTarget(self, action: #selector(clearTextTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - State

    private func updateCreateButtonState() {
        let hasName = !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        let isValidName = trackerName.count <= characterLimit

        let hasCategory = selectedCategory != nil
        let hasSchedule = trackerType == .habit ? !selectedWeekdays.isEmpty : true

        let enabled = hasName && isValidName && hasCategory && hasSchedule

        createButton.isEnabled = enabled
        createButton.backgroundColor = enabled
        ? UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        : UIColor.systemGray3                                    
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard
            let categoryTitle = selectedCategory,
            !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        let schedule = trackerType == .habit ? selectedWeekdays : []

        let tracker = Tracker(
            id: UUID(),
            name: trackerName.trimmingCharacters(in: .whitespaces),
            color: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1),
            emoji: "😊",
            schedule: schedule
        )

        creationDelegate?.didCreateTracker(tracker, in: categoryTitle)
        dismiss(animated: true)
    }

    @objc private func clearTextTapped() {
        nameTextField.text = ""
        trackerName = ""
        clearTextButton.isHidden = true
        errorLabel.isHidden = true
    }

    @objc private func textFieldChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        trackerName = text

        clearTextButton.isHidden = text.isEmpty
        errorLabel.isHidden = text.count <= characterLimit
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }

        let keyboardFrame = frameValue.cgRectValue
        let keyboardHeight = keyboardFrame.height

        if keyboardOffset == 0 {
            keyboardOffset = keyboardHeight / 3
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -self.keyboardOffset)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        if keyboardOffset != 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = .identity
            }
            keyboardOffset = 0
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackerCreationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        trackerType == .habit ? 2 : 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var content = UIListContentConfiguration.valueCell()
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        content.textProperties.color = .label

        if trackerType == .habit {
            if indexPath.row == 0 {
                content.text = "Категория"
                content.secondaryText = selectedCategory
            } else {
                content.text = "Расписание"
                content.secondaryText = scheduleText()
            }
        } else {
            content.text = "Категория"
            content.secondaryText = selectedCategory
        }

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: indexPath.section) - 1

        if indexPath.row == lastRowIndex {
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: cell.bounds.width,
                                               bottom: 0,
                                               right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 16,
                                               bottom: 0,
                                               right: 16)
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if trackerType == .habit {
            if indexPath.row == 0 {
                let categoryVC = CategorySelectionViewController()
                categoryVC.delegate = self
                present(categoryVC, animated: true)
            } else {
                let scheduleVC = ScheduleViewController(selected: selectedWeekdays)
                scheduleVC.delegate = self
                present(scheduleVC, animated: true)
            }
        } else {
            let categoryVC = CategorySelectionViewController()
            categoryVC.delegate = self
            present(categoryVC, animated: true)
        }
    }
}

// MARK: - CategorySelectionDelegate

extension TrackerCreationViewController: CategorySelectionDelegate {

    func didSelectCategory(_ category: String) {
        selectedCategory = category
    }
}

// MARK: - ScheduleSelectionDelegate

extension TrackerCreationViewController: ScheduleSelectionDelegate {

    func didSelectSchedule(_ weekdays: [Weekday]) {
        selectedWeekdays = weekdays
    }
}
