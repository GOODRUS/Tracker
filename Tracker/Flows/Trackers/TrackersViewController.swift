//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {

    // MARK: - Data

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

    private var currentDate: Date = Date() {
        didSet {
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }
    
    private func weekdayForDate(_ date: Date) -> Weekday? {
        let calendar = Calendar.current
        let systemWeekday = calendar.component(.weekday, from: date)

        switch systemWeekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }

    private var visibleCategories: [TrackerCategory] {
        guard let weekday = weekdayForDate(currentDate) else {
            return categories
        }

        return categories.compactMap { category in
            let trackersForDay = category.trackers.filter { tracker in
                tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
            }

            guard !trackersForDay.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackersForDay)
        }
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // UIDatePicker в навбаре
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.tintColor = UIColor(red: 0.22, green: 0.49, blue: 0.91, alpha: 1)
        return picker
    }()

    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 0x76 / 255.0,
            green: 0x76 / 255.0,
            blue: 0x80 / 255.0,
            alpha: 0.12
        )
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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 34)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
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
        label.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white   // фиксируем белый фон

        setupNavigationBar()
        setupTopTitleAndDate()
        setupSearchField()
        setupLayout()
        updatePlaceholderVisibility()
    }
    

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.title = nil

        // левая кнопка "+"
        let plusConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
        let plusImage = UIImage(systemName: "plus")?.applyingSymbolConfiguration(plusConfig)

        let addButtonItem = UIBarButtonItem(
            image: plusImage,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem = addButtonItem

        // правый элемент — компактный UIDatePicker
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        let blackColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        navigationController?.navigationBar.tintColor = blackColor

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white          // header строго белый
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .foregroundColor: blackColor,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.shadowImage = UIImage()
        }

        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupTopTitleAndDate() {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func applySelectedDate(_ date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)

        if selectedDay > today {
            currentDate = today
            datePicker.date = today
        } else {
            currentDate = selectedDay
            datePicker.date = selectedDay
        }
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

    private func updatePlaceholderVisibility() {
        let hasTrackers = visibleCategories.contains { !$0.trackers.isEmpty }

        placeholderImageView.isHidden = hasTrackers
        placeholderLabel.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
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

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        applySelectedDate(sender.date)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
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

        let category = visibleCategories[indexPath.section]
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

        let updatedTracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let days = completedCount(for: updatedTracker)
        let completedToday = isCompletedToday(updatedTracker)

        cell.configure(with: updatedTracker,
                       completedDays: days,
                       isCompletedToday: completedToday)
    }
}
