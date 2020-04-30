import UIKit
import GameKit

let numberx = 10

let xmin = 0
let xmax = 3
let ymin = 0
let ymax = 2

let aa = (xmin ... xmax).flatMap({ x in
    (ymin ... ymax).map({ y in
        x + y * numberx })})

print(aa)

