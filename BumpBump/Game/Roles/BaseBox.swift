//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit

class BaseBox: GameObject {
    var geometry: SCNGeometry!
    var scnNode: SCNNode!
    var boxPosition: SCNVector3 = SCNVector3.init(0, 0, 0)

    convenience init() {
        self.init(geometry: nil, position: nil)
    }

    init(geometry: SCNGeometry?, position: SCNVector3?) {
        self.boxPosition = position ?? SCNVector3.init(0, 0, 0)

        if geometry == nil {
            setupGeometryAndNode()
        } else {
            self.geometry = geometry
        }
    }

    func setupGeometryAndNode() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.randomColor().cgColor

        let boxSize: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max) * 0.4 + 0.4
        self.geometry = SCNBox.init(width: boxSize, height: 0.4, length: boxSize, chamferRadius: 0)
        self.geometry.materials = [material]

        self.scnNode = SCNNode.init(geometry: self.geometry)
        self.scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.2, 0)
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
