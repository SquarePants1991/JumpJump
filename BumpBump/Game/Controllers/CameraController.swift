//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import GLKit

enum CameraControllerState {
    case waitingTargetMove
    case targetMoving(beginPosition: SCNVector3)
    case animateCameraToTarget(beginPosition: SCNVector3, endPosition: SCNVector3)
}

class CameraController: ControllerProtocol {
    var player: Player?
    var boxManager: BoxController?
    var camera: SCNCamera? {
        return cameraNode.camera
    }
    var cameraNode: SCNNode!
    var state: CameraControllerState = .waitingTargetMove

    private var relativePosition: SCNVector3!
    private var animationElapsedTime: TimeInterval = 0
    private var animationDuration: TimeInterval = 0.5

    init(cameraNode: SCNNode) {
        self.cameraNode = cameraNode
    }

    func setupTarget(player: Player, boxManager: BoxController) {
        self.player = player
        self.boxManager = boxManager
        if let player = self.player, let boxManager = self.boxManager {
            let targetPosition = (boxManager.currentBox!.boxPosition + boxManager.nextBox!.boxPosition) * 0.5
            self.relativePosition = self.cameraNode.position - targetPosition
            self.cameraNode.look(at: targetPosition, up: SCNVector3.init(0, 1, 0), localFront: SCNNode.localFront)
        }
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        if let player = self.player, let boxManager = self.boxManager {
            switch self.state {
            case .animateCameraToTarget(let beginPosition, let endPosition):
                animationElapsedTime += timeSinceLastUpdate
                var position = beginPosition + (endPosition - beginPosition) * Float(animationElapsedTime / animationDuration)
                if animationElapsedTime >= animationDuration {
                    position = endPosition
                    self.state = .waitingTargetMove
                }
                self.cameraNode.look(at: position, up: SCNVector3.init(0, 1, 0), localFront: SCNNode.localFront)
                self.cameraNode.position = position + self.relativePosition
            default:
                break
            }
        }
    }

    func updateCamera() {
        if let player = self.player, let boxManager = self.boxManager {
            let beginPosition = self.cameraNode.position - self.relativePosition
            let targetPosition = (boxManager.currentBox!.boxPosition + boxManager.nextBox!.boxPosition) * 0.5
            self.state = .animateCameraToTarget(beginPosition: beginPosition, endPosition: targetPosition)
            animationElapsedTime = 0
        }
    }

    func reset() {
        if let player = self.player, let boxManager = self.boxManager {
            let position = (boxManager.currentBox!.boxPosition + boxManager.nextBox!.boxPosition) * 0.5
            self.cameraNode.position = position + self.relativePosition
            self.cameraNode.look(at: position, up: SCNVector3.init(0, 1, 0), localFront: SCNNode.localFront)
        }
    }

    func rootNode() -> SCNNode {
        return cameraNode
    }
}