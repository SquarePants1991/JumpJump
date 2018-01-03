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
        if let _ = self.player, let boxManager = self.boxManager {
            let targetPosition = (boxManager.currentBox!.boxPosition + boxManager.nextBox!.boxPosition) * 0.5
            self.relativePosition = self.cameraNode.position - targetPosition
            let cameraNodePosition = self.cameraNode.position
            let lookAtMatrix = GLKMatrix4MakeLookAt(cameraNodePosition.x, cameraNodePosition.y, cameraNodePosition.z, targetPosition.x, targetPosition.y, targetPosition.z, 0, 1, 0)
            cameraNode.transform = SCNMatrix4FromGLKMatrix4(GLKMatrix4Invert(lookAtMatrix, nil))
        }
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        if let _ = self.player, let boxManager = self.boxManager {
            switch self.state {
            case .animateCameraToTarget(let beginPosition, let endPosition):
                animationElapsedTime += timeSinceLastUpdate
                var position = beginPosition + (endPosition - beginPosition) * Float(animationElapsedTime / animationDuration)
                if animationElapsedTime >= animationDuration {
                    position = endPosition
                    self.state = .waitingTargetMove
                }
                let cameraNodePosition = position + self.relativePosition
                let lookAtMatrix = GLKMatrix4MakeLookAt(cameraNodePosition.x, cameraNodePosition.y, cameraNodePosition.z, position.x, position.y, position.z, 0, 1, 0)
                cameraNode.transform = SCNMatrix4FromGLKMatrix4(GLKMatrix4Invert(lookAtMatrix, nil))
            default:
                break
            }
        }
    }

    func updateCamera() {
        if let _ = self.player, let boxManager = self.boxManager {
            let beginPosition = self.cameraNode.position - self.relativePosition
            let targetPosition = (boxManager.currentBox!.boxPosition + boxManager.nextBox!.boxPosition) * 0.5
            self.state = .animateCameraToTarget(beginPosition: beginPosition, endPosition: targetPosition)
            animationElapsedTime = 0
        }
    }

    func reset() {
        if let _ = self.player, let boxManager = self.boxManager {
            let position = (boxManager.currentBox!.boxPosition + boxManager.nextBox!.boxPosition) * 0.5
            let cameraNodePosition = position + self.relativePosition
            let lookAtMatrix = GLKMatrix4MakeLookAt(cameraNodePosition.x, cameraNodePosition.y, cameraNodePosition.z, position.x, position.y, position.z, 0, 1, 0)
            cameraNode.transform = SCNMatrix4FromGLKMatrix4(GLKMatrix4Invert(lookAtMatrix, nil))
        }
    }

    func rootNode() -> SCNNode {
        return cameraNode
    }
}
