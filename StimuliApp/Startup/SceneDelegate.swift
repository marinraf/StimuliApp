//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let flow = Flow.shared

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let mainScreen = Main()
        flow.screen = mainScreen

        let tabBar = NavigationControllerTab()
        flow.tabBarController = tabBar
        if #available(iOS 17.0, *) {
            flow.tabBarController.traitOverrides.userInterfaceIdiom = UIUserInterfaceIdiom.phone
        }

        window.tintColor = Color.selection.toUIColor
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
        self.window = window

        configureGlobalAppearance()

        if isFirstLaunch() {
            createDemoTests()
            window.rootViewController?.showAlertOk(title: "Welcome", message: Texts.firstLaunch)
        }
    }

    // MARK: - Appearance

    private func configureGlobalAppearance() {
        let navAp = UINavigationBarAppearance()
        navAp.configureWithOpaqueBackground()
        navAp.backgroundColor = Color.navigation.toUIColor
        navAp.titleTextAttributes = [.foregroundColor: Color.selection.toUIColor]
        navAp.largeTitleTextAttributes = [.foregroundColor: Color.selection.toUIColor]

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = navAp
        navBar.scrollEdgeAppearance = navAp
        navBar.compactAppearance = navAp
        navBar.tintColor = Color.selection.toUIColor

        let tabAp = UITabBarAppearance()
        tabAp.configureWithOpaqueBackground()
        tabAp.backgroundColor = Color.navigation.toUIColor

        let selected = Color.selection.toUIColor
        let unselected = UIColor.systemGray

        tabAp.stackedLayoutAppearance.selected.iconColor = selected
        tabAp.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]
        tabAp.stackedLayoutAppearance.normal.iconColor = unselected
        tabAp.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselected]

        tabAp.inlineLayoutAppearance = tabAp.stackedLayoutAppearance
        tabAp.compactInlineLayoutAppearance = tabAp.stackedLayoutAppearance

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = tabAp
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabAp
        } 
        tabBar.tintColor = selected
        tabBar.unselectedItemTintColor = unselected
    }

    // MARK: - First Launch helpers

    private func isFirstLaunch() -> Bool {
        let key = "HasLaunched"
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
        return false
    }

    private func createDemoTests() {
        loadJson(fileName: "motionDiscriminationDemo")
        loadJson(fileName: "contrastDiscriminationDemo")
        loadJson(fileName: "soundDiscriminationDemo")
    }

    private func loadJson(fileName: String) {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return }
        _ = Flow.shared.createAndSaveNewTest(from: data)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        importFile(url)
    }

    @objc private func importFile(_ url: URL) {
        do {
            _ = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }
            let data = try Data(contentsOf: url)
            if Flow.shared.createAndSaveNewTest(from: data) {
                window?.rootViewController?.showAlertOk(title: "Test imported",
                                                        message: "The test was imported successfully.")
            } else {
                window?.rootViewController?.showAlertOk(title: "Error",
                                                        message: "Unable to load data.")
            }
        } catch {
            window?.rootViewController?.showAlertOk(title: "Error",
                                                    message: "Unable to load data: \(error)")
        }
    }
}
