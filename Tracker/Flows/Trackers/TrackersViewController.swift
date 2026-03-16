//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Data

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()

    // label внутри правой пилюли с датой, чтобы обновлять текст
    private weak var datePillLabel: UILabel?
    
    // MARK: - UI

    // Заголовок "Трекеры"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1) // #1A1B22
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Поле поиска
    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let searchIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "search"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let searchPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Поиск"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red: 0.47, green: 0.47, blue: 0.50, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Коллекция
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 34)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )

        collectionView.register(
            TrackerSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeader.reuseIdentifier
        )

        return collectionView
    }()

    // Заглушка Star
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Star")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Кнопка "Фильтры"
    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = UIColor(red: 0.22, green: 0.49, blue: 0.91, alpha: 1)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 15.0, *) {
            // убираем конфигурацию, чтобы высота/ширина задавались констрейнтами
            button.configuration = nil
        }

        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupTopTitleAndDate()
        setupSearchField()
        setupLayout()
        setupFiltersButton()
        updatePlaceholderVisibility()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.title = nil

        let plusConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
        let plusImage = UIImage(systemName: "plus")?.applyingSymbolConfiguration(plusConfig)

        let addButtonItem = UIBarButtonItem(
            image: plusImage,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem = addButtonItem

        let blackColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        navigationController?.navigationBar.tintColor = blackColor

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .foregroundColor: blackColor,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.shadowImage = UIImage()
        }

        navigationController?.navigationBar.prefersLargeTitles = false
    }

    /// Заголовок и дата в навбаре (дата — правый UIBarButtonItem)
    private func setupTopTitleAndDate() {
        // Заголовок
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        // Формируем строку даты для пилюли
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
        let dateString = formatter.string(from: currentDate)

        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dateLabel.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        let dateContainer = UIView()
        dateContainer.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1) // #F0F0F0
        dateContainer.layer.cornerRadius = 8
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            // Внутренние отступы пилюли.
            // top = 4 делает её визуально чуть ниже текста в навбаре
            dateLabel.topAnchor.constraint(equalTo: dateContainer.topAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor, constant: -4),
            dateLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: -10)
        ])

        // Делаем пилюлю кликабельной
        let tap = UITapGestureRecognizer(target: self, action: #selector(datePillTapped))
        dateContainer.isUserInteractionEnabled = true
        dateContainer.addGestureRecognizer(tap)

        let dateItem = UIBarButtonItem(customView: dateContainer)
        navigationItem.rightBarButtonItem = dateItem

        // Сохраним для обновления текста при смене даты
        self.datePillLabel = dateLabel
    }
    
    private func applySelectedDate(_ date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)

        // Не допускаем будущие даты
        if selectedDay > today {
            currentDate = today
        } else {
            currentDate = selectedDay
        }

        // Обновим текст в пилюле
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
        datePillLabel?.text = formatter.string(from: currentDate)

        // Сейчас просто перерисуем список.
        // Позже можно добавить фильтрацию по расписанию.
        collectionView.reloadData()
    }
    
    private func setupSearchField() {
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchIconView)
        searchContainer.addSubview(searchPlaceholderLabel)

        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 36),

            searchIconView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 8),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 18),
            searchIconView.heightAnchor.constraint(equalToConstant: 18),

            searchPlaceholderLabel.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 8),
            searchPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: searchContainer.trailingAnchor, constant: -8),
            searchPlaceholderLabel.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor)
        ])
    }

    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupFiltersButton() {
        view.addSubview(filtersButton)

        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // ближе к линии разделения над TabBar
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }

    private func updatePlaceholderVisibility() {
        let hasTrackers = categories.contains { !$0.trackers.isEmpty }

        placeholderImageView.isHidden = hasTrackers
        placeholderLabel.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers

        // Кнопка "Фильтры" только если есть трекеры
        filtersButton.isHidden = !hasTrackers
    }

    // MARK: - Helpers (completion)

    private func completedCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }

    private func isCompletedToday(_ tracker: Tracker) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completedTrackers.contains {
            $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: today)
        }
    }

    private func toggleCompletion(for tracker: Tracker) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: currentDate)

        // Нельзя отмечать будущую дату
        if selectedDay > today { return }

        if let index = completedTrackers.firstIndex(
            where: { $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: selectedDay) }
        ) {
            completedTrackers.remove(at: index)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: selectedDay)
            completedTrackers.append(record)
        }
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let typeVC = TrackerTypeViewController()
        typeVC.creationDelegate = self
        typeVC.modalPresentationStyle = .pageSheet

        if let sheet = typeVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        present(typeVC, animated: true)
    }

    @objc private func filtersButtonTapped() {
        print("Фильтры нажаты")
        // здесь позже будет логика выбора фильтра
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let newDate = sender.date

        // Если дата в будущем — откатываем на сегодня (или ближайший допустимый день)
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: newDate)

        if selectedDay > today {
            sender.date = today
            currentDate = today
        } else {
            currentDate = selectedDay
        }

        // Здесь можно обновить отображаемые трекеры под currentDate,
        // если ты будешь реализовывать фильтрацию по расписанию.
        collectionView.reloadData()
    }
    
    @objc private func datePillTapped() {
        showDatePickerAlert()
    }

    private func showDatePickerAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels      // в алерте удобнее колесами
        picker.locale = Locale(identifier: "ru_RU")
        picker.date = currentDate
        picker.tintColor = UIColor(red: 0.22, green: 0.49, blue: 0.91, alpha: 1) // синий

        // Встраиваем пикер в UIAlertController
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.heightAnchor.constraint(equalToConstant: 216)
        ])

        // Кнопка "Готово"
        let okAction = UIAlertAction(title: "Готово", style: .default) { [weak self] _ in
            self?.applySelectedDate(picker.date)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let days = completedCount(for: tracker)
        let completedToday = isCompletedToday(tracker)

        cell.configure(with: tracker,
                       completedDays: days,
                       isCompletedToday: completedToday)
        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeader.reuseIdentifier,
                for: indexPath
              ) as? TrackerSectionHeader else {
            return UICollectionReusableView()
        }

        let category = categories[indexPath.section]
        header.configure(title: category.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 + 16 + 9
        let availableWidth = collectionView.bounds.width - padding
        let width = availableWidth / 2
        let height: CGFloat = 148
        return CGSize(width: width, height: height)
    }
}

// MARK: - TrackerCreationDelegate

extension TrackersViewController: TrackerCreationDelegate {

    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let category = categories[index]
            let newTrackers = category.trackers + [tracker]
            let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)

            var newCategories = categories
            newCategories[index] = newCategory
            categories = newCategories
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }

        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {

    func didTapComplete(for tracker: Tracker, in cell: TrackerCell) {
        toggleCompletion(for: tracker)

        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let updatedTracker = categories[indexPath.section].trackers[indexPath.item]
        let days = completedCount(for: updatedTracker)
        let completedToday = isCompletedToday(updatedTracker)

        cell.configure(with: updatedTracker,
                       completedDays: days,
                       isCompletedToday: completedToday)
    }
}
