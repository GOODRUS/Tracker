//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 09.02.2026.
//

import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ weekdays: [Weekday])
}

final class ScheduleViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: ScheduleSelectionDelegate?

    private var selectedWeekdays: Set<Weekday>

    // MARK: - Init

    init(selected: [Weekday]) {
        self.selectedWeekdays = Set(selected)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1) 
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 0xE6 / 255.0,
            green: 0xE8 / 255.0,
            blue: 0xEB / 255.0,
            alpha: 0.3
        )
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupTableView()
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(tableBackgroundView)
        tableBackgroundView.addSubview(tableView)
        view.addSubview(doneButton)

        let rowHeight: CGFloat = 75
        let rowsCount = CGFloat(Weekday.allCases.count)
        let tableHeight = rowHeight * rowsCount 

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableBackgroundView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableBackgroundView.heightAnchor.constraint(equalToConstant: tableHeight),

            tableView.topAnchor.constraint(equalTo: tableBackgroundView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableBackgroundView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableBackgroundView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableBackgroundView.bottomAnchor),

            doneButton.topAnchor.constraint(equalTo: tableBackgroundView.bottomAnchor, constant: 56),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        let sorted = Array(selectedWeekdays).sorted { $0.rawValue < $1.rawValue }
        delegate?.didSelectSchedule(sorted)
        dismiss(animated: true)
    }

    // MARK: - Helpers

    private func title(for weekday: Weekday) -> String {
        switch weekday {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)

        let weekday = Weekday.allCases[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = title(for: weekday)
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        cell.contentConfiguration = content

        let switchView = UISwitch()
        switchView.isOn = selectedWeekdays.contains(weekday)
        switchView.tag = weekday.rawValue
        switchView.onTintColor = UIColor(red: 0.22, green: 0.45, blue: 0.91, alpha: 1) // #3772E7
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView

        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {

        let lastRowIndex = tableView.numberOfRows(inSection: indexPath.section) - 1

        if indexPath.row == lastRowIndex {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: cell.bounds.width,
                bottom: 0,
                right: 0
            )
        } else {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
        }
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        guard let weekday = Weekday(rawValue: sender.tag) else { return }

        if sender.isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}
