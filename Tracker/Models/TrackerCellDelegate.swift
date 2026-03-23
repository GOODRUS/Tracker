//
//  TrackerCellDelegate.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 12.02.2026.
//

import Foundation

// MARK: - TrackerCellDelegate

protocol TrackerCellDelegate: AnyObject {
    func didTapComplete(for tracker: Tracker, in cell: TrackerCell)
}
