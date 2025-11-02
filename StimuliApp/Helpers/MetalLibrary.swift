//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

struct MetalLibrary {

    static let compute = ["compute1Layer",
                          "compute2Layers",
                          "compute3Layers",
                          "compute1LayerContinuous",
                          "compute2LayersContinuous",
                          "compute3LayersContinuous"]

    static let stimuli = StimuliType.allCases.filter({ $0.metal }).map({ $0.name })
}
