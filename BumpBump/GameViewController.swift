//
//  GameViewController.swift
//  BumpBump
//
//  Created by ocean on 2017/12/29.
//  Copyright © 2017年 ocean. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit

enum GameState {
    case preparing
    case ready
    case running
    case over
}

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var softBox: SCNBox!
    var softBoxNode: SCNNode!
    var scene: SCNScene!

    var lastUpdateTime: TimeInterval = -1

    var game: Game!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameStartPanel: UIView!
    @IBOutlet weak var gameOverPanel: UIView!
    
    var isGameStarted: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        scene = SCNScene()

        // retrieve the SCNView
        let scnView = self.view as! SCNView

        // set the scene to the view
        scnView.scene = scene
        scnView.delegate = self

        // use default light

        scnView.backgroundColor = UIColor.white


        scene.rootNode.castsShadow = true
        scnView.rendersContinuously = true
        scnView.preferredFramesPerSecond = 120
        scnView.showsStatistics = true

        game = Game(scene: scene)

        scoreLabel.text = "\(game.score)"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.gameState == .ready || game.gameState == .over {
            if !isGameStarted {
                game.startGame()
                isGameStarted = true
            } else {
                game.restartGame()
            }
            game.gameState = .running
        } else if game.gameState == .running {
            game.inputController.begin()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        game.playerController.jump()
        game.inputController.end()
    }


    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if game.gameState == .running {

            var deltaTime = 0.0
            if lastUpdateTime < 0 {
                lastUpdateTime = time
            } else {
                deltaTime = time - lastUpdateTime
            }
            lastUpdateTime = time

            game.update(timeSinceLastUpdate: deltaTime)

            DispatchQueue.main.async {
                self.scoreLabel.text = "\(self.game.score)"
            }
        }
    }
    
    @IBAction func startGameButtonTapped(button: UIButton) {
        
    }
    
    @IBAction func continueGameButtonTapped(button: UIButton) {
        
    }
}
