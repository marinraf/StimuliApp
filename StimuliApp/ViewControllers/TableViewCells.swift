//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class MainTableViewCell: UITableViewCell {}

class MenuTableViewCell: UITableViewCell {

    weak var delegate: MenuTableViewCellDelegate?

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    @IBAction func infoButtonPressed(_ sender: UIButton) {
        delegate?.didTapButton(sender)
    }

    @IBAction func segmentedControlSelected(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        delegate?.didSelectSegment(sender, index: index)
    }
}

class SelectTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

protocol MenuTableViewCellDelegate: class {
    func didTapButton(_ sender: UIButton)
    func didSelectSegment(_ sender: UISegmentedControl, index: Int)
}
