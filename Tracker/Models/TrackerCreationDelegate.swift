//
//  TrackerCreationDelegate.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 12.02.2026.
//

import Foundation

// MARK: - TrackerCreationDelegate

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String)
}
