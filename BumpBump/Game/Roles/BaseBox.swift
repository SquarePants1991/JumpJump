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
        material.lightingModel = .blinn
        material.shininess = 0.1

        self.geometry = SCNBox.init(width: 1.2, height: 0.8, length: 1.2, chamferRadius: 0)
        self.geometry.materials = [material]

        self.scnNode = SCNNode.init(geometry: self.geometry)
        self.scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.4, 0)
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
