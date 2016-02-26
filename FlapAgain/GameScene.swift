//
//  GameScene.swift
//  FlapAgain
//
//  Created by Diego Gomes on 18/12/2015.
//  Copyright (c) 2015 Nylon. All rights reserved.
//

import SpriteKit

struct phisicCategory {
    
    static let Ghost: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall: UInt32 = 0x1 << 3
    static let Score: UInt32 = 01 << 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    var imageBkg = SKSpriteNode(imageNamed: "img.png")
    
    var WallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLbl = SKLabelNode()
    
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene(){
        //print for see fonts family that you can use
        //print(UIFont.familyNames())
        
        self.physicsWorld.contactDelegate = self
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 70
        self.addChild(scoreLbl)
        
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        self.addChild(Ground)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = phisicCategory.Ground
        Ground.physicsBody?.collisionBitMask = phisicCategory.Ghost
        Ground.physicsBody?.contactTestBitMask = phisicCategory.Wall
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        //imaage ghost start here
        Ghost = SKSpriteNode(imageNamed: "Ghost")
        Ghost.size = CGSize(width: 60, height: 70)
        Ghost.position = CGPoint(x: self.frame.width / 2 - Ghost.frame.width, y: self.frame.height / 2)
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = phisicCategory.Ghost
        Ghost.physicsBody?.collisionBitMask = phisicCategory.Wall | phisicCategory.Ghost
        Ghost.physicsBody?.contactTestBitMask = phisicCategory.Wall | phisicCategory.Ghost | phisicCategory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.dynamic = true
        
        Ghost.zPosition = 2
        
        //img of bkg
        imageBkg.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        
        self.addChild(Ghost)
        // self.addChild(imageBkg)
    
    }
    
    override func didMoveToView(view: SKView) {
        createScene()
    }
    
    func createBTN(){
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.runAction(SKAction.scaleTo(1.0,duration: 0.3))
    
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firsBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firsBody.contactTestBitMask == phisicCategory.Score && secondBody.categoryBitMask == phisicCategory.Ghost || firsBody.contactTestBitMask == phisicCategory.Ghost && secondBody.categoryBitMask == phisicCategory.Score {
            
            score++
            scoreLbl.text = "\(score)"
            
        }
        
        if firsBody.categoryBitMask == phisicCategory.Ghost && secondBody.categoryBitMask == phisicCategory.Wall || firsBody.categoryBitMask == phisicCategory.Wall && secondBody.categoryBitMask == phisicCategory.Ghost {
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false {
                 died = true
                createBTN()
            }
        }
        
        if firsBody.categoryBitMask == phisicCategory.Ghost && secondBody.categoryBitMask == phisicCategory.Ground || firsBody.categoryBitMask == phisicCategory.Wall && secondBody.categoryBitMask == phisicCategory.Ghost {
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false {
                died = true
                createBTN()
            }
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false{
            
            //game need be true cause false game never started
            gameStarted = true
            
            Ghost.physicsBody?.affectedByGravity = true
            
            let span = SKAction.runBlock({
                
                () in
                self.createWalls()
                
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let spanDelay = SKAction.sequence([span,delay])
            let spanDelayForever = SKAction.repeatActionForever(spanDelay)
            
            self.runAction(spanDelayForever)
            
            let distance = CGFloat(self.frame.width + WallPair.frame.width)
            let movePipe = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipe = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([movePipe,removePipe])
            
            Ghost.physicsBody?.velocity = CGVectorMake(0,0)
            Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
        
        }else{
            
            if died == true{
                
                
                
            }else{
                Ghost.physicsBody?.velocity = CGVectorMake(0,0)
                Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            }
        }
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if died == true{
                if restartBTN.containsPoint(location){
                    restartScene()
                }
            }
        }
    }
    
    func createWalls(){
    
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = phisicCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = phisicCategory.Ghost
        scoreNode.color = SKColor.blueColor()
        
        
        WallPair = SKNode()
        WallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        
        topWall.physicsBody?.categoryBitMask = phisicCategory.Wall
        topWall.physicsBody?.collisionBitMask = phisicCategory.Ghost
        topWall.physicsBody?.contactTestBitMask = phisicCategory.Ghost
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = phisicCategory.Wall
        btmWall.physicsBody?.collisionBitMask = phisicCategory.Ghost
        btmWall.physicsBody?.contactTestBitMask = phisicCategory.Ghost
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        WallPair.addChild(topWall)
        WallPair.addChild(btmWall)
        WallPair.addChild(scoreNode)
        
        
        WallPair.zPosition = 1
        
        //random
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        WallPair.position.y = WallPair.position.y + randomPosition
        
        WallPair.runAction(moveAndRemove)
        
        self.addChild(WallPair)
    }
    override func  update(currentTime: NSTimeInterval) {
        
    }
}
