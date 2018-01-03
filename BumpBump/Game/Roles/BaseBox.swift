//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit

class BaseBox: GameObject {
    var geometry: SCNGeometry!
    var scnNode: SCNNode!
    var boxPosition: SCNVector3 = SCNVector3.init(0, 0, 0)
    var boxSize: Float = 0
    
    init(geometry: SCNGeometry? = nil, position: SCNVector3? = nil, size: Float? = nil) {
        self.boxPosition = position ?? SCNVector3.init(0, 0, 0)
        self.boxSize = size ?? Float(arc4random()) / Float(UInt32.max) * 0.4 + 0.4
        
        if geometry == nil {
            setupGeometryAndNode()
        } else {
            self.geometry = geometry
        }
    }

    func setupGeometryAndNode() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.randomColor().cgColor

        self.geometry = SCNBox.init(width: CGFloat(self.boxSize), height: 0.3, length: CGFloat(self.boxSize), chamferRadius: 0)
        self.geometry.materials = [material]

        self.scnNode = SCNNode.init(geometry: self.geometry)
        self.scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.15, 0)
        self.scnNode.position = self.boxPosition
    }

    func update(timeSinceLastUpdate: TimeInterval) {

    }

    func rootNode() -> SCNNode {
        return self.scnNode
    }

    func topY() -> Float {
        let topY =  geometry.boundingBox.max.y - geometry.boundingBox.min.y + self.scnNode.position.y
        return topY
    }


}
