//
// Created by yang wang on 2017/12/29.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import GLKit
import UIKit

enum PlayerState: Int {
    case idle
    case jumping
    case landSuccess
    case landFailed
}

class Player: GameObject {
    private var scnNode: SCNNode!
    private var prepareJumpParticleSystem: SCNParticleSystem!

    // 运动相关
    private var verticalVelocity: Float = 0
    private var horizontalVelocity: Float = 0
    private var forwardVelocity: Float = 0
    private var verticalVector: SCNVector3 = SCNVector3.init(0, 1, 0)
    private var forwardVector: SCNVector3 = SCNVector3.init(1, 0, 0)

    public var gravity: Float = -40

    // 跳跃相关
    private var jumpingRotation: Float = 0
    private var beginJumpVelocity: Float = 0
    public var jumpForwardVector: SCNVector3 = SCNVector3.init(0, 0, 0)
    // 不想使用物理引擎，此处通过跳跃时传入下一个Box的顶部Y来确定何时结束跳跃
    public var groundY: Float = 0

    // 状态管理
    public var isOnGround: Bool = false
    public var state: PlayerState = .idle

    init() {
        setupGeometryAndNode()
    }

    convenience init(groundY: Float) {
        self.init()
        self.groundY = groundY
    }

    func setupGeometryAndNode() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.orange.cgColor
        material.lightingModel = .blinn
        material.ambient.contents = UIColor.orange.cgColor
        
//        let geometry = SCNCone.init(topRadius: 0.15, bottomRadius: 0.0, height: 0.7)
        // 根据我家老婆大人的指示，把它换成球
        let geometry = SCNSphere.init(radius: 0.1)
        geometry.materials = [material]


        scnNode = SCNNode.init(geometry: geometry)
        scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.1, 0)
        scnNode.castsShadow = true

        if let particleSystem = SCNParticleSystem.init(named: "prepare", inDirectory: "./") {
            self.prepareJumpParticleSystem = particleSystem
        }
    }

    func prepareJump() {
        if scnNode.particleSystems == nil {
            scnNode.addParticleSystem(self.prepareJumpParticleSystem)
        }
    }

    func jump(beginVelocity: (vertical: Float, horizontal: Float), forward: SCNVector3, groundY: Float) {
        if isOnGround {
            scnNode.removeAllParticleSystems()

            self.beginJumpVelocity = beginVelocity.vertical
            self.verticalVelocity = beginVelocity.vertical
            self.horizontalVelocity = beginVelocity.horizontal
            self.jumpForwardVector = forward
            self.jumpingRotation = 0
            self.groundY = groundY
            self.isOnGround = false
            self.state = .jumping
        }
    }

    func falldown(onTopCheckResult: OnTopCheckResult) {
        self.scnNode.rotation = SCNVector4.init(0, 0, 1, 0)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        let position = self.scnNode.position
        self.scnNode.position = SCNVector3.init(position.x, 0.0, position.z)
        self.scnNode.rotation = SCNVector4.init(0, 0, 1,  Float(onTopCheckResult.falldownSide.rawValue) * -90.0 / 180.0 * Float.pi)
        SCNTransaction.commit()
    }

    func reset() {
        verticalVelocity = 0
        horizontalVelocity = 0
        beginJumpVelocity = 0
        self.scnNode.position = SCNVector3.init(0.0 , self.groundY + 1.0, 0.0)
        self.scnNode.rotation = SCNVector4.init(0, 0, 1, 0)
        self.isOnGround = false
    }

    private func jumpRotateAxis() -> SCNVector3 {
        // 目前跳跃旋转轴只会在xz平面上，所以将跳跃方向的向量围绕y轴旋转90度就能得到跳跃旋转轴
        let glkForwardAxis = SCNVector3ToGLKVector3(jumpForwardVector)
        let forwardAxisRotation = GLKQuaternionMakeWithAngleAndAxis(Float.pi / 2.0, 0, 1, 0)
        let rotateAxis = GLKQuaternionRotateVector3(forwardAxisRotation, glkForwardAxis)
        return SCNVector3FromGLKVector3(rotateAxis)
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        if !isOnGround {
            var position = scnNode.position
            position += verticalVector * verticalVelocity * Float(timeSinceLastUpdate)
            position += jumpForwardVector * horizontalVelocity * Float(timeSinceLastUpdate)
            verticalVelocity += gravity * Float(timeSinceLastUpdate)

            // 只有跳起才能后空翻
            if beginJumpVelocity > 0 {
                // FIXME: 此处逻辑基于所有Box的高度时一致的，后期如果Box高度不一致需要修改
                if verticalVelocity > 0 {
                    jumpingRotation = 180.0 * (beginJumpVelocity - verticalVelocity) / beginJumpVelocity
                } else {
                    jumpingRotation = 180.0 * -verticalVelocity / beginJumpVelocity + 180.0
                }
                let rotateAxis = jumpRotateAxis()
                // TODO: 增加非线性的动画方案， 现在形状是球，所以别转了。。。
//                scnNode.rotation = SCNVector4.init(rotateAxis.x, rotateAxis.y, rotateAxis.z, jumpingRotation / 180.0 * Float.pi)
                // TODO: 怕自己看不懂，分步骤解答，用于弹跳过程中的伸缩计算，先伸展，然后回到初始状态
                var scaleFactor = 1.0 - jumpingRotation / 180.0 // -1 ~ 1
                scaleFactor = abs(scaleFactor) // 1 ~ 0 ~ 1
                scaleFactor = 1.0 - scaleFactor // 0 ~ 1 ~ 0
                scnNode.scale = SCNVector3.init(1, scaleFactor * 0.2 + 1.0, 1)
            }

            if position.y <= groundY && verticalVelocity < 0 {
                position.y = groundY
                verticalVelocity = 0
                horizontalVelocity = 0
                beginJumpVelocity = 0
                isOnGround = true
                scnNode.rotation = SCNVector4.init(1, 0, 0, 0)
            }

            scnNode.position = position
        }
    }

    func rootNode() -> SCNNode {
        return self.scnNode
    }
}
