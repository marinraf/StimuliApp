//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import SafariServices

class MainViewController: UIViewController {

    @IBAction func infoButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://stimuliapp.com") else { return }

        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    @IBAction func privacyButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.stimuliapp.com/privacy-policy/") else { return }

        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }

    @IBAction func brainButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://braincircuitsbehavior.org") else { return }

        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }

    var main: Main
    var button = UIButton()

    init() {
        self.main = Flow.shared.screen as? Main ?? Main()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background.toUIColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.backgroundColor = Color.navigation.toUIColor
        self.tabBarController?.tabBar.isHidden = false

        if !Flow.shared.tabBarIsMenu {
            Flow.shared.initTabControllerMenu()
            Flow.shared.tabBarIsMenu = true
        }

        main.setting()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
