//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var previewButton: UIButton!
    @IBAction func previewButtonPressed(_ sender: Any) {
        preview()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorTitleView: UIView!
    @IBOutlet weak var groupTitleView: UIView!

    var menu: Menu

    init(screen: Screen = Flow.shared.screen) {
        self.menu = screen as? Menu ?? Menu(title: "")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.background.toUIColor
        setupLongPressRecognizer()
        settingCell()

        // Auto resizing the height of the cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.backgroundColor = Color.navigation.toUIColor
        groupTitleView.backgroundColor = Color.navigation.toUIColor
        separatorTitleView.backgroundColor = Color.separatorArrow.toUIColor
        self.tableView.contentInset.bottom = 150
        setting()
        self.tabBarController?.tabBar.isHidden = false
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func setting() {
        menu.setting()

        if menu.title2 != "" {
            let attrs = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 30)]
            let attributedString = NSMutableAttributedString(string: menu.title2, attributes: attrs)
            let normalString = NSMutableAttributedString(string: menu.title + ":  ")
            normalString.append(attributedString)
            titleLabel.attributedText = normalString
        } else {
            titleLabel.text = menu.title
        }
        self.previewButton.isHidden = menu.previewButtonHidden
        if menu.buttonImage != "" {
            self.previewButton.setImage(UIImage(named: menu.buttonImage), for: .normal)
        }

        //edit button
        let editButton = UIBarButtonItem(title: "Edit",
                                         style: .plain,
                                         target: self,
                                         action: #selector(toggleEditing))
        editButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)],
                                          for: .normal)
        editButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 0)],
                                          for: .disabled)

        editButton.tintColor = Color.selection.toUIColor
        if menu.export {
            editButton.title = "Export test >"
            editButton.action = #selector(infoExport)
        }
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.rightBarButtonItem?.isEnabled = menu.isEditable

        //back button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: menu.backButton,
                                            style: .done,
                                            target: self,
                                            action: #selector(goBack))
        newBackButton.tintColor = Color.selection.toUIColor
        newBackButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ], for: .normal)
        self.navigationItem.leftBarButtonItem = newBackButton

        settingTableView()
    }

    @objc private func goBack() {
        Flow.shared.navigateBack()
    }

    @objc private func toggleEditing() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = self.tableView.isEditing ? "Done" : "Edit"
    }

    @objc private func infoExport() {
        Flow.shared.navigate(to: InfoExport(type: .exportTest))
    }

    private func preview() {
        if menu.buttonImage == "preview test" {
            Task.shared.reset()
            Task.shared.error = Task.shared.createTask(test: Flow.shared.test, preview: .previewTest)
            if Task.shared.error == "" {
                Flow.shared.navigate(to: Display())
            } else {
                Flow.shared.navigate(to: InfoExport(type: .previewErrorStimulusOrTest))
            }
        } else if menu.buttonImage == "preview scene" {
            Task.shared.reset()
            Task.shared.error = Task.shared.createTask(section: Flow.shared.section,
                                                       scene: Flow.shared.scene,
                                                       test: Flow.shared.test)
            if Task.shared.error == "" {
                Flow.shared.navigate(to: DisplayPreview())
            } else {
                Flow.shared.navigate(to: InfoExport(type: .previewErrorStimulusOrTest))
            }
        } else if menu.buttonImage == "preview stimulus" {
            Task.shared.reset()
            Task.shared.error = Task.shared.createTask(stimulus: Flow.shared.stimulus)
            if Task.shared.error == "" {
                Flow.shared.navigate(to: Display())
            } else {
                Flow.shared.navigate(to: InfoExport(type: .previewErrorStimulusOrTest))
            }
        } else if menu.buttonImage == "preview variables" {
            Task.shared.reset()
            Task.shared.error = Task.shared.createSection(section: Flow.shared.section, test: Flow.shared.test)
            if Task.shared.error == "" {
                Flow.shared.navigate(to: InfoExport(type: .previewVariables))
            } else {
                Flow.shared.navigate(to: InfoExport(type: .previewErrorStimulusOrTest))
            }
        }
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {

    //setting cell
    private func settingCell() {
        let nib = UINib.init(nibName: FileNames.menuCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FileNames.menuCell)
    }

    //setting table
    private func settingTableView() {
        tableView.backgroundColor = Color.background.toUIColor
        tableView.separatorColor = Color.separatorArrow.toUIColor
        tableView.reloadData()
    }

    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return menu.numberOfSections
    }

    //header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
            as? MenuTableViewHeader ?? MenuTableViewHeader(reuseIdentifier: "header")

        header.titleLabel.text = menu.title(forSection: section)

        header.titleLabel.textColor = Color.darkText.toUIColor

        drawArrowHeader(section, header)

        header.section = section
        header.delegate = self

        return header
    }

    //header arrow
    private func drawArrowHeader(_ section: Int, _ header: MenuTableViewHeader) {
        if menu.title(forSection: section) == "" {
            header.arrowLabel.text = ""
        } else if menu.sections[section].collapsed {
            header.arrowLabel.text = ">"
        } else {
            header.arrowLabel.text = "..."
        }
    }

    //row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 //to silence a warning
    }

    //size header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        } else if menu.title(forSection: section) == "" {
            return CGFloat.leastNormalMagnitude
        } else {
            return 60
        }
    }

    //size footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    //number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menu.sections[section].collapsed {
            return 0
        } else {
            return menu.numberOfRows(inSection: section)
        }
    }

    //cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = menu.option(at: indexPath)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: FileNames.menuCell, for: indexPath)
            as? MenuTableViewCell else { return UITableViewCell() }

        cell.delegate = self

        cell.segmentedControl.removeAllSegments()

        var title = ""
        for _ in 0 ..< option.position {
            title.append("        ")
        }
        if option.style == .insert {
            title.append("        ")
        }
        cell.title.text = title + option.name
        cell.detail.text = option.detail
        cell.separatorView?.backgroundColor = Color.background.toUIColor

        if indexPath.section == menu.sections.count - 1 {
            if indexPath.row == menu.sections[indexPath.section].numberOfRows - 1 {
                cell.separatorView.isHidden = true
            } else {
                cell.separatorView.isHidden = false
            }
        } else if menu.sections[indexPath.section + 1].title != "" &&
            indexPath.row == menu.sections[indexPath.section].numberOfRows - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }

        switch option.style {
        case .insert: //info,arrow,blue,italic
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.selection.toUIColor
            cell.title.font = UIFont.italicSystemFont(ofSize: 16)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .optional: //info,arrow,blue,edit
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.selection.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .runTest: //info,arrow,blue
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.selection.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .optionalInfo: //info,arrow,black,edit
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.darkText.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .standard: //info,arrow,black
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.darkText.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .onlyInfo: //info,noarrow,gray
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .none
            cell.arrowLabel.isHidden = true
            cell.title.textColor = Color.lightText.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .onlySelect: //info,arrow,black,special
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.darkText.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .selectFromSegment: //info,noarrow,black,select
            configureSegmentedControl(for: cell, from: option)
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = false
            cell.selectionStyle = .none
            cell.arrowLabel.isHidden = true
            cell.title.textColor = Color.darkText.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.defaultCell.toUIColor
        case .highlight: //info,arrow,black,highlight
            cell.infoButton.isHidden = false
            cell.segmentedControl.isHidden = true
            cell.selectionStyle = .gray
            cell.arrowLabel.isHidden = false
            cell.title.textColor = Color.darkText.toUIColor
            cell.title.font = UIFont.boldSystemFont(ofSize: 17)
            cell.backgroundColor = Color.highlightCell.toUIColor
        }

        cell.detail.textColor = cell.title.textColor
        cell.arrowLabel.textColor = Color.separatorArrow.toUIColor

        cell.setWidthToSegmentControl()
        return cell
    }

    //select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let option = menu.option(at: indexPath)
        Flow.shared.navigate(to: option.nextScreen())
    }

    //can edit?
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let option = menu.option(at: indexPath)
        if option.style == .optional || option.style == .optionalInfo {
            return true
        } else {
            return false
        }
    }

    //edit style
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    //edit
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        let option = menu.option(at: indexPath)
        if option.deleteTexts.title != "" {
            showAlertDelete(title: option.deleteTexts.title, message: option.deleteTexts.message, action: { _ in
                self.delete(indexPath: indexPath)
            })
        } else {
            delete(indexPath: indexPath)
        }
    }

    //delete
    func delete(indexPath: IndexPath) {

        var rowsToDelete: [IndexPath] = [indexPath]
        let newRows = menu.deleteOption(at: indexPath)
        for element in newRows where !rowsToDelete.contains(where: { $0 == element }) {
            rowsToDelete.append(element)
        }

        var rows: [IndexPath] = []
        for element in rowsToDelete {
            let sectionToDelete = element.section
            if !menu.sections[sectionToDelete].collapsed {
                rows.append(element)
            }
        }
        tableView.deleteRows(at: rows, with: .fade)

        if tableView.numberOfRows(inSection: indexPath.section) == 0 {
            self.tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
        tableView.reloadData()
    }

    //duplicate
    func duplicate(indexPath: IndexPath) {
        var rowsToInsert: [IndexPath] = [indexPath]
        let newRows = menu.duplicateOption(at: indexPath)
        for element in newRows where !rowsToInsert.contains(where: { $0 == element }) {
            rowsToInsert.append(element)
        }

        var rows: [IndexPath] = []
        for element in rowsToInsert {
            let sectionToInsert = element.section
            if !menu.sections[sectionToInsert].collapsed {
                rows.append(element)
            }
        }
        tableView.insertRows(at: rows, with: .fade)
        tableView.reloadData()
    }

    //can move?
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let option = menu.option(at: indexPath)
        if option.style == .optional {
            return true
        } else {
            return false
        }
    }

    //move style
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {

        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        } else {
            return proposedDestinationIndexPath
        }
    }

    //move
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let first = sourceIndexPath.row
        let second = destinationIndexPath.row
        if first != second {
            if menu.secondMoveSection == sourceIndexPath.section {
                menu.move2(first, to: second)
            } else {
                menu.move(first, to: second)
            }
        }
        tableView.reloadData()
    }

    //long press on cell
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let option = menu.option(at: indexPath)
                if option.canDuplicate {
                    showAlertDuplicate(action: { _ in
                        self.duplicate(indexPath: indexPath)
                    })
                }
            }
        }
    }
}

extension MenuViewController: MenuTableViewCellDelegate {

    func didTapButton(_ sender: UIButton) {
        if let indexPath = getCurrentCellIndexPath(sender) {
            let option = menu.option(at: indexPath)
            if option.style == .optional && option.canDuplicate {
                self.showAlertOk(title: option.infoTitle,
                                 message: Texts.optionalAndDuplicatingElements + "\n\n" + option.infoMessage)
            } else if option.style == .optional {
                self.showAlertOk(title: option.infoTitle,
                                 message: Texts.optionalElements + "\n\n" + option.infoMessage)
            } else {
                self.showAlertOk(title: option.infoTitle,
                                 message: option.infoMessage)
            }
        }
    }

    func didSelectSegment(_ sender: UISegmentedControl, index: Int) {
        if let indexPath = getCurrentCellIndexPath(sender) {
            let option = menu.option(at: indexPath)
            option.segments[index].action()
        }
        setting()
    }

    private func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }

    private func getCurrentCellIndexPath(_ sender: UISegmentedControl) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }

    private func configureSegmentedControl(for cell: MenuTableViewCell, from option: Menu.Option) {
        cell.segmentedControl.removeAllSegments()
        for (index, element) in option.segments.enumerated() {
            cell.segmentedControl.insertSegment(withTitle: element.title, at: index, animated: false)
        }
        cell.segmentedControl.selectedSegmentIndex = option.selectedSegment
    }
}

extension MenuViewController: MenuTableViewHeaderDelegate {
    func toggleSection(_ header: MenuTableViewHeader, section: Int) {

        menu.sections[section].toggleCollapse()
        drawArrowHeader(section, header)

        var sectionFinal = section

        if menu.title(forSection: section + 1) == "" && menu.sections.count > section + 1 {
            menu.sections[section + 1].toggleCollapse()
            drawArrowHeader(section + 1, header)
            sectionFinal = section + 1

            if menu.title(forSection: section + 2) == "" && menu.sections.count > section + 2 {
                menu.sections[section + 2].toggleCollapse()
                drawArrowHeader(section + 2, header)
                sectionFinal = section + 2
            }
        }

        tableView.reloadSections(IndexSet(section...sectionFinal), with: .none)
    }
}
