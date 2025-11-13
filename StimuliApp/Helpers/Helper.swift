//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import GameKit

struct Constants {
    static let version: Double = 2.0
    static let epsilon: Float = 0.00001
    static let minimumResolutionMac: Float = 800
    static let cmsInInch: Float = 2.54
    static let gamma: Float = 2.2
    static let inversGamma: Float = 0.45454545
    static let gammaPerBrightness: Double = 2.4 // when brightness is high the gamma fit is aprox 2.4 not 2.2
    static let rampTime: Float = 0.005
    static let distanceDegreeEqualCm: Float = 57.2943
    static let defaultDistanceCm: Float = 50
    static let radiansPerDegree: Float = Float.pi / 180
    static let defaultBrightness: Double = 0.8
    static let maxFractionDigits: Int = 5
    static let maxNumberOfMetalStimuli: Int = 20 //change in metal also
    static let maxNumberOfDots: Int = 100000
    static let maxNumberOfDotObjects: Int = 2
    static let maxNumberOfVideoObjects: Int = 1
    static let maxNumberOfAudioObjects: Int = 10 //number of audio objects in a scene
    static let maxNumberOfAudios: Int = 100 // number of audios in the list
    static let maxLengthSequence: Int = 10000
    static let maxNumberOfTrials: Int = 5000
    static let numberOfMetalFloats: Int = 55
    static let numberOfAudioFloats: Int = 63
    static let numberOfDotsFloats: Int = 4 //type, duration, positionX, positionY
    static let sceneZeroDuration: Int = 3 //in seconds
    static let sceneZeroDurationShort: Int = 2 //in seconds
    static let sceneSimpleDuration: Int = 1000 //in seconds
    static let bufferAudio: Double = 0.002 //in seconds (the value will be something similar not this exact value)
    static let delayAudio60: Double = 0.03333 //in seconds (to sync audio and video, corrected in settings)
    static let delayAudio120: Double = 0.01666 //in seconds (to sync audio and video, corrected in settings)

    static let eyeTrackerSamplingFrequency: Int = 20 // seeso can sample up to 30 Hz
    static let numberOfTrackingErrors: Int = 10 // more than that number of errors in a certain scene in certain trial triggers error

    static let separator = "\n\n\n******************************\n\n\n"

    static let metalViewTag = 100
    static let textViewTag = 200
    static let videoViewTag = 300
    static let controlViewTag = 400

    static let numberOfComputeKernels: Int = MetalLibrary.compute.count
    static let numberOfObjectKernels: Int = MetalLibrary.stimuli.count
}

struct BackGroundValues {
    static let timeInFrames = 4
    static let frameRate = 5
    static let randomSeed = 6
    static let randomSeedInitial = 7
    static let screenWidth = 8
    static let screenHeight = 9
    static let status = 12
}

struct MetalValues {

    static let type = 0
    static let imageTextVideoDots = 1
    static let shapeType = 21
    static let xSize = 22
    static let ySize = 23
    static let start = 24
    static let duration = 25
    static let xOrigin = 26
    static let yOrigin = 27
    static let xPosition = 28
    static let yPosition = 29
    static let xCenter = 30
    static let yCenter = 31
    static let rotation = 32
    static let borderType = 33
    static let borderDistance = 34
    static let borderThickness = 35
    static let borderColorRed = 36
    static let borderColorGreen = 37
    static let borderColorBlue = 38
    static let contrastType = 39
    static let contrastValue = 40
    static let contrastEnvelope = 41
    static let noiseType = 42
    static let noiseValue = 43
    static let noiseProp = 44
    static let noiseProp1 = 45
    static let noiseProp2 = 46
    static let noiseProp3 = 47
    static let noiseProp4 = 48
    static let noiseProp5 = 49
    static let modulatorType = 50
    static let modulatorAmplitude = 51
    static let modulatorPeriod = 52
    static let modulatorPhase = 53
    static let modulatorRotation = 54
}

struct AudioValues {
    static let changingTones = 0
    static let numberOfAudios = 1
    static let toneCounter = 2

}

enum Color {
    case background
    case separatorArrow
    case defaultCell
    case highlightCell
    case selection
    case lightText
    case navigation
    case navigationTab
    case darkText
    case textField
    
    var toUIColor: UIColor {
        switch self {
        case .separatorArrow: return UIColor.systemGray
        case .lightText: return UIColor.systemGray2
        case .background: return UIColor.systemGray3
        case .navigation: return UIColor.systemGray3
        case .defaultCell: return UIColor.systemGray4
        case .highlightCell: return UIColor.systemGray4
        case .navigationTab: return UIColor.systemGray6
        case .textField: return UIColor.systemGray6
        case .selection: return UIColor.systemBlue
        case .darkText: return UIColor.label
        }
    }
}

struct FileNames {
    static let mainCell = "MainTableViewCell"
    static let menuCell = "MenuTableViewCell"
    static let menuHeader = "MenuTableViewHeader"
    static let selectCell = "SelectTableViewCell"
}

// MARK: - Encoding and decoding
struct Encode {

    static func testToJsonString(test: Test) -> String? {
        guard let jsonData = testToJsonData(test: test) else { return nil }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
        return jsonString
    }

    static func testToJsonData(test: Test) -> Data? {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(test) else { return nil }
        return jsonData
    }

    static func jsonStringToTest(jsonString: String) -> Test? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        guard let test = jsonDataToTest(jsonData: jsonData) else { return nil }
        return test
    }

    static func jsonDataToTest(jsonData: Data) -> Test? {
        let jsonDecoder = JSONDecoder()
        guard let test = try? jsonDecoder.decode(Test.self, from: jsonData) else { return nil }
        return test
    }

    static func resultToJsonString(result: Result) -> String? {
        guard let jsonData = resultToJsonData(result: result) else { return nil }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
        return jsonString
    }

    static func resultToJsonData(result: Result) -> Data? {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(result) else { return nil }
        return jsonData
    }

    static func jsonStringToResult(jsonString: String) -> Result? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        guard let result = jsonDataToResult(jsonData: jsonData) else { return nil }
        return result
    }

    static func jsonDataToResult(jsonData: Data) -> Result? {
        let jsonDecoder = JSONDecoder()
        guard let result = try? jsonDecoder.decode(Result.self, from: jsonData) else { return nil }
        return result
    }
}

// MARK: - Capitalizing first letter
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    func prependingSymbol() -> String {
        return "_" + self
    }
}

// MARK: - Transform int to superindex or subindex
extension Int {
    func exponentiate() -> String {
        let powers: [String] = [
            "\u{2070}",
            "\u{00B9}",
            "\u{00B2}",
            "\u{00B3}",
            "\u{2074}",
            "\u{2075}",
            "\u{2076}",
            "\u{2077}",
            "\u{2078}",
            "\u{2079}"
        ]

        let digits = Array(String(self))
        var string = ""

        for d in digits {
            string.append("\(powers[Int(String(d))!])")
        }
        return string
    }

    func subExponentiate() -> String {
        let powers: [String] = [
            "\u{2080}",
            "\u{2081}",
            "\u{2082}",
            "\u{2083}",
            "\u{2084}",
            "\u{2085}",
            "\u{2086}",
            "\u{2087}",
            "\u{2088}",
            "\u{2089}"
        ]

        let digits = Array(String(self))
        var string = ""

        for d in digits {
            string.append("\(powers[Int(String(d))!])")
        }
        return string
    }
}

// MARK: - Get the Int
extension Float {
    var toInt: Int {
        let value = self
        return Int(roundf(value))
    }

    var toEvenUpInt: Int {
        let value = Int(ceilf(self))
        return value % 2 == 0 ? value : value + 1
    }
    
    var toString: String {
        if self.isNaN {
            return "NaN"
        } else {
            return String(format: "%.3f", self)
        }
    }
}

extension Double {
    
    var toString: String {
        if self.isNaN {
            return "NaN"
        } else {
            return String(format: "%.3f", self)
        }
    }
    
}



// MARK: - Resize label text
extension UIView {
    func setWidthToSegmentControl() {
        let subviews = self.subviews
        for subview in subviews {
            if subview is UILabel {
                let label: UILabel? = (subview as? UILabel)
                label?.adjustsFontSizeToFitWidth = true
                label?.minimumScaleFactor = 0.1
            } else {
                subview.setWidthToSegmentControl()
            }
        }
    }
}

// MARK: - Orientation for png
extension UIImage {
    var png: Data? {
        guard let flattened = flattened else { return nil }
        return flattened.pngData()
    }
    var flattened: UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UITextView {
    func updateTextFont(expectFont: UIFont) {

        guard !self.text.isEmpty && !self.bounds.size.equalTo(CGSize.zero) else { return }
        self.font = expectFont
        let textViewSize = self.frame.size
        let fixedWidth = textViewSize.width
        let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        var expectFont = expectFont

        if expectSize.height > textViewSize.height {
            while self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height {
                expectFont = expectFont.withSize(expectFont.pointSize - 1)
                self.font = expectFont
            }
        }
        self.font = expectFont
    }
}

// MARK: - Utilities
struct AppUtility {

    static func printTimeElapsedWhenRunningCode(title: String, operation: () -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s.")
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask,
                                andRotateTo rotateOrientation: UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

    // create a sequence limited to a maximum of 10000 values
    static func createSequenceArray(firstValue: Float, lastValue: Float, numberOfValues: Float) -> [Float] {
        let numberOfValuesInt = Int(abs(numberOfValues))
        guard numberOfValuesInt <= 10000 else { return [] }
        guard numberOfValuesInt > 1 else { return [firstValue] }
        var values: [Float] = Array(repeating: 0, count: numberOfValuesInt)
        let separation: Float = (lastValue - firstValue) / Float(numberOfValuesInt - 1)
        for i in 0 ..< numberOfValuesInt {
            values[i] = firstValue + separation * Float(i)
        }
        return values
    }

    // create a log sequence limited to a maximum of 10000 values
    static func createLogSequenceArray(firstValue: Float, lastValue: Float, numberOfValues: Float) -> [Float] {
        let numberOfValuesInt = Int(abs(numberOfValues))
        guard numberOfValuesInt <= 10000 else { return [] }
        guard numberOfValuesInt > 1 else { return [firstValue] }
        guard (lastValue > 0 && firstValue > 0) || (lastValue < 0 && firstValue < 0) else { return [] }
        var values: [Float] = Array(repeating: 0, count: numberOfValuesInt)
        let separation: Float = pow((lastValue / firstValue), (1 / Float(numberOfValuesInt - 1)))
        for i in 0 ..< numberOfValuesInt {
            values[i] = firstValue * pow(separation, Float(i))
        }
        return values
    }

    // reorder an array with an array of indices
    static func reorder<T>(_ array: [T], with order: [Int]) -> [T] {

        guard let min = order.min(), let max = order.max() else { return array }
        guard min >= 0 && max < array.count else { return array }

        var newArray: [T] = []
        for i in order {
            newArray.append(array[i])
        }

        return newArray
    }

    // transform coordinates
    static func cartesianToPolar(xPos: Float, yPos: Float) -> (Float, Float) {
        var angle: Float = 0
        if xPos == 0 && yPos >= 0 {
            angle = Float.pi / 2
        } else if xPos == 0 && yPos < 0 {
            angle = 3 * Float.pi / 2
        } else if xPos > 0 && yPos >= 0 {
            angle = atan(yPos / xPos)
        } else if xPos > 0 && yPos < 0 {
            angle = atan(yPos / xPos) + 2 * Float.pi
        } else if xPos < 0 {
            angle = atan(yPos / xPos) + Float.pi
        }
        let radius = sqrt(pow(xPos, 2) + pow(yPos, 2))
        return (radius, angle)
    }

    static func polarToCartesian(radius: Float, angle: Float) -> (Float, Float) {
        if radius <= 0 {
            return (0, 0)
        } else {
            return (radius * cos(angle), radius * sin(angle))
        }
    }

    // calculate distance
    static func calculateDistance(_ vector1: (Float, Float), _ vector2: (Float, Float)) -> Float {

        let newVector = (vector1.0 - vector2.0, vector1.1 - vector2.1)

        return sqrtf(newVector.0 * newVector.0 + newVector.1 * newVector.1)
    }

    static func calculateDistancePolar(_ vector1: (Float, Float), _ vector2: (Float, Float)) -> Float {

        let vector1C = polarToCartesian(radius: vector1.0, angle: vector1.1)
        let vector2C = polarToCartesian(radius: vector2.0, angle: vector2.1)

        let newVector = (vector1C.0 - vector2C.0, vector1C.1 - vector2C.1)

        return sqrtf(newVector.0 * newVector.0 + newVector.1 * newVector.1)
    }

    static func calculateDistanceAngle(_ angle1: Float, _ angle2: Float) -> Float {

        let dist = abs(angle1 - angle2)

        return min(dist, 360 - dist)
    }

    static func calculateDistance3d(_ vector1: (Float, Float, Float), _ vector2: (Float, Float, Float)) -> Float {

        let newVector = (vector1.0 - vector2.0, vector1.1 - vector2.1, vector1.2 - vector2.2)

        return sqrtf(newVector.0 * newVector.0 + newVector.1 * newVector.1 + newVector.2 * newVector.2)
    }

    static func createTexture(from image: UIImage?, device: MTLDevice) -> MTLTexture {
        guard let image = image, let cgImage = image.cgImage else {
            return createTexture(device: device, width: 1, height: 1)
        }
        #if targetEnvironment(simulator)
        return createTexture(device: device, width: 1, height: 1)
        #else
        let textureLoader = MTKTextureLoader(device: device)
        do {
            let textureOut = try textureLoader.newTexture(cgImage: cgImage, options: [:])
            return textureOut
        } catch {
            return createTexture(device: device, width: 1, height: 1)
        }
        #endif
    }

    static func createTexture(device: MTLDevice, width: Int, height: Int) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                         width: max(width, 1),
                                                                         height: max(height, 1),
                                                                         mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        let texture = device.makeTexture(descriptor: textureDescriptor)

        return texture!
    }
    
    
    static func transpose(matrix: [[Double]]) -> [[Double]] {
        let rowCount = matrix.count
        let colCount = matrix[0].count
        var transposed : [[Double]] = Array(repeating: Array(repeating: 0.0, count: rowCount), count: colCount)
        for rowPos in 0..<matrix.count {
            for colPos in 0..<matrix[0].count {
                transposed[colPos][rowPos] = matrix[rowPos][colPos]
            }
        }
        return transposed
    }
     
    static func multiply(firstMatrix A: [[Double]], secondMatrix B: [[Double]]) -> [[Double]] {
        let rowCount = A.count
        let colCount = B[0].count
        var product : [[Double]] = Array(repeating: Array(repeating: 0.0, count: colCount), count: rowCount)
        for rowPos in 0..<rowCount {
            for colPos in 0..<colCount {
                for i in 0..<B.count {
                    product[rowPos][colPos] += A[rowPos][i] * B[i][colPos]
                }
            }
        }
        return product
    }
     
    // gauss jordan inversion
    static func inverse(matrix: [[Double]]) -> [[Double]] {
        // augment matrix
        var matrix = matrix
        var idrow = Array(repeating: 0.0, count: matrix.count)
        idrow[0] = 1.0
        for row in 0..<matrix.count {
            matrix[row] += idrow
            idrow.insert(0.0, at:0)
            idrow.removeLast()
        }
        
        // partial pivot
        for row1 in 0..<matrix.count {
            for row2 in row1..<matrix.count {
                if abs(matrix[row1][row1]) < abs(matrix[row2][row2]) {
                    (matrix[row1],matrix[row2]) = (matrix[row2],matrix[row1])
                }
            }
        }
        
        // forward elimination
        for pivot in 0..<matrix.count {
            // multiply
            let arg = 1.0 / matrix[pivot][pivot]
            for col in pivot..<matrix[pivot].count {
                matrix[pivot][col] *= arg
            }
            
            // multiply-add
            for row in (pivot+1)..<matrix.count {
                let arg = matrix[row][pivot] / matrix[pivot][pivot]
                for col in pivot..<matrix[row].count {
                    matrix[row][col] -= arg * matrix[pivot][col]
                }
            }
        }
        
        // backward elimination
        for pivot in (0..<matrix.count).reversed() {
            // multiply-add
            for row in 0..<pivot {
                let arg = matrix[row][pivot] / matrix[pivot][pivot]
                for col in pivot..<matrix[row].count {
                    matrix[row][col] -= arg * matrix[pivot][col]
                }
            }
        }
        
        // remove identity
        for row in 0..<matrix.count {
            for _ in 0..<matrix.count {
                matrix[row].remove(at:0)
            }
        }
        
        return matrix
    }


    static func leastSquares(matrix m: [[Double]], y: [[Double]]) -> [Double] {

        let t = transpose(matrix: m)
        let v1 = multiply(firstMatrix: t, secondMatrix: m)
        let v2 = inverse(matrix: v1)
        let v3 = multiply(firstMatrix: v2, secondMatrix: t)
        let v4 = multiply(firstMatrix: v3, secondMatrix: y)
        
        return transpose(matrix: v4)[0]
    }
    
    static func module(_ v: (Float, Float, Float)) -> Float {
        let x2 = v.0 * v.0
        let y2 = v.1 * v.1
        let z2 = v.2 * v.2
        
        let module = sqrt(x2 + y2 + z2)
        
        return module
    }
    
    static func extractPositionFromMatrix(matrix: simd_float4x4) -> (Float, Float, Float) {
        let x = matrix[3, 0]
        let y = matrix[3, 1]
        let z = matrix[3, 2]
        
        return(x, y, z)
    }
    
    static func extractOrientationFromMatrix(matrix: simd_float4x4) -> (Float, Float) {
        let (_, _, z0) = extractPositionFromMatrix(matrix: matrix)
        let (Ax, Ay, Az) = extractVectorPointingZFromMatrix(matrix: matrix)
        
        let x: Float = -z0 * Ax / Az
        let y: Float = -z0 * Ay / Az
        
        return (x, y)
    }
    
    static func extractOrientationFromMatrixAndZdistance(matrix: simd_float4x4, zDistance: Float) -> (Float, Float) {
        let (Ax, Ay, Az) = extractVectorPointingZFromMatrix(matrix: matrix)
        
        let x: Float = -zDistance * Ax / Az
        let y: Float = -zDistance * Ay / Az
        
        return (x, y)
    }
    
    static func extractOrientationFromVectorAndZdistance(vector: simd_float3, zDistance: Float) -> (Float, Float) {
        let (Ax, Ay, Az) = (vector.x, vector.y, vector.z)
        
        let x: Float = -zDistance * Ax / Az
        let y: Float = -zDistance * Ay / Az
        
        return (x, y)
    }
    
    static func extractVectorPointingZFromMatrix(matrix: simd_float4x4) -> (Float, Float, Float) {
        let mat_col1: simd_float3 = SIMD3(matrix[0, 0], matrix[0, 1], matrix[0, 2])
        let mat_col2: simd_float3 = SIMD3(matrix[1, 0], matrix[1, 1], matrix[1, 2])
        let mat_col3: simd_float3 = SIMD3(matrix[2, 0], matrix[2, 1], matrix[2, 2])
        let upperLeftMatrix: simd_float3x3 = simd_float3x3(mat_col1, mat_col2, mat_col3)
        let direction: simd_float3 = simd_float3(0, 0, 1)
        let transformedDirection: simd_float3 = upperLeftMatrix * direction
        let Ax = transformedDirection.x
        let Ay = transformedDirection.y
        let Az = transformedDirection.z
        
        return(Ax, Ay, Az)
    }
    
    static func project4x4MatrixToZequalZero(matrix: simd_float4x4) -> (Float, Float) {
        
        let (x0, y0, z0) = extractPositionFromMatrix(matrix: matrix)
        let (Ax, Ay, Az) = extractVectorPointingZFromMatrix(matrix: matrix)
        
        let x: Float = x0 - z0 * Ax / Az
        let y: Float = y0 - z0 * Ay / Az
        
        return (x, y)
    }
    
    static func intersecion2VectorsComponentsXZ(matrix1: simd_float4x4, matrix2: simd_float4x4) -> (Float, Float, Float, Float) {
        
        let (x0, y0, z0) = extractPositionFromMatrix(matrix: matrix1)
        let (x1, y1, z1) = extractPositionFromMatrix(matrix: matrix2)
        
        let (A0, B0, C0) = extractVectorPointingZFromMatrix(matrix: matrix1)
        let (A1, B1, C1) = extractVectorPointingZFromMatrix(matrix: matrix2)
        
        let s: Float = ((z1 - z0) * A0 - (x1 - x0) * C0) / (C0 * A1 - A0 * C1)
        
        let x: Float = x1 + A1 * s
        let z: Float = z1 + C1 * s
        
        let y_2: Float = y1 + B1 * s
        let y_1: Float = y0 + (B0 / A0) * (x1 - x0 + A1 * s)
        
        return (x, y_2, z, y_1)
    }
}

extension MutableCollection {
    mutating func shuffle(seed: UInt64) {
        let c = count
        guard c > 1 else { return }

        let source = GKMersenneTwisterRandomSource(seed: seed)
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let random = GKRandomDistribution(randomSource: source, lowestValue: 0, highestValue: unshuffledCount - 1)
            let d: Int = random.nextInt()
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    func shuffled(seed: UInt64) -> [Element] {
        var result = Array(self)
        result.shuffle(seed: seed)
        return result
    }
}

extension Sequence where Element: Collection, Element.Index == Int {
    func transposed() -> [[Element.Element]] {
        var o: [[Element.Element]] = []
        let n = Swift.min(.max, self.min { $0.count < $1.count }?.count ?? 0)
        let m = Swift.min(.max, self.max { $0.count < $1.count }?.count ?? 0)
        o.reserveCapacity(.max)
        for i in 0 ..< m {
            if i < n {
                o.append(map { $0[i] })
            } else {
                o.append(map { $0[0] })
            }
        }
        return o
    }
}

extension Int {
    static func random(seed: UInt64, minimum: Int, maximum: Int) -> Int {
        let source = GKMersenneTwisterRandomSource(seed: seed)

        let randomDistribution = GKRandomDistribution(randomSource: source, lowestValue: minimum, highestValue: maximum)
        return randomDistribution.nextInt()
    }
}

extension Float {
    static func random(seed: UInt64, minimum: Float, maximum: Float) -> Float {
        let source = GKMersenneTwisterRandomSource(seed: seed)

        let randomDistribution = GKRandomDistribution(randomSource: source, lowestValue: 0, highestValue: 10000)

        let random = randomDistribution.nextInt()

        return minimum + (maximum - minimum) * Float(random) / 10000
    }
}

class FilesAndPermission {

    // MARK: - File Managing
    static func getFilePath(fileName: String) -> String? {
        guard fileName != "Image" && fileName != "Video"
            && fileName != "Audio" && fileName != "" else {
                return nil
        }
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        var filePath: String?
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0] as NSString
            filePath = dirPath.appendingPathComponent(fileName)
        } else {
            filePath = nil
        }
        return filePath
    }

    static func saveFile(fileData: NSData, fileExtension: String) -> String? {
        let id = NSUUID().uuidString + fileExtension
        guard let filePath = getFilePath(fileName: id) else { return nil }
        _ = fileData.write(toFile: filePath, atomically: true)
        Flow.shared.test.files.append(id)
        Flow.shared.saveTest(Flow.shared.test)
        return id
    }

    static func deleteFile(fileName: String, test: Test) {
        var counter = 0
        for item in Flow.shared.tests {
            for file in item.files where file == fileName {
                counter += 1
            }
        }
        test.files.removeAll(where: { $0 == fileName })
        guard counter <= 1 else { return }
        let fileManager = FileManager.default
        guard let filePath = getFilePath(fileName: fileName) else { return }
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch {
                print("Could not delete file: \(error)") // borrar esto, a veces pasa
            }
        }
    }

    static func saveImage(image: UIImage) -> String {
        guard let imageData = image.png else { return "Image" }
        let imageNSData = NSData(data: imageData)
        return FilesAndPermission.saveFile(fileData: imageNSData, fileExtension: ".png") ?? "Image"
    }

    static func getImage(imageName: String) -> UIImage? {
        var savedImage: UIImage?
        if let imagePath = FilesAndPermission.getFilePath(fileName: imageName) {
            savedImage = UIImage(contentsOfFile: imagePath)
        } else {
            savedImage = nil
        }
        return savedImage
    }

    static func saveVideo(videoURL: URL) -> String {
        guard let videoNSData = NSData(contentsOf: videoURL) else { return "Video" }
        return FilesAndPermission.saveFile(fileData: videoNSData, fileExtension: ".mp4") ?? "Video"
    }

    static func getVideo(videoName: String) -> URL? {
        var savedVideo: URL?
        if let videoPath = FilesAndPermission.getFilePath(fileName: videoName) {
            savedVideo = URL(fileURLWithPath: videoPath)
        } else {
            savedVideo = nil
        }
        return savedVideo
    }

    static func saveAudio(audioURL: URL, test: Test) -> String {
        var name = "Audio"
        guard let exportSession = AVAssetExportSession(asset: AVAsset(url: audioURL),
                                                       presetName: AVAssetExportPresetAppleM4A) else { return name }
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = AVFileType.m4a
        if let audioName = FilesAndPermission.saveFile(fileData: NSData(), fileExtension: ".m4a") {
            deleteFile(fileName: audioName, test: test)

            if let outputURL = getAudio(audioName: audioName) {

                exportSession.outputURL = outputURL

                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                exportSession.exportAsynchronously(completionHandler: { () -> Void in

                    switch exportSession.status {
                    case .cancelled:
                        print("cancelled")
                    case .unknown:
                        print("unknown")
                    case .waiting:
                        print("waiting")
                    case .exporting:
                        print("exporting")
                    case .completed:
                        name = audioName
                        Flow.shared.test.files.append(audioName)
                        Flow.shared.saveTest(Flow.shared.test)
                        print("completed")
                    case .failed:
                        print("failed")
                    @unknown default:
                        print("unknown default")
                    }
                    dispatchGroup.leave()
                })
                dispatchGroup.wait()
            }
        }
        return name
    }

    static func getAudio(audioName: String) -> URL? {
        var savedAudio: URL?
        if let audioPath = FilesAndPermission.getFilePath(fileName: audioName) {
            savedAudio = URL(fileURLWithPath: audioPath)
        } else {
            savedAudio = nil
        }
        return savedAudio
    }

    //list of all files to make comprobations
    static func listAllFilesInDocuments() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("")
            print("printing files")
            for element in fileURLs {
                print("")
                print(element)
            }
            print("")
            print("total number of files: \(fileURLs.count)")
            print("")
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }

    static func deleteAllFilesInDocuments() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for element in fileURLs {
                try FileManager.default.removeItem(at: element)
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
}

extension Bool {
    var text: String {
        return self ? "true" : "false"
    }

    var int: Int {
        return self ? 1 : 0
    }
}

