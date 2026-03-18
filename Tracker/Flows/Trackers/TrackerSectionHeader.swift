//
//  TrackerSectionHeader.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - TrackerSectionHeader

final class TrackerSectionHeader: UICollectionReusableView {

    // MARK: - Static

    static let reuseIdentifier = "TrackerSectionHeader"

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(title: String) {
        titleLabel.text = title
    }
}
