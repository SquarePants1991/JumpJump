//
// Created by yang wang on 2017/12/29.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit

protocol GameObject {
    func rootNode() -> SCNNode
    func update(timeSinceLastUpdate: TimeInterval)
}

extension GameObject {
    func addToNode(baseNode: SCNNode) {
        let node = self.rootNode()
        if node.parent != nil {
            node.removeFromParentNode()
        }
        baseNode.addChildNode(node)
    }

    func destroy() {
        let node = self.rootNode()
        if node.parent != nil {
            node.removeFromParentNode()
        }
    }
}