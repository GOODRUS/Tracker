//
//  TrackerModels.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - Weekday (Расписание)

enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

// MARK: - Models

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}
