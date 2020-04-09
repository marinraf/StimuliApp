//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var flow = Flow.shared

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let mainScreen = Main()
        flow.screen = mainScreen
        flow.tabBarController = NavigationControllerTab()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.tintColor = Color.selection.toUIColor
        window?.rootViewController = flow.tabBarController
        window?.makeKeyAndVisible()

        UINavigationBar.appearance().barTintColor = Color.navigation.toUIColor
        UINavigationBar.appearance().tintColor = Color.selection.toUIColor
        UINavigationBar.appearance().isTranslucent = false

        return true
    }

    // set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    @objc func importFile(_ url: URL) {
        do {
            _ = url.startAccessingSecurityScopedResource()
            let data = try Data(contentsOf: url)
            _ = url.stopAccessingSecurityScopedResource()
            if Flow.shared.createAndSaveNewTest(from: data) {
                self.window?.rootViewController?.showAlertOk(title: "Test imported",
                                                             message: "The test was imported successfully.")
            } else {
                self.window?.rootViewController?.showAlertOk(title: "Error", message: "Unable to load data.")
            }
        } catch {
            self.window?.rootViewController?.showAlertOk(title: "Error", message: "Unable to load data: \(error)")
        }
    }


    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        importFile(url)
        return true
    }


    #if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
            super.buildMenu(with: builder)

            builder.remove(menu: .services)
            builder.remove(menu: .format)
            builder.remove(menu: .toolbar)
    }
    #endif
}
