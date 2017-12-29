//
//  GameViewController.swift
//  BumpBump
//
//  Created by ocean on 2017/12/29.
//  Copyright © 2017年 ocean. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var softBox: SCNBox!
    var softBoxNode: SCNNode!
    var player: SCNCylinder!
    var playerNode: SCNNode!
    var scene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: -10, y: 10, z: 10)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
    
        // use default light
        
        scnView.backgroundColor = UIColor.black
        
        scene.rootNode.castsShadow = true
        
        createLight()
        createFloor()
        createSoftBox()
        createPlayer()
    }
    
    func createLight() {
        // Main light
        let mainLightNode = SCNNode()
        mainLightNode.light = SCNLight()
        mainLightNode.light?.type = .directional
        mainLightNode.light?.castsShadow = true
        mainLightNode.light?.color = UIColor.white
        mainLightNode.rotation = SCNVector4.init(1, -0.4, 0, -Float.pi / 3.7)
        scene.rootNode.addChildNode(mainLightNode)
        
    
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func createFloor() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.gray.cgColor
        
        let floor = SCNPlane.init(width: 50, height: 50)
        floor.materials = [material]
        let floorNode = SCNNode.init(geometry: floor)
        floorNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.scene.rootNode.addChildNode(floorNode)
        floorNode.castsShadow = false
    }
    
    func createSoftBox() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.cgColor
        self.softBox = SCNBox.init(width: 2, height: 1.4, length: 2, chamferRadius: 0)
        self.softBox.materials = [material]
        self.softBoxNode = SCNNode.init(geometry: self.softBox)
        self.softBoxNode.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
        self.scene.rootNode.addChildNode(self.softBoxNode)
    }
    
    func createPlayer() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green.cgColor
        self.player = SCNCylinder.init(radius: 0.2, height: 0.6)
        self.player.materials = [material]
        self.playerNode = SCNNode.init(geometry: self.player)
        self.playerNode.pivot = SCNMatrix4MakeTranslation(0, -0.3, 0)
        self.playerNode.position = SCNVector3.init(0, 1.4, 0)
        self.scene.rootNode.addChildNode(self.playerNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SCNTransaction.animationDuration = 0.3
        self.softBoxNode.scale = SCNVector3.init(1, 0.3, 1)
        self.playerNode.position = SCNVector3.init(0, 0.42, 0)
        self.playerNode.scale = SCNVector3.init(1, 0.5, 1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        SCNTransaction.animationDuration = 0.3
        self.softBoxNode.scale = SCNVector3.init(1, 1, 1)
        self.playerNode.position = SCNVector3.init(0, 1.4, 0)
        self.playerNode.scale = SCNVector3.init(1, 1, 1)
    }

}
