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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
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
        title = "Расписание"

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
        view.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
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
        delegate?.didSelectSchedule(Array(selectedWeekdays).sorted { $0.rawValue < $1.rawValue })
        dismiss(animated: true)
    }

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
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
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
