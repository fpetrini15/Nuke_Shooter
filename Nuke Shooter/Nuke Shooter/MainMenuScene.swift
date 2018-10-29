//
//  MainMenuScene.swift
//  Nuke Shooter
//
//  Created by Francesco Petrini on 8/8/17.
//  Copyright © 2017 Francesco Petrini. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene{
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 1
        background.size = self.size
        self.addChild(background)
        
        let gameByLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameByLabel.text = "Francesco Petrini's"
        gameByLabel.fontSize = 50
        gameByLabel.fontColor = SKColor.black
        gameByLabel.zPosition = 100
        gameByLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.78)
        self.addChild(gameByLabel)
        
        let gameNameFirstHalf = SKLabelNode(fontNamed: "The Bold Font")
        gameNameFirstHalf.text = "Nuke"
        gameNameFirstHalf.fontSize = 200
        gameNameFirstHalf.fontColor = SKColor.black
        gameNameFirstHalf.zPosition = 100
        gameNameFirstHalf.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
        self.addChild(gameNameFirstHalf)
        
        let gameNameSecondHalf = SKLabelNode(fontNamed: "The Bold Font")
        gameNameSecondHalf.text = "Shooter"
        gameNameSecondHalf.fontSize = 200
        gameNameSecondHalf.fontColor = SKColor.black
        gameNameSecondHalf.zPosition = 100
        gameNameSecondHalf.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.625)
        self.addChild(gameNameSecondHalf)
        
        let startGameLabel = SKLabelNode(fontNamed: "The Bold Font")
        startGameLabel.text = "Start Game"
        startGameLabel.fontSize = 150
        startGameLabel.fontColor = SKColor.black
        startGameLabel.zPosition = 100
        startGameLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        startGameLabel.name = "StartGameLabel"
        self.addChild(startGameLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            
            if nodeITapped.name == "StartGameLabel"{
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
        
        
        
    }
    
}
