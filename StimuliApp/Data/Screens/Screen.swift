//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

protocol Screen {
    var style: ScreenStyle { get }
}

class EmptyScreen: Screen {
    var style: ScreenStyle = .main
}

enum ScreenStyle {
    case main
    case menu
    case modify
    case infoExport
    case content
    case display
    case displayPreview
    case select
    case calibration
}
