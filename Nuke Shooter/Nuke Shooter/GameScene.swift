//
//  GameScene.swift
//  Nuke Shooter
//
//  Created by Francesco Petrini on 7/19/17.
//  Copyright © 2017 Francesco Petrini. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0   //make the game score public to all files

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    var levelNumber = 0                 //globally defined variables
    var livesNumber = 3
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    let player = SKSpriteNode(imageNamed: "heroPlane.png")
   
    let bulletSound = SKAction.playSoundFileNamed("MachineGun.m4a", waitForCompletion: false)       //audio file initialization
    let explosionSound = SKAction.playSoundFileNamed("expl1.wav", waitForCompletion: false)
    
    enum gameState{
        case preGame    //start menu
        case inGame     //when the game is in progress
        case afterGame  //game over screen
    }
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories{
    
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4 -- (not 3 b/c that would represent the player & bulllet)
    }
    
    func randomTrajectory() -> CGFloat{                         //utility functions
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return randomTrajectory() * (max-min) + min
    }
    
    
    let gameBounds: CGRect              //set up universal game boundaries
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameBounds = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        
        gameScore = 0        //gameScore must be reinitialized otherwise the score will carry over to the next game
        self.physicsWorld.contactDelegate = self                    //initialize in game contact physics

        for i in 0...1{
            
            let background = SKSpriteNode(imageNamed: "background.png")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width / 2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        player.setScale(3)
        player.position = CGPoint(x: self.size.width / 2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/5)  //adding a physics body around player ship
        player.physicsBody!.affectedByGravity = false                   //unaffected by gravity
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)            //have labels glide onto the screen
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 125
        tapToStartLabel.fontColor = SKColor.black
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let removeLabel = SKAction.removeFromParent()
        let startGameSequence = SKAction.sequence([fadeOutAction, removeLabel])
        tapToStartLabel.run(startGameSequence)
        
        let moveShipToStartAction = SKAction.moveTo(y: self.size.height * 0.1, duration: 0.5)
        let startLevelAction = SKAction.run(levelUp)
        let gameOnSequence = SKAction.sequence([moveShipToStartAction, startLevelAction])
        player.run(gameOnSequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{           //places phyics bodies in numerical order
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{   //if enemy hits player
            
            if body1.node != nil{                               //make sure the node exists before passing its position to the Kaboom func
            spawnKaboom(spawnPosition: body1.node!.position)
            }
            if body2.node != nil{
            spawnKaboom(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && body2.node!.position.y < self.size.height && livesNumber != 0{
            //if bullet hits enemy, while the enemy is on screen
            
            if body2.node != nil{
            spawnKaboom(spawnPosition: body2.node!.position)
            }
            addScore()
            body1.node?.removeFromParent()  //these are optionals (i.e."node?") b/c, for example, if two bullets collide with on enemy..
            body2.node?.removeFromParent()  //the computer would attempt to delete the enemy twice ->crashing the game
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{     //variable is global so it is not set to zero at every iteration
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background"){
            background, stop in
            
            if self.currentGameState == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
        
    }
    
   
    func spawnKaboom(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explosion.png")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 2, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound,scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    func spawnBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.name = "Bullet"
        bullet.setScale(2)
        bullet.position = player.position
        bullet.zPosition = 1
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
       
        self.addChild(bullet)
        
        let fireBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, fireBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemies(){
        
        let randomXBegin = random(min: gameBounds.minX, max: gameBounds.maxX)
        let randomXEnd = random(min: gameBounds.minX, max: gameBounds.maxX)
        let start = CGPoint(x: randomXBegin, y: self.size.height * 1.2)
        let end = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyPlane")
        enemy.name = "Enemy"
        enemy.setScale(2)
        enemy.position = start
        enemy.zPosition = 2
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
       
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: end, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = end.x - start.x
        let dy = end.y - start.y
        let rotationAmount = atan2(dy, dx)      //rocket will rotate to face its trajectory
        enemy.zRotation = rotationAmount
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        
        else if currentGameState == gameState.inGame{
            spawnBullet()
        }
        
    }
    
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let after = touch.location(in: self)
            let before = touch.previousLocation(in: self)
            
            let distance = after.x - before.x
            if currentGameState == gameState.inGame{
                player.position.x += distance
                
                if player.position.x > gameBounds.maxX - player.size.width / 2{     //prevents half of player from leaving the screen
                    player.position.x = gameBounds.maxX - player.size.width / 2
                }
                if player.position.x < gameBounds.minX + player.size.width / 2{
                    player.position.x = gameBounds.minX + player.size.width / 2
                }
            }
        }
    }
    
    func levelUp(){
        
        levelNumber += 1
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        switch levelNumber{
            case 1: levelDuration = 0.1
            case 2: levelDuration = 1
            case 3: levelDuration = 0.8
            case 4: levelDuration = 0.5
            default:
                levelDuration = 0.5
                print("Can't find level info")
        }
        let spawn = SKAction.run(spawnEnemies)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnIndefinately = SKAction.repeatForever(spawnSequence)
        self.run(spawnIndefinately, withKey: "spawningEnemies")
    }
    

    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 20 || gameScore == 50{
            levelUp()
        }
    }
    
    func loseALife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        if livesNumber == 0{
            runGameOver()
        }
        
    }
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){       //find and cycle through all bullets removing all actions--making them stop
            bullet, stop in
            
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneAction = SKAction.run(changeScene)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene,changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene(){
        
        let sceneMoveTo = GameOverScene(size: self.size)
        sceneMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneMoveTo, transition: myTransition)
    }
    


}
