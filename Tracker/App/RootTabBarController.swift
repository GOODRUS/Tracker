//
//  RootTabBarController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()

        trackersVC.title = "Трекеры"
        statisticsVC.title = "Статистика"

        let trackersNav = UINavigationController(rootViewController: trackersVC)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)

        // MARK: - Иконка "Трекеры"

        var trackersImage = UIImage(named: "record.circle.fill")
        if let baseImage = trackersImage {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            trackersImage = baseImage.applyingSymbolConfiguration(config) ?? baseImage
        }

        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: trackersImage?.withRenderingMode(.alwaysTemplate),
            selectedImage: trackersImage?.withRenderingMode(.alwaysTemplate)
        )

        // MARK: - Иконка "Статистика"

        var statisticsImage = UIImage(named: "hare.fill")
        if let baseImage = statisticsImage {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            statisticsImage = baseImage.applyingSymbolConfiguration(config) ?? baseImage
        }

        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: statisticsImage?.withRenderingMode(.alwaysTemplate),
            selectedImage: statisticsImage?.withRenderingMode(.alwaysTemplate)
        )

        viewControllers = [trackersNav, statisticsNav]
    }

    private func setupAppearance() {
        let activeColor = UIColor(red: 0.22, green: 0.49, blue: 0.91, alpha: 1)       // #3772E7
        let inactiveColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1)     // #AEAFB4

        tabBar.tintColor = activeColor
        tabBar.unselectedItemTintColor = inactiveColor

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.shadowColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1) // линия над TabBar

            appearance.stackedLayoutAppearance.selected.iconColor = activeColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: activeColor
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: inactiveColor
            ]

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = .systemBackground
        }
    }
}
