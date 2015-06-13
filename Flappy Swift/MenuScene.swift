//
//  GameScene.swift
//  SwiftTeamSelect
//
//  Created by Kamil Burczyk on 16.06.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    enum Zone {
        case Left, Center, Right
    }
    
    var players = [SKSpriteNode]()
    
    var leftPlayer: SKSpriteNode?
    var centerPlayer: SKSpriteNode?
    var rightPlayer: SKSpriteNode?
    
    var textureCompare: SKSpriteNode?
    
    var leftGuide : CGFloat {
        return round(view!.bounds.width / 6.0)
    }
    
    var rightGuide : CGFloat {
        return view!.bounds.width - leftGuide
    }
    
    var gap : CGFloat {
        return (size.width / 2 - leftGuide) / 2
    }
    
    // Background
    var background: SKNode!
    let background_speed = 100.0
    
    // Initialization
    
    override init(size: CGSize) {
        super.init(size:size)
        createPlayers()
        centerPlayer = players[players.count/2]
        setLeftAndRightPlayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        placePlayersOnPositions()
        calculateZIndexesForPlayers()
        initBackground()
    }
    
    // MARK: - Background Functions
    func initBackground() {
        
        // 1
        background = SKNode()
        addChild(background)
        
        // 2
        for i in 0...2 {
            let tile = SKSpriteNode(imageNamed: "background")
            tile.anchorPoint = CGPointZero
            tile.position = CGPoint(x: CGFloat(i) * 640.0, y: 0.0)
            tile.name = "background"
            tile.zPosition = -10
            background.addChild(tile)
        }
        
    }
    
    func createPlayers() {
        
        let characters = ["baby1","greenguy1","man1"]
        
        for i in 0..<3 {
            
            var names = ["King","Baby","Bird Lover"]
            let player = SKSpriteNode(imageNamed: characters[i])
            player.size = CGSizeMake(100, 100)
            player.name = characters[i]
            
            players.append(player)
            
        }
    }
    
    func placePlayersOnPositions() {
        for i in 0..<players.count/2 {
            players[i].position = CGPointMake(leftGuide, size.height/2)
        }
        
        players[players.count/2].position = CGPointMake(size.width/2, size.height/2)
        
        for i in players.count/2 + 1..<players.count {
            players[i].position = CGPointMake(rightGuide, size.height/2)
        }
        
        for player in players {
            player.setScale(calculateScaleForX(player.position.x))
            self.addChild(player)
        }
        
    }
    
    
    // Helper functions
    
    func calculateScaleForX(x:CGFloat) -> CGFloat {
        let minScale = CGFloat(0.5)
        
        if x <= leftGuide || x >= rightGuide {
            return minScale
        }
        
        if x < size.width/2 {
            let a = 1.0 / (size.width - 2 * leftGuide)
            let b = 0.5 - a * leftGuide
            
            return (a * x + b)
        }
        
        let a = 1.0 / (frame.size.width - 2 * rightGuide)
        let b = 0.5 - a * rightGuide
        
        return (a * x + b)
    }
    
    func calculateZIndexesForPlayers() {
        var playerCenterIndex : Int = players.count / 2
        
        for i in 0..<players.count {
            if centerPlayer == players[i] {
                playerCenterIndex = i
            }
        }
        
        for i in 0...playerCenterIndex {
            players[i].zPosition = CGFloat(i)
        }
        
        for i in playerCenterIndex+1..<players.count {
            players[i].zPosition = centerPlayer!.zPosition * 2 - CGFloat(i)
        }
        
    }
    
    func movePlayerToX(player: SKSpriteNode, x: CGFloat, duration: NSTimeInterval) {
        let moveAction = SKAction.moveToX(x, duration: duration)
        let scaleAction = SKAction.scaleTo(calculateScaleForX(x), duration: duration)
        
        player.runAction(SKAction.group([moveAction, scaleAction]))
    }
    
    func movePlayerByX(player: SKSpriteNode, x: CGFloat) {
        let duration = 0.01
        
        if CGRectGetMidX(player.frame) <= rightGuide && CGRectGetMidX(player.frame) >= leftGuide {
            player.runAction(SKAction.moveByX(x, y: 0, duration: duration), completion: {
                player.setScale(self.calculateScaleForX(CGRectGetMidX(player.frame)))
            })
            
            if CGRectGetMidX(player.frame) < leftGuide {
                player.position = CGPointMake(leftGuide, player.position.y)
            } else if CGRectGetMidX(player.frame) > rightGuide {
                player.position = CGPointMake(rightGuide, player.position.y)
            }
        }
    }
    
    func zoneOfCenterPlayer() -> Zone {
        let gap = size.width / 2 - leftGuide
        
        switch CGRectGetMidX(centerPlayer!.frame) {
            
        case let x where x < leftGuide + gap/2:
            return .Left
            
        case let x where x > rightGuide - gap/2:
            return .Right
            
        default: return .Center
            
        }
    }
    
    func setLeftAndRightPlayers() {
        var playerCenterIndex : Int = players.count / 2
        
        for i in 0..<players.count {
            if centerPlayer == players[i] {
                playerCenterIndex = i
            }
        }
        
        if playerCenterIndex > 0 && playerCenterIndex < players.count {
            leftPlayer = players[playerCenterIndex-1]
        } else {
            leftPlayer = nil
        }
        
        if playerCenterIndex > -1 && playerCenterIndex < players.count-1 {
            rightPlayer = players[playerCenterIndex+1]
        } else {
            rightPlayer = nil
        }
    }
    
    
    
    // Touch interactions
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
//        let touch = touches.AnyObject() as! UITouch
        let node = self.nodeAtPoint(touch.locationInNode(self))
            let location = touch.locationInNode(self)

        textureCompare = SKSpriteNode(imageNamed: "man1")
            
        if CGRectContainsPoint(self.centerPlayer!.frame, location) {
           println( self.centerPlayer?.name )
            
            
            if self.centerPlayer!.name == "man1" {
                println("MAN BABY")
            }
            
            //            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
            let scene = GameScene(size: self.scene!.size)
            scene.scaleMode = SKSceneScaleMode.AspectFill
            
            //            self.scene!.view!.presentScene(scene, transition: transition)
            self.scene!.view!.presentScene(scene)
            
            }
        
        if node == centerPlayer {
            let fadeOut = SKAction.fadeAlphaTo(0.5, duration: 0.15)
            let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.15)
            
   
            centerPlayer!.runAction(fadeOut, completion: { self.centerPlayer!.runAction(fadeIn) })
        }

        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
//        let location = touch.locationInNode(self)
        let duration = 0.01
//        let touch = touches
        let newPosition = touch.locationInNode(self)
        let oldPosition = touch.previousLocationInNode(self)
        let xTranslation = newPosition.x - oldPosition.x
        
        
        if CGRectGetMidX(centerPlayer!.frame) > size.width/2 {
            if (leftPlayer != nil) {
                let actualTranslation = CGRectGetMidX(leftPlayer!.frame) + xTranslation > leftGuide ? xTranslation : leftGuide - CGRectGetMidX(leftPlayer!.frame)
                movePlayerByX(leftPlayer!, x: actualTranslation)
            }
        } else {
            if (rightPlayer != nil) {
                let actualTranslation = CGRectGetMidX(rightPlayer!.frame) + xTranslation < rightGuide ? xTranslation : rightGuide - CGRectGetMidX(rightPlayer!.frame)
                movePlayerByX(rightPlayer!, x: actualTranslation)
            }
        }
        
        movePlayerByX(centerPlayer!, x: xTranslation)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
//        let touch = touches.anyObject() as! UITouch
        let duration = 0.25
        
        switch zoneOfCenterPlayer() {
            
        case .Left:
            if (rightPlayer != nil) {
                movePlayerToX(centerPlayer!, x: leftGuide, duration: duration)
                if (leftPlayer != nil) {
                    movePlayerToX(leftPlayer!, x: leftGuide, duration: duration)
                }
                if (rightPlayer != nil) {
                    movePlayerToX(rightPlayer!, x: size.width/2, duration: duration)
                }
                
                centerPlayer = rightPlayer
                setLeftAndRightPlayers()
            } else {
                movePlayerToX(centerPlayer!, x: size.width/2, duration: duration)
            }
            
        case .Right:
            if (leftPlayer != nil) {
                movePlayerToX(centerPlayer!, x: rightGuide, duration: duration)
                if (rightPlayer != nil) {
                    movePlayerToX(rightPlayer!, x: rightGuide, duration: duration)
                }
                if (leftPlayer != nil) {
                    movePlayerToX(leftPlayer!, x: size.width/2, duration: duration)
                }
                
                centerPlayer = leftPlayer
                setLeftAndRightPlayers()
            } else {
                movePlayerToX(centerPlayer!, x: size.width/2, duration: duration)
            }
            
        case .Center:
            movePlayerToX(centerPlayer!, x: size.width/2, duration: duration)
            if (leftPlayer != nil) {
                movePlayerToX(leftPlayer!, x: leftGuide, duration: duration)
            }
            if (rightPlayer != nil) {
                movePlayerToX(rightPlayer!, x: rightGuide, duration: duration)
            }
        }
        
        calculateZIndexesForPlayers()
        }
    }
    
}