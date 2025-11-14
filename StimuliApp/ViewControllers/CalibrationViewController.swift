//  Created by VisualCamp on 2020/06/12.
//  Copyright © 2020 VisualCamp. All rights reserved.

import UIKit
import AVKit

class CalibrationViewController: UIViewController {
    
    @IBOutlet weak var calibrationButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func calibrationButtonPressed(_ sender: Any) {
        self.calibrationButton.isHidden = true
        self.continueButton.isHidden = true
        startCalibration()
    }

    @IBAction func continueButtonPressed(_ sender: Any) {
        self.saveCalibrationData()
        Flow.shared.navigate(to: Display())
    }
    
    var screenSize: CGSize = UIScreen.main.bounds.size
    var x: CGFloat = 0
    var y: CGFloat = 0

    var gazePointView : GazePointView? = nil
    var caliPointView : CalibrationPointView? = nil

    var calibrationData : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        
        Flow.shared.enterFullScreen()

        //brightness
        UIApplication.shared.isIdleTimerDisabled = true
        let brightness = pow(Flow.shared.settings.brightness, (1.0 / Constants.gammaPerBrightness))
        UIScreen.main.brightness = CGFloat(brightness - 0.01)
        UIScreen.main.brightness = CGFloat(brightness)

        view.frame = CGRect(x: x, y: y, width: screenSize.width, height: screenSize.height)

        let size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)

        switch UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown {
        case .unknown:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
            Flow.shared.cameraXPosition = Flow.shared.settings.device.cameraPosition.portraitX * screenSize.width
            Flow.shared.cameraYPosition = Flow.shared.settings.device.cameraPosition.portraitY * screenSize.height
            Flow.shared.angle00 = 0
            Flow.shared.angle01 = 1
            Flow.shared.angle10 = 1
            Flow.shared.angle11 = 0
        case .portrait:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
            Flow.shared.cameraXPosition = Flow.shared.settings.device.cameraPosition.portraitX * screenSize.width
            Flow.shared.cameraYPosition = Flow.shared.settings.device.cameraPosition.portraitY * screenSize.height
            Flow.shared.angle00 = 0
            Flow.shared.angle01 = 1
            Flow.shared.angle10 = 1
            Flow.shared.angle11 = 0
        case .portraitUpsideDown:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
            Flow.shared.cameraXPosition = Flow.shared.settings.device.cameraPosition.portraitX * screenSize.width
            Flow.shared.cameraYPosition = Flow.shared.settings.device.cameraPosition.portraitY * screenSize.height
            Flow.shared.angle00 = 0
            Flow.shared.angle01 = 1
            Flow.shared.angle10 = 1
            Flow.shared.angle11 = 0
        case .landscapeRight:
            AppUtility.lockOrientation(.landscapeRight)
            Flow.shared.orientation = .landscapeRight
            Flow.shared.cameraXPosition = Flow.shared.settings.device.cameraPosition.landscapeRightX * screenSize.width
            Flow.shared.cameraYPosition = Flow.shared.settings.device.cameraPosition.landscapeRightY * screenSize.height
            Flow.shared.angle00 = 1
            Flow.shared.angle01 = 0
            Flow.shared.angle10 = 0
            Flow.shared.angle11 = -1
        case .landscapeLeft:
            AppUtility.lockOrientation(.landscapeLeft)
            Flow.shared.orientation = .landscapeLeft
            Flow.shared.cameraXPosition = Flow.shared.settings.device.cameraPosition.landscapeLeftX * screenSize.width
            Flow.shared.cameraYPosition = Flow.shared.settings.device.cameraPosition.landscapeLeftY * screenSize.height
            Flow.shared.angle00 = -1
            Flow.shared.angle01 = 0
            Flow.shared.angle10 = 0
            Flow.shared.angle11 = 1
        @unknown default:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
            Flow.shared.cameraXPosition = Flow.shared.settings.device.cameraPosition.portraitX * screenSize.width
            Flow.shared.cameraYPosition = Flow.shared.settings.device.cameraPosition.portraitY * screenSize.height
            Flow.shared.angle00 = 0
            Flow.shared.angle01 = 1
            Flow.shared.angle10 = 1
            Flow.shared.angle11 = 0
        }
        
        //tracker
        Flow.shared.eyeTracker?.eyeTrackerDelegate = self
        
        initViewComponents(size: size)
        Flow.shared.eyeTracker?.start()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    

    func startCalibration() {
        self.calibrationData.removeAll()
        showCaliPointView(view: caliPointView!)
        Flow.shared.eyeTracker?.startCalibration()
        
    }
}



// UI componenents setting functions
extension CalibrationViewController {

    private func initViewComponents(size: CGSize) {
        self.calibrationButton.isHidden = true
        self.continueButton.isHidden = true


        self.gazePointView = GazePointView(frame: CGRect(origin: .zero, size: size))
        self.gazePointView?.isHidden = true
        self.view.addSubview(gazePointView!)

        self.caliPointView = CalibrationPointView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        self.caliPointView?.isHidden = true
        self.view.addSubview(caliPointView!)
    }


    func showCaliPointView(view : UIView) {
        DispatchQueue.main.async {
            if view.isHidden {
                view.isHidden = false
                if view == self.caliPointView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        Flow.shared.eyeTracker?.startCollectSamples()
                    })
                }
            }
        }
    }
}



class CalibrationPointView : UILabel {
    override init(frame: CGRect) {
        super.init(frame : frame)
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
        textAlignment = .center
        textColor = .red
        adjustsFontSizeToFitWidth = true
        text = "0%"
    }

    func setProgress(progress : Double){
        let percent = Int(progress * 100)
        DispatchQueue.main.async {
            self.text = "\(percent)%"
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class GazePointView : UIView {
    let verticalLine : UIView =  UIView()
    let horizontalLine : UIView = UIView()
    let pointView : UIView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
        isUserInteractionEnabled = false
    }

    private func initSubviews() {
        verticalLine.frame.size = CGSize(width: 2.5, height: frame.height)
        verticalLine.backgroundColor = .red
        horizontalLine.frame.size = CGSize(width: frame.width, height: 2.5)
        horizontalLine.backgroundColor = .red
        pointView.frame.size = CGSize(width: 30, height: 30)
        pointView.layer.cornerRadius = 15
        pointView.backgroundColor = .red

        self.addSubview(verticalLine)
        self.addSubview(horizontalLine)
        self.addSubview(pointView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moveView(x: Double, y: Double){
        let centerPoint = CGPoint(x: x, y: y)
        DispatchQueue.main.async {
            self.pointView.center = centerPoint
            self.verticalLine.frame.origin.x = centerPoint.x
            self.horizontalLine.frame.origin.y = centerPoint.y
        }
    }
}


extension CalibrationViewController : TrackerOnViewDelegate {

    func onInitialized(error: Bool) {
        if error {
            showAlertCalibrationError(action: { _ in
                Flow.shared.navigateBack()
            })
        } else {
            self.view.bringSubviewToFront(gazePointView!)

            if Task.shared.testUsesTrackerSeeSo {
                showAlertCalibration(action: { _ in
                    self.startCalibration()
                })
            }
            DispatchQueue.global(qos: .userInitiated).async {
                Flow.shared.eyeTracker?.startTracking()
                if let calibrationData = UserDefaults.standard.array(forKey: "calibrationData") as? [Double] {
                    self.calibrationData = calibrationData
                    Flow.shared.eyeTracker?.setCalibrationData(calibrationData: self.calibrationData)
                }
            }
        }
    }
    
    func onCalibrationProgress(progress: Double) {
        caliPointView?.setProgress(progress: progress)
    }

    func onCalibrationNextPoint(x: Double, y: Double) {
        DispatchQueue.main.async {
            self.caliPointView?.center = CGPoint(x: CGFloat(x), y: CGFloat(y))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                Flow.shared.eyeTracker?.startCollectSamples()
            })
        }
    }
    
    func onCalibrationFinished(calibrationData : [Double]) {
        if Task.shared.testUsesTrackerSeeSo {
            self.calibrationData = calibrationData
            self.continueButton.isHidden = false
            self.calibrationButton.isHidden = false
            self.caliPointView?.isHidden = true
        } else {
            Flow.shared.navigate(to: Display())
        }
    }
    
    func onGaze(gazeX: Double, gazeY: Double, clock: Double, isTracking: Bool) {
        if Flow.shared.eyeTracker?.isCalibrating ?? false {
            self.gazePointView?.isHidden = true
        } else {
            if isTracking {
                self.showCaliPointView(view: self.gazePointView!)
                self.gazePointView?.moveView(x: gazeX, y: gazeY)
            } else {
                self.gazePointView?.isHidden = true
            }
        }
    }
    
    func onFace(z: Float, clock: Double) {}

    func saveCalibrationData() {
        if calibrationData.count > 0 {
            UserDefaults.standard.removeObject(forKey: "calibrationData")
            UserDefaults.standard.set(calibrationData, forKey: "calibrationData")
        }
    }
}

