//
//  RootTabBarController.swift
//  Tracker
//
//  Created by Дмитрий Шиляев on 08.02.2026.
//

import UIKit

// MARK: - RootTabBarController

final class RootTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    // MARK: - Setup Tabs

    private func setupTabs() {
        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()

        trackersVC.title = "Трекеры"
        statisticsVC.title = "Статистика"

        let trackersNav = UINavigationController(rootViewController: trackersVC)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)

        let trackersConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let trackersImage = UIImage(
            systemName: "record.circle.fill",
            withConfiguration: trackersConfig
        )?.withRenderingMode(.alwaysTemplate)

        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: trackersImage,
            selectedImage: trackersImage
        )

        let statisticsConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let statisticsImage = UIImage(
            systemName: "hare.fill",
            withConfiguration: statisticsConfig
        )?.withRenderingMode(.alwaysTemplate)

        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: statisticsImage,
            selectedImage: statisticsImage
        )

        viewControllers = [trackersNav, statisticsNav]
    }

    // MARK: - Appearance

    private func setupAppearance() {
        let activeColor = UIColor(red: 0.22, green: 0.49, blue: 0.91, alpha: 1)
        let inactiveColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1)    

        tabBar.tintColor = activeColor
        tabBar.unselectedItemTintColor = inactiveColor

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1)

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
