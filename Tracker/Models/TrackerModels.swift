//
//  TrackerModels.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - Расписание

/// День недели для расписания (понедельник–воскресенье)
enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

// MARK: - Модели

/// Трекер (привычка или нерегулярное событие)
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    /// Расписание: в какие дни действует трекер.
    /// Для нерегулярных событий можно хранить [].
    let schedule: [Weekday]
}

/// Категория трекеров
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

/// Запись о выполнении трекера в конкретную дату
struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}
