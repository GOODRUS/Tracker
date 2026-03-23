//
//  TrackerCell.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - TrackerCell

final class TrackerCell: UICollectionViewCell {

    // MARK: - Static

    static let reuseIdentifier = "TrackerCell"

    // MARK: - Properties

    weak var delegate: TrackerCellDelegate?

    private var tracker: Tracker?
    private var completedDays: Int = 0

    // MARK: - UI

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true

        return button
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setupLayout()
        actionButton.addTarget(self,
                               action: #selector(actionButtonTapped),
                               for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Layout

    private func setupLayout() {
        contentView.addSubview(cardView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(actionButton)

        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor)
            ,cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 32),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 32),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            actionButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            actionButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 132),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),

            daysLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        ])
    }

    // MARK: - Configure

    func configure(with tracker: Tracker,
                   completedDays: Int,
                   isCompletedToday: Bool) {
        self.tracker = tracker
        self.completedDays = completedDays

        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysLabel.text = daysText(for: completedDays)

        updateActionButton(isCompletedToday: isCompletedToday)
    }

    // MARK: - Helpers

    private func daysText(for count: Int) -> String {
        let lastTwo = count % 100
        let last = count % 10

        let word: String
        if lastTwo >= 11 && lastTwo <= 14 {
            word = "дней"
        } else {
            switch last {
            case 1: word = "день"
            case 2, 3, 4: word = "дня"
            default: word = "дней"
            }
        }
        return "\(count) \(word)"
    }

    private func updateActionButton(isCompletedToday: Bool) {
        let plusColor = UIColor(red: 0.20, green: 0.81, blue: 0.41, alpha: 1)

        let symbolSize: CGFloat = isCompletedToday ? 12 : 11
        let symbolWeight: UIImage.SymbolWeight = isCompletedToday ? .bold : .medium
        let config = UIImage.SymbolConfiguration(pointSize: symbolSize, weight: symbolWeight)

        let systemName = isCompletedToday ? "checkmark" : "plus"
        let image = UIImage(systemName: systemName, withConfiguration: config)

        actionButton.setImage(image, for: .normal)
        actionButton.setTitle(nil, for: .normal)
        actionButton.tintColor = .white
        actionButton.backgroundColor = isCompletedToday
            ? plusColor.withAlphaComponent(0.3)
            : plusColor
    }
    
    // MARK: - Actions

    @objc private func actionButtonTapped() {
        guard let tracker else { return }
        delegate?.didTapComplete(for: tracker, in: self)
    }
}
