//
//  Tracker.swift
//  StimuliApp
//
//  Created by Rafael Marín Campos on 1/5/23.
//  Copyright © 2023 Rafa Marín. All rights reserved.
//

import Foundation
import UIKit
import ARKit

#if canImport(SeeSo)
let importedSeeSo = true
let licenseKey : String = ""
import SeeSo


class SeeSoTracker: GazeDelegate, FaceDelegate, UserStatusDelegate, CalibrationDelegate, InitializationDelegate, TrackerDelegate {
    
    var gazeTracker: GazeTracker?
    var eyeTrackerDelegate: TrackerOnViewDelegate?
    var isCalibrating: Bool {
        return gazeTracker?.isCalibrating() ?? false
    }
    
    func start() {
        let options = UserStatusOption()
        options.useAll()
        GazeTracker.initGazeTracker(license: licenseKey, delegate: self, option: options)
    }

    func end() {
        GazeTracker.deinitGazeTracker(tracker: self.gazeTracker)
        self.gazeTracker = nil
    }
    
    func onInitialized(tracker: GazeTracker?, error: InitializationError) {
        if tracker != nil {
            Flow.shared.eyeTracker?.gazeTracker = tracker
            tracker?.gazeDelegate = self
            tracker?.faceDelegate = self
            tracker?.userStatusDelegate = self
            tracker?.calibrationDelegate = self
            tracker?.setTrackingFPS(fps: Constants.eyeTrackerSamplingFrequency)
            self.eyeTrackerDelegate?.onInitialized(error: false)
        } else {
            self.eyeTrackerDelegate?.onInitialized(error: true)
        }
    }
    
    func setCalibrationData(calibrationData: [Double]) {
        self.gazeTracker?.setCalibrationData(calibrationData: calibrationData)
    }
    
    func startCalibration() {
        self.gazeTracker?.startCalibration(mode: .FIVE_POINT, criteria: .HIGH)
    }
    
    func startCollectSamples() {
        self.gazeTracker?.startCollectSamples()
    }
    
    func startTracking() {
        self.gazeTracker?.startTracking()
    }

    func stopTracking() {
        self.gazeTracker?.stopTracking()
    }
    
    func onCalibrationProgress(progress: Double) {
        self.eyeTrackerDelegate?.onCalibrationProgress(progress: progress)
    }
    func onCalibrationNextPoint(x: Double, y: Double) {
        self.eyeTrackerDelegate?.onCalibrationNextPoint(x: x, y: y)
    }
    func onCalibrationFinished(calibrationData: [Double]) {
        self.eyeTrackerDelegate?.onCalibrationFinished(calibrationData: calibrationData)
    }
    
    func onGaze(gazeInfo : GazeInfo) {
        let isTracking = gazeInfo.trackingState == .SUCCESS || gazeInfo.trackingState == .LOW_CONFIDENCE
        let clock = gazeInfo.timestamp / 1000
        self.eyeTrackerDelegate?.onGaze(gazeX: gazeInfo.x,
                                        gazeY: gazeInfo.y,
                                        clock: clock,
                                        isTracking: isTracking)
    }
    
    func onFace(faceInfo: FaceInfo) {
        let z = Float(faceInfo.centerZ) / 10 // divide per 10 because SeeSo gives mm
        let clock = faceInfo.timestamp / 1000
        self.eyeTrackerDelegate?.onFace(z: z, clock: clock)
    }
    
    func moveToFirstPosition() {}
}





#else
let importedSeeSo = false

class GazeTracker {}

class SeeSoTracker: TrackerDelegate {
    func moveToFirstPosition() {}
    
    var gazeTracker: GazeTracker?
    var eyeTrackerDelegate: TrackerOnViewDelegate?
    var isCalibrating: Bool = false
    
    func start() {}
    func startCalibration() {}
    func startTracking() {}
    func stopTracking() {}
    func startCollectSamples() {}
    func setCalibrationData(calibrationData: [Double]) {}
    func end() {}
}



#endif
class ARKitTracker: NSObject, ARSessionDelegate, TrackerDelegate {
    
    var gazeTracker: GazeTracker?
    var session: ARSession?
    var eyeTrackerDelegate: TrackerOnViewDelegate?
    var isTracking: Bool = false
    var isCalibrating: Bool = false
    var saveSamples: Bool = false
    let width: Double = Double(UIScreen.main.bounds.size.width)
    let height: Double = Double(UIScreen.main.bounds.size.height)
    let semiWidth: Double = Double(UIScreen.main.bounds.size.width) / 2
    let semiHeight: Double = Double(UIScreen.main.bounds.size.height) / 2
    let pointspermeter: Double = Double(Flow.shared.settings.ppcm * 100 / Flow.shared.settings.retina)
    

    var xBias: Double = 0
    var xSlopeZ: Double = 0
    var xSlopeFacePointX: Double = 0
    var xSlopeFacePointY: Double = 0
    var xSlopeLeftX: Double = 0
    var xSlopeRightX: Double = 0
    var xSlopeZlrX: Double = 0
    var xSlopeFaceOrientationXlrX: Double = 0
    var xSlopeFaceOrientationYlrX: Double = 0
    
    var yBias: Double = 0
    var ySlopeZ: Double = 0
    var ySlopeFacePointX: Double = 0
    var ySlopeFacePointY: Double = 0
    var ySlopeLeftY: Double = 0
    var ySlopeRightY: Double = 0
    var ySlopeZlrY: Double = 0
    var ySlopeFaceOrientationXlrY: Double = 0
    var ySlopeFaceOrientationYlrY: Double = 0
    
    
//    let points: [CGPoint] = [CGPoint(x: 30,
//                                     y: 30),
//
//                             CGPoint(x: (UIScreen.main.bounds.size.width - 30),
//                                     y: 30),
//
//                             CGPoint(x: 30,
//                                     y: UIScreen.main.bounds.size.height - 30),
//
//                             CGPoint(x: UIScreen.main.bounds.size.width - 30,
//                                     y: UIScreen.main.bounds.size.height - 30),
//
//                             CGPoint(x: 30,
//                                     y: UIScreen.main.bounds.size.height * 0.5),
//
//                             CGPoint(x: UIScreen.main.bounds.size.width - 30,
//                                     y: UIScreen.main.bounds.size.height * 0.5),
//
//                             CGPoint(x: UIScreen.main.bounds.size.width * 0.5,
//                                     y: UIScreen.main.bounds.size.height * 0.5)]
    
    
    let points: [CGPoint] = [CGPoint(x: UIScreen.main.bounds.size.width * 0.5,
                                     y: UIScreen.main.bounds.size.height * 0.5)]
    
    var xs: [Double] = []
    var ys: [Double] = []
    var zs: [Float] = []
    
    var matrixX: [[Double]] = []
    var matrixY: [[Double]] = []
    var realX: [[Double]] = []
    var realY: [[Double]] = []
    
    var progressCounter: Double = 0
    var pointCounter: Int = 0
    
    var cameraToOriginTransform: simd_float4x4 = simd_float4x4()
        
    func start() {
        self.session = ARSession()
        self.session?.delegate = self
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.worldAlignment = .camera
        session?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.isTracking = true
        self.eyeTrackerDelegate?.onInitialized(error: false)
        
        let v1: simd_float4 = SIMD4(Float(Flow.shared.angle00),
                                    Float(Flow.shared.angle01),
                                    0,
                                    Float(Flow.shared.cameraXPosition / pointspermeter))
        
        let v2: simd_float4 = SIMD4(Float(Flow.shared.angle10),
                                    Float(Flow.shared.angle11),
                                    0,
                                    Float(Flow.shared.cameraYPosition / pointspermeter))
        
        let v3: simd_float4 = SIMD4(0, 0, -1, 0)
        let v4: simd_float4 = SIMD4(0, 0, 0, 1)
        
        cameraToOriginTransform = simd_float4x4(rows: [v1, v2, v3, v4])
        
        self.eyeTrackerDelegate?.onCalibrationFinished(calibrationData: [])
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        var faceDetected = false
        
        for anchor in frame.anchors {
            guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
            guard faceAnchor.isTracked else { continue }
            
            faceDetected = true
            
            let leftEyeToFaceTransform: simd_float4x4 = faceAnchor.leftEyeTransform
            let rightEyeToFaceTransform: simd_float4x4 = faceAnchor.rightEyeTransform
            
            let faceToCameraTransform: simd_float4x4 = faceAnchor.transform
            let leftEyeToCameraTransform: simd_float4x4 = faceToCameraTransform * leftEyeToFaceTransform
            let rightEyeToCameraTransform: simd_float4x4 = faceToCameraTransform * rightEyeToFaceTransform
            
//          let faceToOriginTransform: simd_float4x4 = cameraToOriginTransform * faceToCameraTransform
            let leftEyeToOriginTransform: simd_float4x4 = cameraToOriginTransform * leftEyeToCameraTransform
            let rightEyeToOriginTransform: simd_float4x4 = cameraToOriginTransform * rightEyeToCameraTransform

                            
            // only positions (from origin)
//          let faceToOriginPosition = AppUtility.extractPositionFromMatrix(matrix: faceToOriginTransform)
            let leftEyeToOriginPosition = AppUtility.extractPositionFromMatrix(matrix: leftEyeToOriginTransform)
            let rightEyeToOriginPosition = AppUtility.extractPositionFromMatrix(matrix: rightEyeToOriginTransform)
            
            
            // distance
            let z0 = (leftEyeToOriginPosition.2 + rightEyeToOriginPosition.2) / 2
//          // only orientations (from origin)
//          let faceToOriginOrientation = AppUtility.extractOrientationFromMatrix(matrix: faceToOriginTransform)
//          let leftEyeToOriginOrientation = AppUtility.extractOrientationFromMatrix(matrix: leftEyeToOriginTransform)
//          let rightEyeToOriginOrientation = AppUtility.extractOrientationFromMatrix(matrix: rightEyeToOriginTransform)
//          let facePositionX: Double = max(-1, min(1, Double(faceToOriginPosition.0)))
//          let faceOrientationX: Double = max(-1, min(1, Double(faceToOriginOrientation.0)))
//          let leftX: Double = max(-1, min(1, Double(leftEyeToOriginOrientation.0))) - faceOrientationX
//          let rightX: Double = max(-1, min(1, Double(rightEyeToOriginOrientation.0))) - faceOrientationX
//          let lrX: Double = leftX + rightX
//          let facePositionY: Double = max(-1, min(1, Double(faceToOriginPosition.1)))
//          let faceOrientationY: Double = max(-1, min(1, Double(faceToOriginOrientation.1)))
//          let leftY: Double = max(-1, min(1, Double(leftEyeToOriginOrientation.1))) - faceOrientationY
//          let rightY: Double = max(-1, min(1, Double(rightEyeToOriginOrientation.1))) - faceOrientationY
//          let lrY: Double = leftY + rightY
//          let x = Double(points[pointCounter].x)
//          let y = Double(points[pointCounter].y)
            
            if isCalibrating && saveSamples {
//                    print(z, faceOrientationX, faceOrientationY)
//                    matrixX.append([z,
//                                    faceOrientationX,
//                                    faceOrientationY,
//                                    facePositionX,
//                                    facePositionY,
//                                    lrX,
//                                    lrY,
//                                    x,
//                                    y])
////                    matrixX.append([z,
////                                    faceOrientationX,
////                                    faceOrientationY,
////                                    Double(zGroup),
////                                    Double(faceOrientationXGroup),
////                                    Double(faceOrientationYGroup),
////                                    facePointX,
////                                    lrX,
////                                    x,
////                                    y])
////                    matrixX.append([1,
////                                    z,
////                                    facePointX,
////                                    facePointY,
////                                    leftX,
////                                    rightX,
////                                    zlrX,
////                                    faceOrientationXlrX,
////                                    faceOrientationYlrX])
////
////                    matrixY.append([1,
////                                    z,
////                                    facePointX,
////                                    facePointY,
////                                    leftY,
////                                    rightY,
////                                    zlrY,
////                                    faceOrientationXlrY,
////                                    faceOrientationYlrY])
//                    realX.append([x])
//                    realY.append([y])
//                    progressCounter += 0.0033
//                    self.eyeTrackerDelegate?.onCalibrationProgress(progress: progressCounter)
//                    if realX.count % 4000 == 0 {
//                        pointCounter += 1
//                        if pointCounter == points.count {
////                            let resultCalibrationX: [Double] = AppUtility.leastSquares(matrix: matrixX, y: realX)
////                            let resultCalibrationY: [Double] = AppUtility.leastSquares(matrix: matrixY, y: realY)
////
////                            let resultCalibration: [Double] = resultCalibrationX + resultCalibrationY
////
////                            isTracking = true
////                            isCalibrating = false
////                            saveSamples = false
////                            progressCounter = 0
////                            pointCounter = 0
////
////                            let point = points[pointCounter]
////
////                            self.eyeTrackerDelegate?.onCalibrationProgress(progress: 0)
////                            self.eyeTrackerDelegate?.onCalibrationNextPoint(x: Double(point.x),
////                                                                            y: Double(point.y))
////                            self.eyeTrackerDelegate?.onCalibrationFinished(calibrationData: resultCalibration)
////                            self.setCalibrationData(calibrationData: resultCalibration)
//                            pointCounter = 0
//                            matrixX = []
//                            realX = []
//                        } else {
//                            let point = points[pointCounter]
//                            self.eyeTrackerDelegate?.onCalibrationProgress(progress: 0)
//                            self.eyeTrackerDelegate?.onCalibrationNextPoint(x: Double(point.x),
//                                                                            y: Double(point.y))
//                            progressCounter = 0
//                            saveSamples = false
//                        }
//                    }
            } else {
//                    var x0 = faceOrientationX + facePositionX + 0.65 * lrX
//                    var y0 = faceOrientationY + facePositionY + lrY
//                    x0 *= pointspermeter
//                    y0 *= pointspermeter
//                    xs.append(x0)
//                    ys.append(y0)
                zs.append(z0)
                
                if zs.count == 10 {
                    let clock = CACurrentMediaTime()
                    let z1 = zs.reduce(0, +) / 10
                    self.eyeTrackerDelegate?.onFace(z: z1 * 100, clock: clock)
                    zs.removeFirst()
//                        let x1 = xs.reduce(0, +) / 10
//                        let y1 = ys.reduce(0, +) / 10
//                        self.eyeTrackerDelegate?.onGaze(gazeX: Double(x1), gazeY: Double(y1),
//                                                        clock: clock, isTracking: true)
//                        xs.removeFirst()
//                        ys.removeFirst()
                }
            }
        }
        
        if !faceDetected && isTracking {
            let clock = CACurrentMediaTime()
            self.eyeTrackerDelegate?.onFace(z: Float.nan, clock: clock)
        }
    }
    
    
    
    func end() {}
    func startCalibration() {
        self.isCalibrating = false
    }
    func startTracking() {
        if self.isTracking == false {
            let configuration = ARFaceTrackingConfiguration()
            configuration.maximumNumberOfTrackedFaces = 1
            configuration.worldAlignment = .camera
            session?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            self.isTracking = true
        }
    }
    func stopTracking() {
        if self.isTracking == true {
            self.isTracking = false
            self.session?.pause()
        }
    }
    
    func moveToFirstPosition() {
        self.eyeTrackerDelegate?.onCalibrationNextPoint(x: points[0].x,
                                                        y: points[0].y)
    }
    
    func startCollectSamples() {
        self.saveSamples = true
    }

    func onInitialized(error: Bool) {}

    func setCalibrationData(calibrationData: [Double]) {
        
        if calibrationData.count == 18 {
                        
            self.xBias = calibrationData[0]
            self.xSlopeZ = calibrationData[1]
            self.xSlopeFacePointX = calibrationData[2]
            self.xSlopeFacePointY = calibrationData[3]
            self.xSlopeLeftX = calibrationData[4]
            self.xSlopeRightX = calibrationData[5]
            self.xSlopeZlrX = calibrationData[6]
            self.xSlopeFaceOrientationXlrX = calibrationData[7]
            self.xSlopeFaceOrientationYlrX = calibrationData[8]
            
            self.yBias = calibrationData[9]
            self.ySlopeZ = calibrationData[10]
            self.ySlopeFacePointX = calibrationData[11]
            self.ySlopeFacePointY = calibrationData[12]
            self.ySlopeLeftY = calibrationData[13]
            self.ySlopeRightY = calibrationData[14]
            self.ySlopeZlrY = calibrationData[15]
            self.ySlopeFaceOrientationXlrY = calibrationData[16]
            self.ySlopeFaceOrientationYlrY = calibrationData[17]
        }
    }
}


// functions I need in the viewControllers
protocol TrackerOnViewDelegate {
    func onInitialized(error: Bool)
    func onCalibrationProgress(progress: Double)
    func onCalibrationNextPoint(x: Double, y: Double)
    func onCalibrationFinished(calibrationData : [Double])
    func onGaze(gazeX: Double, gazeY: Double,
                clock: Double, isTracking: Bool)
    func onFace(z: Float, clock: Double)

    func saveCalibrationData()
}

// functions I need the eyeTracker to have
protocol TrackerDelegate {
    var gazeTracker: GazeTracker? { get set }
    var eyeTrackerDelegate: TrackerOnViewDelegate? { get set }
    var isCalibrating: Bool { get }
    
    func start()
    func startCalibration()
    func startTracking()
    func stopTracking()
    func moveToFirstPosition()
    func startCollectSamples()
    func setCalibrationData(calibrationData: [Double])
    func end()
}
