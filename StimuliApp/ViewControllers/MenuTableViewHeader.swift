//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

protocol MenuTableViewHeaderDelegate: class {
    func toggleSection(_ header: MenuTableViewHeader, section: Int)
}

class MenuTableViewHeader: UITableViewHeaderFooterView {

    weak var delegate: MenuTableViewHeaderDelegate?
    var section: Int = 0

    let titleLabel = UILabel()
    let arrowLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(MenuTableViewHeader.tapHeader(_:))))

        //content View
        contentView.backgroundColor = Color.background.toUIColor
        let marginGuide = contentView.layoutMarginsGuide

        //arrow label
        contentView.addSubview(arrowLabel)
        arrowLabel.textColor = Color.separatorArrow.toUIColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        arrowLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

        //title label
        contentView.addSubview(titleLabel)
        titleLabel.textColor = Color.darkText.toUIColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? MenuTableViewHeader else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
    }
}
