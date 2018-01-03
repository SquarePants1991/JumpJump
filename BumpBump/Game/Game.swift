//
// Created by yang wang on 2017/12/31.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import UIKit

class Game {
    var scene: SCNScene!
    var aspectRatio: Float!

    var cameraNode: SCNNode!

    var floorNode: SCNNode!

    var player: Player!

    var gameState: GameState = .ready

    var score: Int = 0

    // Controllers
    var boxController: BoxController!
    var playerController: PlayerController!
    var cameraController: CameraController!
    var inputController: PressInputController!
    var scoreController: ScoreController = ScoreController()

    init(scene: SCNScene, aspectRatio: Float) {
        self.scene = scene
        self.aspectRatio = aspectRatio

        setupCamera()
        setupMainScene()

        setupBoxController()
        setupPlayerController()
        setupCameraController()
        setupInputController()
    }
    
    func syncAspectRatio(_ aspectRatio: Float) {
        self.aspectRatio = aspectRatio
        
    }

    func setupCamera() {
        self.cameraNode = SCNNode()
        self.cameraNode.camera = SCNCamera()
        let perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(38), self.aspectRatio, 0.1, 1000)
        self.cameraNode.camera!.projectionTransform = SCNMatrix4FromGLKMatrix4(perspectiveMatrix)
        scene.rootNode.addChildNode(self.cameraNode)

        let lookAtMatrix = GLKMatrix4MakeLookAt(-2.6, 3.8, 3.2, 0, 0, 0, 0, 1, 0)
        let cameraTransform = GLKMatrix4Invert(lookAtMatrix, nil)
        cameraNode.transform = SCNMatrix4FromGLKMatrix4(cameraTransform)
    }

    func startGame() {
        // 按照依赖次序配置
        boxController.resetBoxes()
        playerController.setupEnvironment(boxController: self.boxController, inputController: self.inputController)
        cameraController.setupTarget(player: self.player, boxManager: self.boxController)
    }

    func restartGame() {
        // TODO: use controller to manage this
        self.score = 0

        boxController.resetBoxes()
        player.reset()
        cameraController.reset()
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        let controllers: [ControllerProtocol] = [inputController, boxController, playerController, cameraController]
        for controller in controllers {
            controller.update(timeSinceLastUpdate: timeSinceLastUpdate)
        }

        // tmp code sync floor & player
        let playerPos = player.rootNode().position
        floorNode.position = SCNVector3.init(playerPos.x, floorNode.position.y, playerPos.z)

        // TODO: 优化解耦此处代码堆。。。。
        let playerCollider = BoxCollider.fromSCNNode(scnNode: player.rootNode())
        var onTopCheckResult: OnTopCheckResult? = nil
        for box in self.boxController.boxObjects {
            let boxCollider = BoxCollider.fromSCNNode(scnNode: box.rootNode())
            if self.player.isOnGround {
                var checkResult: OnTopCheckResult = OnTopCheckResult(isOnTop: false, falldownSide: .forward, distance: 0)
                if playerCollider.isOnTheTopOfCollider(bottomOne: boxCollider, result: &checkResult, forwardVector: player.jumpForwardVector) == false {
                    if onTopCheckResult == nil {
                        onTopCheckResult = checkResult
                    } else if checkResult.distance < onTopCheckResult!.distance {
                        onTopCheckResult = checkResult
                    }
                } else {
                    player.state = .landSuccess

                    onTopCheckResult = nil
                    if let nextBox = self.boxController.nextBox, nextBox === box {
                        self.boxController.createNextBox()
                        self.cameraController.updateCamera()
                        self.score += 1
                    }
                    break
                }
            }
        }
        if onTopCheckResult != nil {
            self.player.falldown(onTopCheckResult: onTopCheckResult!)
            self.player.state = .landFailed
            self.gameState = .over
        }
    }
}

// Setup main scene
extension Game {
    func setupMainScene() {
        createFloor()
        createLight()
        createPlayer()
    }

    func createFloor() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.cgColor
        material.lightingModel = .constant
        material.writesToDepthBuffer = true
//        material.colorBufferWriteMask

        let floor = SCNPlane.init(width: 20, height: 20)
        floor.materials = [material]
        floorNode = SCNNode.init(geometry: floor)
        floorNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.scene.rootNode.addChildNode(floorNode)
        floorNode.castsShadow = true
    }

    func createLight() {
        // Main light
        let mainLightNode = SCNNode()
        mainLightNode.light = SCNLight()
        mainLightNode.light?.type = .directional
        mainLightNode.light?.castsShadow = true
        mainLightNode.light?.color = UIColor.init(white: 1.0, alpha: 1.0)
        // 深入了解一下不同的Shadow模式
        // FIXME: 有自阴影的问题
        #if !(arch(i386) || arch(x86_64))
            mainLightNode.light?.shadowMode = .deferred
        #endif
        mainLightNode.light?.shadowColor = UIColor.init(white: 0.0, alpha: 0.15).cgColor
        mainLightNode.rotation = SCNVector4.init(1, -0.4, 0, -Float.pi / 3.3)
        scene.rootNode.addChildNode(mainLightNode)


        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.init(white: 0.6, alpha: 1.0).cgColor
        scene.rootNode.addChildNode(ambientLightNode)
    }

    func createPlayer() {
        player = Player()
        player.addToNode(baseNode: self.scene.rootNode)
    }
}

// Setup Box Controller & Prepare Boxes
extension Game {
    func setupBoxController() {
        self.boxController = BoxController.init(scene: self.scene)
    }
}

// Setup Camera Controller
extension Game {
    func setupCameraController() {
        self.cameraController = CameraController.init(cameraNode: self.cameraNode)
    }
}

// Player Controller
extension Game {
    func setupPlayerController() {
        self.playerController = PlayerController.init(player: self.player)
    }
}

// Input Controller
extension Game {
    func setupInputController() {
        self.inputController = PressInputController()
    }
}
