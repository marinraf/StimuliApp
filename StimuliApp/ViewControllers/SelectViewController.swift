//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class SelectViewController: UIViewController {

    @IBOutlet weak var groupTitleView: UIView!
    @IBOutlet weak var separatorTitleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!

    var menu: Menu

    init() {
        self.menu = Flow.shared.screen as? Menu ?? Menu(title: "")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.background.toUIColor
        settingCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        groupTitleView.backgroundColor = Color.navigation.toUIColor
        separatorTitleView.backgroundColor = Color.separatorArrow.toUIColor
        setting()
        self.tabBarController?.tabBar.isHidden = true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func setting() {
        menu.setting()

        titleLabel.text = menu.sections[0].title
        if menu.title2 == "" {
            infoTextView.isHidden = true
        } else {
            infoTextView.isHidden = false
            infoTextView.text = menu.title2

        }
        settingTableView()

        //back button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "< Back",
                                            style: .done,
                                            target: self,
                                            action: #selector(goBack))
        newBackButton.tintColor = Color.selection.toUIColor
        newBackButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ], for: .normal)
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @objc private func goBack() {
        Flow.shared.navigateBack()
    }
}

extension SelectViewController: UITableViewDelegate, UITableViewDataSource {

    //setting cell
    private func settingCell() {
        let nib = UINib.init(nibName: FileNames.selectCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FileNames.selectCell)
    }

    //setting table
    private func settingTableView() {
        tableView.backgroundColor = Color.background.toUIColor
        tableView.separatorColor = Color.background.toUIColor
        tableView.reloadData()
    }

    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu.numberOfSections
    }

    //number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.numberOfRows(inSection: section)
    }

    //cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = menu.option(at: indexPath)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: FileNames.selectCell, for: indexPath)
            as? SelectTableViewCell else { return UITableViewCell() }

        cell.backgroundColor = Color.defaultCell.toUIColor

        cell.title?.adjustsFontSizeToFitWidth = true
        cell.title?.text = option.name
        if option.style == .insert {
            cell.title?.textColor = Color.selection.toUIColor
        } else if option.style == .onlyInfo {
            cell.title?.textColor = Color.lightText.toUIColor
        } else {
            cell.title?.textColor = Color.darkText.toUIColor
        }

        return cell
    }

    //select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = menu.option(at: indexPath)
        if let nextScreen = option.nextScreen() {
            Flow.shared.navigate(to: nextScreen)
        } else {
            Flow.shared.navigateBack()
        }
    }
}
