import UIKit
import GameKit

extension Int {
    static func random(seed: UInt64, minimum: Int, maximum: Int) -> Int {
        let source = GKMersenneTwisterRandomSource(seed: seed)

        let randomDistribution = GKRandomDistribution(randomSource: source, lowestValue: minimum, highestValue: maximum)
        return randomDistribution.nextInt()
    }
}

let a = Int.random(seed: 956, minimum: 0, maximum: 3)

print(a)

