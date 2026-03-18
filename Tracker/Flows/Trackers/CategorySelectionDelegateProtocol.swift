//
//  CategorySelectionDelegateProtocol.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - CategorySelectionDelegate

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}
