//
//  GameOverScene.swift
//  Nuke Shooter
//
//  Created by Francesco Petrini on 8/7/17.
//  Copyright © 2017 Francesco Petrini. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.size = self.size
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.fontSize = 125
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.width * 0.45)
        highScoreLabel.zPosition = 1
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        self.addChild(highScoreLabel)
        
       
        restartLabel.text = "Restart"
        restartLabel.fontSize = 125
        restartLabel.fontColor = SKColor.black
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        let scaleUp = SKAction.scale(to: 2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        restartLabel.run(scaleSequence)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
                let sceneMoveTo = GameScene(size: self.size)
                sceneMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneMoveTo, transition: myTransition)
            }
        }
    }
}










