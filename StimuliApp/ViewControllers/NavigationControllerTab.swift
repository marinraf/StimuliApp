//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class NavigationControllerTab: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.barTintColor = Color.navigationTab.toUIColor
        delegate = self

        settingViewControllersMenu()
    }

    func settingViewControllersMenu() {

        let vc0 = UINavigationController(rootViewController: MainViewController())
        vc0.tabBarItem = UITabBarItem(title: "StimuliApp",
                                      image: UIImage(named: "stimuliapp gray"),
                                      selectedImage: UIImage(named: "stimuliapp blue"))
        vc0.addCustomTransitioning()

        let screen1 = TestsMenu(title: "Tests")
        let vc1 = UINavigationController(rootViewController: MenuViewController(screen: screen1))
        vc1.tabBarItem = UITabBarItem(title: "Tests",
                                      image: UIImage(named: "tests gray"),
                                      selectedImage: UIImage(named: "tests blue"))
        vc1.addCustomTransitioning()

        let screen2 = RunMenu(title: "Run Test")
        let vc2 = UINavigationController(rootViewController: MenuViewController(screen: screen2))
        vc2.tabBarItem = UITabBarItem(title: "Run Test",
                                      image: UIImage(named: "run test gray"),
                                      selectedImage: UIImage(named: "run test blue"))
        vc2.addCustomTransitioning()

        let screen3 = ResultsMenu(title: "Results")
        let vc3 = UINavigationController(rootViewController: MenuViewController(screen: screen3))
        vc3.tabBarItem = UITabBarItem(title: "Results",
                                      image: UIImage(named: "results gray"),
                                      selectedImage: UIImage(named: "results blue"))
        vc3.addCustomTransitioning()

        let screen4 = SettingsMenu(title: "App Settings")
        let vc4 = UINavigationController(rootViewController: MenuViewController(screen: screen4))
        vc4.tabBarItem = UITabBarItem(title: "App Settings",
                                      image: UIImage(named: "settings gray"),
                                      selectedImage: UIImage(named: "settings blue"))
        vc4.addCustomTransitioning()

        viewControllers = [vc0, vc1, vc2, vc3, vc4]

        Flow.shared.tabBarController.selectedIndex = 0
    }

    func settingViewControllersTest() {

        let vc0 = UINavigationController(rootViewController: MainViewController())
        vc0.tabBarItem = UITabBarItem(title: "Back to Main Menu",
                                      image: UIImage(named: "back gray"),
                                      selectedImage: UIImage(named: "back blue"))
        vc0.addCustomTransitioning()

        let screen1 = TestsMenu(title: "Test")
        let vc1 = UINavigationController(rootViewController: MenuViewController(screen: screen1))
        vc1.tabBarItem = UITabBarItem(title: "Test",
                                         image: UIImage(named: "test gray"),
                                         selectedImage: UIImage(named: "test blue"))
        vc1.addCustomTransitioning()

        let screen2 = SectionsMenu(title: "Sections in")
        let vc2 = UINavigationController(rootViewController: MenuViewController(screen: screen2))
        vc2.tabBarItem = UITabBarItem(title: "Scenes & Sections",
                                         image: UIImage(named: "sections gray"),
                                         selectedImage: UIImage(named: "sections blue"))
        vc2.addCustomTransitioning()

        let screen3 = StimuliMenu(title: "Stimuli in")
        let vc3 = UINavigationController(rootViewController: MenuViewController(screen: screen3))
        vc3.tabBarItem = UITabBarItem(title: "Stimuli",
                                         image: UIImage(named: "stimuli gray"),
                                         selectedImage: UIImage(named: "stimuli blue"))
        vc3.addCustomTransitioning()

        let screen4 = ListsOfValuesMenu(title: "Lists in")
        let vc4 = UINavigationController(rootViewController: MenuViewController(screen: screen4))
        vc4.tabBarItem = UITabBarItem(title: "Lists",
                                         image: UIImage(named: "values gray"),
                                         selectedImage: UIImage(named: "values blue"))
        vc4.addCustomTransitioning()

        viewControllers = [vc0, vc1, vc2, vc3, vc4]

        Flow.shared.tabBarController.selectedIndex = 1
    }
}
