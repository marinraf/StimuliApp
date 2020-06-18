//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import MetalKit

struct TouchInView {

    var touch: UITouch
    var time: Double
    var view: UIView
    var originX: Float
    var originY: Float
    var coordinates: FixedPositionResponse
    var unit: Unit
    var unit1: Unit

    var location: CGPoint
    var screenSize: CGSize
    var screenRetina: CGFloat

    var realX: Float
    var realY: Float

    var x: Float
    var y: Float

    var realPolar: (radius: Float, angle: Float)
    var polar: (radius: Float, angle: Float)

    init(touch: UITouch,
         time: Double,
         view: UIView,
         originX: Float,
         originY: Float,
         coordinates: FixedPositionResponse,
         unit: Unit,
         unit1: Unit) {

        self.touch = touch
        self.time = time
        self.view = view
        self.originX = originX
        self.originY = originY
        self.coordinates = coordinates
        self.unit = unit
        self.unit1 = unit1

        self.location = touch.location(in: view)
        self.screenSize = view.bounds.size

        if Flow.shared.settings.device.type == .mac {
            self.screenRetina = 1
        } else {
            self.screenRetina = UIScreen.main.scale
        }

        self.realX = Float((location.x - screenSize.width / 2) * screenRetina)
        self.realY = Float((-location.y + screenSize.height / 2) * screenRetina)

        self.x = (realX - originX) / unit.factor
        self.y = (realY - originY) / unit1.factor

        self.realPolar = AppUtility.cartesianToPolar(xPos: realX - originX, yPos: realY - originY)
        self.polar = (radius: realPolar.0 / unit.factor, realPolar.1 / unit1.factor)
    }
}

extension DisplayRender {

    func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let uitouch = touches.first else { return }
        guard let coalescedTouches = event?.coalescedTouches(for: uitouch) else { return }
        guard let touch = coalescedTouches.first else { return }

        let time = touch.timestamp - Flow.shared.frameControl.initSceneTimeReal
        guard time > 0 else { return }

        badTiming = time < Task.shared.sceneTask.responseStart || time > Task.shared.sceneTask.responseEnd

        guard !badTiming || Task.shared.sceneTask.responseOutWindow else { return }

        touching = true

        let touchInView = TouchInView(touch: touch,
                                      time: time,
                                      view: view,
                                      originX: Task.shared.sceneTask.responseOrigin.x,
                                      originY: Task.shared.sceneTask.responseOrigin.y,
                                      coordinates: Task.shared.sceneTask.responseCoordinates,
                                      unit: Task.shared.sceneTask.responseFirstUnit,
                                      unit1: Task.shared.sceneTask.responseSecondUnit)

        switch Task.shared.sceneTask.responseType {
        case .leftRight:
            leftRightTouch(touchInView: touchInView)
        case .topBottom:
            topBottomTouch(touchInView: touchInView)
        case .touch:
            touchTouch(touchInView: touchInView)
        case .path:
            touchPath(touchInView: touchInView)
        case .touchObject:
            touchObjectTouch(touchInView: touchInView)
        case .moveObject, .keyboard, .keys, .none:
            break
        }
    }

    func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard touching else { return }
        switch Task.shared.sceneTask.responseType {
        case .path:
            pathTouches(touches: touches, event:event, view: view)
        case .moveObject:
            moveObjectTouches(touches: touches, event:event, view: view)
        default:
            return
        }
    }

    func touchesEnded(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard touching else { return }

        guard let uitouch = touches.first else { return }
        guard let coalescedTouches = event?.coalescedTouches(for: uitouch) else { return }
        guard let touch = coalescedTouches.first else { return }
        touching = false
        Task.shared.responseMovingObject = nil
        switch Task.shared.sceneTask.responseType {
        case .moveObject:
            if let userResponseTemp = userResponseTemp, Task.shared.sceneTask.endPath == .lift {
                Task.shared.userResponse.float = userResponseTemp
                if let float = Task.shared.userResponse.float {
                    Task.shared.userResponse.string = String(float)
                }
                Task.shared.userResponse.liftClock = touch.timestamp - Flow.shared.frameControl.initSceneTimeReal
                displayRenderDelegate?.stopAudio()
                responded = true
            }
        case .path:
            Task.shared.userResponse.liftClock = touch.timestamp - Flow.shared.frameControl.initSceneTimeReal
            displayRenderDelegate?.stopAudio()
            responded = true
        default:
            return
        }
    }

    func leftRightTouch(touchInView: TouchInView) {
        if touchInView.location.x < touchInView.screenSize.width / 3 {
            Task.shared.userResponse.integer = Task.shared.sceneTask.responseObject[0]?.toInt
            if let integer = Task.shared.userResponse.integer {
                Task.shared.userResponse.string = String(integer)
            }
            Task.shared.userResponse.clocks.append(touchInView.time)
            displayRenderDelegate?.stopAudio()
            responded = true
        } else if touchInView.location.x > 2 * touchInView.screenSize.width / 3 {
            Task.shared.userResponse.integer = Task.shared.sceneTask.responseObject[1]?.toInt
            if let integer = Task.shared.userResponse.integer {
                Task.shared.userResponse.string = String(integer)
            }
            Task.shared.userResponse.clocks.append(touchInView.time)
            displayRenderDelegate?.stopAudio()
            responded = true
        }
    }

    func topBottomTouch(touchInView: TouchInView) {
        if touchInView.location.y < touchInView.screenSize.height / 3 {
            Task.shared.userResponse.integer = Task.shared.sceneTask.responseObject[0]?.toInt
            if let integer = Task.shared.userResponse.integer {
                Task.shared.userResponse.string = String(integer)
            }
            Task.shared.userResponse.clocks.append(touchInView.time)
            displayRenderDelegate?.stopAudio()
            responded = true
        } else if touchInView.location.y > 2 * touchInView.screenSize.height / 3 {
            Task.shared.userResponse.integer = Task.shared.sceneTask.responseObject[1]?.toInt
            if let integer = Task.shared.userResponse.integer {
                Task.shared.userResponse.string = String(integer)
            }
            Task.shared.userResponse.clocks.append(touchInView.time)
            displayRenderDelegate?.stopAudio()
            responded = true
        }
    }

    func touchTouch(touchInView: TouchInView) {
        Task.shared.userResponse.xTouches.append(touchInView.x)
        Task.shared.userResponse.yTouches.append(touchInView.y)
        let polar = touchInView.polar
        Task.shared.userResponse.radiusTouches.append(polar.radius)
        Task.shared.userResponse.angleTouches.append(polar.angle)
        Task.shared.userResponse.clocks.append(touchInView.time)
        displayRenderDelegate?.stopAudio()
        responded = true
    }

    func touchPath(touchInView: TouchInView) {
        Task.shared.userResponse.xTouches.append(touchInView.x)
        Task.shared.userResponse.yTouches.append(touchInView.y)
        let polar = touchInView.polar
        Task.shared.userResponse.radiusTouches.append(polar.radius)
        Task.shared.userResponse.angleTouches.append(polar.angle)
        Task.shared.userResponse.clocks.append(touchInView.time)
    }

    func isTouched(object: Int, trial: Int, touchInView: TouchInView) -> Bool {
        guard DataTask.activatedBools[object] else { return false }

        let centerX = Task.shared.sceneTask.xCenter0[trial][object]
        let centerY = Task.shared.sceneTask.yCenter0[trial][object]
        let xSize = Task.shared.sceneTask.xSizeMax0[trial][object]
        let ySize = Task.shared.sceneTask.ySizeMax0[trial][object]

        let rotation = DataTask.metalValues[object][MetalValues.rotation]
        let shapeType = DataTask.metalValues[object][MetalValues.shapeType]

        var posX = touchInView.realX - centerX
        var posY = touchInView.realY - centerY

        posX = posX * cos(rotation) + posY * sin(rotation)
        posY = -posX * sin(rotation) + posY * cos(rotation)

        if shapeType == 0 {        //rectangle
            if abs(posX) < xSize / 2 && abs(posY) < ySize / 2 {
                return true
            } else {
                return false
            }
        } else if shapeType == 1 {        //ellipse
            if pow(posX, 2) / pow(xSize / 2, 2) + pow(posY, 2) / pow(ySize / 2, 2) < 1 {
                return true
            } else {
                return false
            }
        } else {         //cross, polygon, ring, wedge
            if pow(posX, 2) + pow(posY, 2) < pow(xSize / 2, 2) {
                return true
            } else {
                return false
            }
        }
    }

    func touchObjectTouch(touchInView: TouchInView) {
        let trial = Task.shared.sectionTask.currentTrial
        let numberOfObjects = DataTask.metalValues.count

        for object in (0 ..< numberOfObjects).reversed() {
            if let objectValue = Task.shared.sceneTask.responseObject[object] {
                if isTouched(object: object, trial: trial, touchInView: touchInView) {
                    Task.shared.userResponse.float = objectValue
                    if let float = Task.shared.userResponse.float {
                        Task.shared.userResponse.string = String(float)
                    }
                    Task.shared.userResponse.clocks.append(touchInView.time)
                    displayRenderDelegate?.stopAudio()
                    responded = true
                    return
                }
            }
        }
        if let backgroundValue = Task.shared.sceneTask.responseBackground {
            Task.shared.userResponse.float = backgroundValue
            if let float = Task.shared.userResponse.float {
                Task.shared.userResponse.string = String(float)
            }
            Task.shared.userResponse.clocks.append(touchInView.time)
            displayRenderDelegate?.stopAudio()
            responded = true
        }
    }

    func pathTouches(touches: Set<UITouch>, event: UIEvent?, view: UIView) {
        for uitouch in touches {
            guard let coalescedTouches = event?.coalescedTouches(for: uitouch) else { return }
            for touch in coalescedTouches {
                let time = touch.timestamp - Flow.shared.frameControl.initSceneTimeReal
                let touchInView = TouchInView(touch: touch,
                                              time: time,
                                              view: view,
                                              originX: Task.shared.sceneTask.responseOrigin.x,
                                              originY: Task.shared.sceneTask.responseOrigin.y,
                                              coordinates: Task.shared.sceneTask.responseCoordinates,
                                              unit: Task.shared.sceneTask.responseFirstUnit,
                                              unit1: Task.shared.sceneTask.responseSecondUnit)

                Task.shared.userResponse.xTouches.append(touchInView.x)
                Task.shared.userResponse.yTouches.append(touchInView.y)
                let polar = touchInView.polar
                Task.shared.userResponse.radiusTouches.append(polar.radius)
                Task.shared.userResponse.angleTouches.append(polar.angle)
                Task.shared.userResponse.clocks.append(time)
            }
        }
    }

    func moveObjectTouches(touches: Set<UITouch>, event: UIEvent?, view: UIView) {
        for uitouch in touches {
            guard let coalescedTouches = event?.coalescedTouches(for: uitouch) else { return }
            for touch in coalescedTouches {
                let time = touch.timestamp - Flow.shared.frameControl.initSceneTimeReal
                let touchInView = TouchInView(touch: touch,
                                              time: time,
                                              view: view,
                                              originX: Task.shared.sceneTask.responseOrigin.x,
                                              originY: Task.shared.sceneTask.responseOrigin.y,
                                              coordinates: Task.shared.sceneTask.responseCoordinates,
                                              unit: Task.shared.sceneTask.responseFirstUnit,
                                              unit1: Task.shared.sceneTask.responseSecondUnit)

                Task.shared.userResponse.xTouches.append(touchInView.x)
                Task.shared.userResponse.yTouches.append(touchInView.y)
                let polar = touchInView.polar
                Task.shared.userResponse.radiusTouches.append(polar.radius)
                Task.shared.userResponse.angleTouches.append(polar.angle)
                Task.shared.userResponse.clocks.append(time)

                let trial = Task.shared.sectionTask.currentTrial
                let numberOfObjects = DataTask.metalValues.count

                if Task.shared.responseMovingObject == nil {
                    for object in (0 ..< numberOfObjects).reversed() {
                        if let objectValue = Task.shared.sceneTask.responseObject[object] {
                            if isTouched(object: object, trial: trial, touchInView: touchInView) {

                                Task.shared.sceneTask.xCenter0[trial][object] = touchInView.realX
                                Task.shared.sceneTask.yCenter0[trial][object] = touchInView.realY

                                Task.shared.responseMovingObject = object
                                userResponseTemp = objectValue
                                if Task.shared.sceneTask.endPath == .touch {
                                    touchObjectTouches(touchInView: touchInView)
                                }
                                return
                            }
                        }
                    }
                } else if let object = Task.shared.responseMovingObject {

                    Task.shared.sceneTask.xCenter0[trial][object] = touchInView.realX
                    Task.shared.sceneTask.yCenter0[trial][object] = touchInView.realY

                    if Task.shared.sceneTask.endPath == .touch {
                        touchObjectTouches(touchInView: touchInView)
                    }
                    return
                }
            }
        }
    }

    func touchObjectTouches(touchInView: TouchInView) {
        let trial = Task.shared.sectionTask.currentTrial
        let numberOfObjects = DataTask.metalValues.count

        var objectsTouchedTemp = 0
        for object in (0 ..< numberOfObjects).reversed() where Task.shared.responseMovingObject != object {
            if isTouched(object: object, trial: trial, touchInView: touchInView) {
                objectsTouchedTemp += 1
            }
        }
        if objectsTouched == nil {
            objectsTouched = objectsTouchedTemp
        }
        if objectsTouched != objectsTouchedTemp {
            Task.shared.userResponse.float = userResponseTemp
            if let float = Task.shared.userResponse.float {
                Task.shared.userResponse.string = String(float)
            }
            displayRenderDelegate?.stopAudio()
            responded = true
        }
    }
}
