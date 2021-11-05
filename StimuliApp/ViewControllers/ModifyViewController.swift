//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class ModifyViewController: UIViewController {

    @IBOutlet weak var groupTitleView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var separatorTitleView: UIView!
    @IBOutlet weak var propertyAndUnitInfo: UITextView!
    @IBOutlet weak var extraInfo: UITextView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeTitleLabel: UILabel!
    @IBOutlet weak var unitTitleLabel: UILabel!
    @IBOutlet weak var extraTitleLabel: UILabel!
    @IBOutlet weak var valueTitleLabel: UILabel!

    @IBOutlet weak var textFieldSimple: UITextField!

    @IBOutlet weak var textFieldDoble1: UITextField!
    @IBOutlet weak var textFieldDoble2: UITextField!

    @IBOutlet weak var textFieldTriple1: UITextField!
    @IBOutlet weak var textFieldTriple2: UITextField!
    @IBOutlet weak var textFieldTriple3: UITextField!

    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var unitView: UIView!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var extraView: UIView!

    @IBOutlet weak var typeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unitViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var extraViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var unitSegControl: UISegmentedControl!
    @IBAction func unitSegControlSelected(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if modify.propertyType == .finalFloat {
            unitSegControlSelectForFinalFloat(index: index)
        } else {
            unitSegControlSelect(index: index)
        }
    }

    @IBOutlet weak var typeSegControl: UISegmentedControl!
    @IBAction func typeSegControlSelected(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        typeSegControlSelect(index: index)
    }

    @IBOutlet weak var extraSegControl: UISegmentedControl!
    @IBAction func extraSegControlSelected(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if modify.propertyType == .type {
            stimulusTypeSegControlSelect(index: index)
        } else if modify.propertyType == .response {
            sceneResponseSegControlSelect(index: index)
        } else {
            timeFunctionSegControlSelect(index: index)
        }    }

    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var okButton: UIButton!

    @IBAction func okButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        save()
    }

    var modify: Modify
    var responses: [String] = []

    init() {
        self.modify = Flow.shared.screen as? Modify ?? Modify()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.background.toUIColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        groupTitleView.backgroundColor = Color.navigation.toUIColor
        separatorTitleView.backgroundColor = Color.separatorArrow.toUIColor
        registerNotifications()
        setting()
        self.tabBarController?.tabBar.isHidden = true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotifications()
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }

    private func setting() {
        configureTypeView()
        configureUnitView()
        configureValueView()
        configureExtraView()

        configurePlaceholders()

        responses = [String(modify.float0), String(modify.float1), String(modify.float2)]
        //back button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "< Cancel",
                                            style: .done,
                                            target: self,
                                            action: #selector(goBack))
        newBackButton.tintColor = Color.selection.toUIColor
        newBackButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ], for: .normal)
        self.navigationItem.leftBarButtonItem = newBackButton

        //must be last
        configureTitleAndTextFields()
    }

    @objc private func goBack() {
        Flow.shared.navigateBack()
    }

    private func configureTitleAndTextFields() {
        textFieldSimple.backgroundColor = Color.textField.toUIColor
        textFieldDoble1.backgroundColor = Color.textField.toUIColor
        textFieldDoble2.backgroundColor = Color.textField.toUIColor
        textFieldTriple1.backgroundColor = Color.textField.toUIColor
        textFieldTriple2.backgroundColor = Color.textField.toUIColor
        textFieldTriple3.backgroundColor = Color.textField.toUIColor

        textFieldSimple.textColor = Color.darkText.toUIColor
        textFieldDoble1.textColor = Color.darkText.toUIColor
        textFieldDoble2.textColor = Color.darkText.toUIColor
        textFieldTriple1.textColor = Color.darkText.toUIColor
        textFieldTriple2.textColor = Color.darkText.toUIColor
        textFieldTriple3.textColor = Color.darkText.toUIColor

        switch modify.propertyType {
        case .doblePosition, .dobleSize, .trialAccuracy:
            textFieldSimple.isHidden = true
            textFieldDoble1.isHidden = false
            textFieldDoble2.isHidden = false
            textFieldTriple1.isHidden = true
            textFieldTriple2.isHidden = true
            textFieldTriple3.isHidden = true
            if Flow.shared.settings.device.type == .mac  {
                textFieldDoble1.becomeFirstResponder()
            }
        case .triple, .sequence:
            textFieldSimple.isHidden = true
            textFieldDoble1.isHidden = true
            textFieldDoble2.isHidden = true
            textFieldTriple1.isHidden = false
            textFieldTriple2.isHidden = false
            textFieldTriple3.isHidden = false
            if Flow.shared.settings.device.type == .mac  {
                textFieldTriple1.becomeFirstResponder()
            }
        default:
            textFieldSimple.isHidden = false
            textFieldDoble1.isHidden = true
            textFieldDoble2.isHidden = true
            textFieldTriple1.isHidden = true
            textFieldTriple2.isHidden = true
            textFieldTriple3.isHidden = true
            if Flow.shared.settings.device.type == .mac  {
                textFieldSimple.becomeFirstResponder()
            }
        }
        titleLabel.text = modify.title
    }

    private func configureTypeView() {
        if modify.timeDependency == .alwaysConstant {
            typeView.isHidden = true
            typeViewHeightConstraint.constant = 0
        } else {
            typeTitleLabel.text = "Value type:"
            configureTypeSegControl()
        }
    }

    private func configureUnitView() {
        if modify.numberKeyboard {
            unitTitleLabel.text = "Unit:"
            if modify.propertyType == .finalFloat {
                configureUnitSegControlForFinalFloat()
            } else {
                configureUnitSegControl()
            }
        } else if modify.propertyType == .type || modify.propertyType == .response {
            unitTitleLabel.text = ""
            unitView.isHidden = false
            unitSegControl.removeAllSegments()
        } else {
            unitView.isHidden = true
            unitViewHeightConstraint.constant = 0
        }
        propertyAndUnitInfo.text = modify.info
    }

    private func configurePlaceholders() {
        modify.settingPlaceholders()
        responses = [String(modify.float0), String(modify.float1), String(modify.float2)]
        textFieldSimple.placeholder = modify.placeholders[0]
        textFieldDoble1.placeholder = modify.placeholders[0]
        textFieldDoble2.placeholder = modify.placeholders[1]
        textFieldTriple1.placeholder = modify.placeholders[0]
        textFieldTriple2.placeholder = modify.placeholders[1]
        textFieldTriple3.placeholder = modify.placeholders[2]
    }

    private func configureValueView() {
        guard modify.propertyType != .type && modify.propertyType != .response else {
            valueView.isHidden = true
            valueViewHeightConstraint.constant = 0
            return
        }
        switch modify.timeDependency {
        case .constant, .alwaysConstant:
            valueView.isHidden = false
            valueViewHeightConstraint.constant = 60
            if modify.propertyType == .string || modify.propertyType == .image {
                valueTitleLabel.text = ""
            } else {
                valueTitleLabel.text = "Value:"
            }
        case .variable, .timeDependent:
            valueView.isHidden = true
            valueViewHeightConstraint.constant = 0
        }
    }

    private func configureExtraView() {
        switch modify.timeDependency {
        case .constant, .alwaysConstant, .variable:
            if modify.propertyType == .type {
                extraView.isHidden = false
                extraViewHeightConstraint.constant = 310
                image.isHidden = false
                image.image = UIImage(named: StimuliType.allCases[modify.selectedValue].name)
                configureStimuliTypeSegControl()
                modify.settingInfo()
                extraInfo.text = modify.extraInfo
                extraInfo.layoutIfNeeded()
                extraInfo.updateTextFont(expectFont: UIFont.systemFont(ofSize: 17))
                extraTitleLabel.text = "Stimulus type:"
            } else if modify.propertyType == .response {
                extraView.isHidden = false
                extraViewHeightConstraint.constant = 310
                image.isHidden = false
                image.image = UIImage(named: FixedResponse.allCases[modify.selectedValue].name)
                configureSceneResponseSegControl()
                modify.settingInfo()
                extraInfo.text = modify.extraInfo
                extraInfo.layoutIfNeeded()
                extraInfo.updateTextFont(expectFont: UIFont.systemFont(ofSize: 17))
                extraTitleLabel.text = "Scene response:"
            } else if modify.propertyType == .image {
                extraView.isHidden = true
                image.isHidden = true
                extraViewHeightConstraint.constant = 0
            } else {
                extraView.isHidden = true
                image.isHidden = true
                extraViewHeightConstraint.constant = 0
            }
        case .timeDependent:
            extraView.isHidden = false
            extraViewHeightConstraint.constant = 310
            image.isHidden = false
            image.image = UIImage(named: modify.timeFunction.name)
            configureTimeFunctionSegControl()
            modify.settingInfo()
            extraInfo.text = modify.extraInfo
            extraInfo.layoutIfNeeded()
            extraInfo.updateTextFont(expectFont: UIFont.systemFont(ofSize: 17))
            extraTitleLabel.text = "Time dependency:"
        }
    }

    private func configureUnitSegControl() {
        unitSegControl.removeAllSegments()
        for (index, element) in modify.unitType.possibleUnits.enumerated() {
            if element == .none {
                unitSegControl.insertSegment(withTitle: modify.unitType.name,
                                             at: index,
                                             animated: false)
            } else {
                unitSegControl.insertSegment(withTitle: element.name, at: index, animated: false)
            }
        }
        if let selected = modify.unitType.possibleUnits.firstIndex(where: { $0 == modify.unit }) {
            unitSegControl.selectedSegmentIndex = selected
        }
        unitSegControl.setWidthToSegmentControl()
    }

    private func configureUnitSegControlForFinalFloat() {
        unitSegControl.removeAllSegments()

        if modify.timeExponent != 0 {
            var title1 = modify.property.si(modify.unit, .second)
            let title2 = modify.property.si(modify.unit, .frame)
            if title1 == "s" {
                title1 = "seconds"
            }
            unitSegControl.insertSegment(withTitle: title1, at: 0, animated: false)
            unitSegControl.insertSegment(withTitle: title2, at: 1, animated: false)

            if modify.property.timeUnit == .frame {
                unitSegControl.selectedSegmentIndex = 1
            } else {
                unitSegControl.selectedSegmentIndex = 0
            }
        } else if modify.unitType == .time {
            for (index, element) in modify.unitType.possibleUnits.enumerated() {
                if element == .none {
                    unitSegControl.insertSegment(withTitle: modify.unitType.name,
                                                 at: index,
                                                 animated: false)
                } else {
                    unitSegControl.insertSegment(withTitle: element.name, at: index, animated: false)
                }
            }
            if let selected = modify.unitType.possibleUnits.firstIndex(where: { $0 == modify.unit }) {
                unitSegControl.selectedSegmentIndex = selected
            }
        } else if modify.unitType == .angle {
            for (index, element) in modify.unitType.possibleUnits.enumerated() {
                if element == .none {
                    unitSegControl.insertSegment(withTitle: modify.unitType.name,
                                                 at: index,
                                                 animated: false)
                } else {
                    unitSegControl.insertSegment(withTitle: element.name, at: index, animated: false)
                }
            }
            if let selected = modify.unitType.possibleUnits.firstIndex(where: { $0 == modify.unit }) {
                unitSegControl.selectedSegmentIndex = selected
            }
        } else {
            if modify.unit == .none {
                unitSegControl.insertSegment(withTitle: modify.unitType.name, at: 0, animated: false)
            } else {
                unitSegControl.insertSegment(withTitle: modify.unit.name, at: 0, animated: false)
            }
            unitSegControl.selectedSegmentIndex = 0
        }

        unitSegControl.setWidthToSegmentControl()
    }

    private func configureTypeSegControl() {
        typeSegControl.removeAllSegments()
        let timeDependencies = modify.propertyType.timeDependencies
        for (index, element) in timeDependencies.enumerated() {
            typeSegControl.insertSegment(withTitle: element.name,
                                             at: index,
                                             animated: false)
        }
        if let selected = timeDependencies.firstIndex(where: { $0 == modify.timeDependency }) {
            typeSegControl.selectedSegmentIndex = selected
        }
        typeSegControl.setWidthToSegmentControl()
    }

    private func configureTimeFunctionSegControl() {
        extraSegControl.removeAllSegments()
        let timeFunctions = TimeFunctions.allCases
        for (index, element) in timeFunctions.enumerated() {
            extraSegControl.insertSegment(withTitle: element.name,
                                             at: index,
                                             animated: false)
        }
        if let selected = timeFunctions.firstIndex(where: { $0 == modify.timeFunction }) {
            extraSegControl.selectedSegmentIndex = selected
        }
        extraSegControl.setWidthToSegmentControl()
    }

    private func configureStimuliTypeSegControl() {
        extraSegControl.removeAllSegments()
        let stimulusTypes = StimuliType.allCases
        for (index, element) in stimulusTypes.enumerated() {
            extraSegControl.insertSegment(withTitle: element.name,
                                                 at: index,
                                                 animated: false)
        }
        if extraSegControl.numberOfSegments > modify.selectedValue {
            extraSegControl.selectedSegmentIndex = modify.selectedValue
        }
        extraSegControl.setWidthToSegmentControl()
    }

    private func configureSceneResponseSegControl() {
        extraSegControl.removeAllSegments()
        let responses = FixedResponse.allCases
        for (index, element) in responses.enumerated() {
            extraSegControl.insertSegment(withTitle: element.name,
                                          at: index,
                                          animated: false)
        }
        if extraSegControl.numberOfSegments > modify.selectedValue {
            extraSegControl.selectedSegmentIndex = modify.selectedValue
        }
        extraSegControl.setWidthToSegmentControl()
    }

    private func unitSegControlSelect(index: Int) {
        modify.unit = modify.unitType.possibleUnits[index]
        modify.settingInfo()
        propertyAndUnitInfo.text = modify.info
        configurePlaceholders()
    }

    private func unitSegControlSelectForFinalFloat(index: Int) {
        if modify.timeExponent != 0 {
            modify.timeUnit = index == 1 ? .frame : .second
        } else {
            modify.unit = modify.unitType.possibleUnits[index]
        }
        modify.settingInfo()
        propertyAndUnitInfo.text = modify.info
        configurePlaceholders()
    }

    private func typeSegControlSelect(index: Int) {
        modify.timeDependency = modify.propertyType.timeDependencies[index]
        modify.settingInfo()
        propertyAndUnitInfo.text = modify.info
        configurePlaceholders()
        configureValueView()
        configureExtraView()
    }

    private func stimulusTypeSegControlSelect(index: Int) {
        modify.selectedValue = index
        modify.settingInfo()
        extraInfo.text = modify.extraInfo
        extraInfo.updateTextFont(expectFont: UIFont.systemFont(ofSize: 17))
        propertyAndUnitInfo.text = modify.info
        image.image = UIImage(named: StimuliType.allCases[modify.selectedValue].name)
    }

    private func sceneResponseSegControlSelect(index: Int) {
        modify.selectedValue = index
        modify.settingInfo()
        extraInfo.text = modify.extraInfo
        extraInfo.updateTextFont(expectFont: UIFont.systemFont(ofSize: 17))
        propertyAndUnitInfo.text = modify.info
        image.image = UIImage(named: FixedResponse.allCases[modify.selectedValue].name)
    }

    private func timeFunctionSegControlSelect(index: Int) {
        modify.timeFunction = TimeFunctions.allCases[index]
        modify.settingInfo()
        extraInfo.text = modify.extraInfo
        extraInfo.updateTextFont(expectFont: UIFont.systemFont(ofSize: 17))
        propertyAndUnitInfo.text = modify.info
        image.image = UIImage(named: modify.timeFunction.name)
    }
}

extension ModifyViewController: UITextFieldDelegate {

    //touching return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == textFieldDoble1 {
            textFieldDoble2.becomeFirstResponder()
        } else if textField == textFieldTriple1 {
            textFieldTriple2.becomeFirstResponder()
        } else if textField == textFieldTriple2 {
            textFieldTriple3.becomeFirstResponder()
        } else if modify.isSeed {
            textField.text = ""
            save()
        } else {
            textField.resignFirstResponder()
            save()
        }
        return true
    }

    //start editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textField.keyboardType = modify.numberKeyboard ? .numbersAndPunctuation : .default
    }

    //finish editing
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let response = textField.text else { return false }

        if textField == textFieldSimple {
            responses[0] = response
        } else if textField == textFieldDoble1 || textField == textFieldTriple1 {
            if response != "" {
                responses[0] = response
            }
        } else if textField == textFieldDoble2 || textField == textFieldTriple2 {
            if response != "" {
                responses[1] = response
            }
        } else if textField == textFieldTriple3 {
            if response != "" {
                responses[2] = response
            }
        }

        return true
    }

    func save() {
        let result = modify.save(responses: responses)

        switch result {
        case .invalid, .saved:
            Flow.shared.navigateBack()
        case .used:
            showAlertOk(title: modify.alertTitle, message: modify.alertMessage)
            textFieldSimple.text = ""
        case .again:
            configureTitleAndTextFields()
            configurePlaceholders()
            textFieldSimple.text = ""
            textFieldSimple.becomeFirstResponder()
        case .seed:
            if Task.shared.error == "" {
                Flow.shared.navigate(to: Display())
            } else {
                Flow.shared.navigate(to: InfoExport(type: .previewErrorStimulusOrTest))
            }
        }
    }
}
