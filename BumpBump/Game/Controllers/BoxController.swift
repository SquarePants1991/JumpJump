//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import QuartzCore

class BoxController: ControllerProtocol {
    var boxObjects: [BaseBox] = []
    var putPosition: SCNVector3 = SCNVector3.init(0, 0, 0)

    let nextBoxDirections = [
        SCNVector3.init(1, 0, 0),
        SCNVector3.init(0, 0, -1),
    ]

    weak var scene: SCNScene?

    public var currentBox: BaseBox?
    public var nextBox: BaseBox?

    init(scene: SCNScene) {
        self.scene = scene
    }

    func resetBoxes() {
        clearBoxes()
        putPosition = SCNVector3.init(0, 0, 0)
        currentBox = addBox(direction: nextBoxDirections[0], size: 0.6, nextDistance: 1.0)
        nextBox = addBox(direction: nextBoxDirections[1], size: 0.6, nextDistance: 1.0)
    }

    func clearBoxes() {
        boxObjects.forEach {
            $0.destroy()
        }
        boxObjects = []
    }

    func createNextBox() {
        currentBox = nextBox
        nextBox = addBox()

        // do put box animation
        let originPosition = nextBox!.rootNode().position
        nextBox!.rootNode().position = SCNVector3.init(originPosition.x, originPosition.y, originPosition.z)

        let keyframeAnimation = CAKeyframeAnimation.init(keyPath: "position.y")
        keyframeAnimation.keyTimes = [0.0, 0.4, 0.55, 0.7, 0.78, 0.86, 0.94, 1.0]
        keyframeAnimation.values = [originPosition.y + 2, originPosition.y, originPosition.y + 0.5, originPosition.y, originPosition.y + 0.4, originPosition.y, originPosition.y + 0.14, originPosition.y]
        keyframeAnimation.duration = 0.4
        keyframeAnimation.isRemovedOnCompletion = true
        keyframeAnimation.fillMode = kCAFillModeForwards
        nextBox!.rootNode().addAnimation(keyframeAnimation, forKey: "position.y")
    }

    private func addBox(direction: SCNVector3? = nil, size: Float? = nil, nextDistance: Float? = nil) -> BaseBox? {
        if let parentNode = scene?.rootNode {
            let newDirectionIndex = Float(arc4random()) / Float(UInt32.max) * Float(nextBoxDirections.count)
            let newDirection = direction ?? nextBoxDirections[Int(newDirectionIndex)]
            let boxDistance: Float = nextDistance ?? Float(arc4random()) / Float(UInt32.max) * 1.0 + 0.8
            let newBox = BaseBox.init(geometry: nil, position: putPosition, size: size)
            putPosition += newDirection * boxDistance
            newBox.addToNode(baseNode: parentNode)
            boxObjects.append(newBox)
            return newBox
        }
        return nil
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        boxObjects.forEach {
            $0.update(timeSinceLastUpdate: timeSinceLastUpdate)
        }
    }
}
