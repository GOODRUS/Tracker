//
//  TrackerCreationDelegate.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 12.02.2026.
//

import Foundation

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String)
}
