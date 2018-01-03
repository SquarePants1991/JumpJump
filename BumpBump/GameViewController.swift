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
    @IBOutlet weak var newRecordLabel: UILabel!
    @IBOutlet weak var gameStartPanel: UIView!
    @IBOutlet weak var gameOverPanel: UIView!
    
    var isGameStarted: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        gameStartPanel.isHidden = false
        gameOverPanel.isHidden = true
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
        scnView.preferredFramesPerSecond = 60
//        scnView.showsStatistics = true

        game = Game.init(scene: scene, aspectRatio: Float(self.view.frame.size.width /  self.view.frame.size.height))

        scoreLabel.text = "\(game.score)"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.gameState == .running {
            game.inputController.begin()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.gameState == .running {
            game.playerController.jump()
            game.inputController.end()
        }
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
        } else if game.gameState == .over {
            self.game.gameState = .preparing
            DispatchQueue.main.async {
                self.gameStartPanel.isHidden = true
                self.gameOverPanel.isHidden = false
                if self.game.scoreController.isNewRecord(newScore: self.game.score) {
                    self.newRecordLabel.isHidden = false
                } else {
                    self.newRecordLabel.isHidden = true
                }
                self.game.scoreController.saveScore(newScore: self.game.score)
            }
        }
    }
    
    @IBAction func startGameButtonTapped(button: UIButton) {
        gameStartPanel.isHidden = true
        gameOverPanel.isHidden = true
        
        if game.gameState == .ready {
            game.startGame()
            game.gameState = .running
        }
    }
    
    @IBAction func continueGameButtonTapped(button: UIButton) {
        gameStartPanel.isHidden = true
        gameOverPanel.isHidden = true
        
        if game.gameState == .preparing {
            game.restartGame()
            game.gameState = .running
        }
    }
}
