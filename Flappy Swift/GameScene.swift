//
//  GameScene.swift
//  Flappy Swift
//
//  Created by Julio Montoya on 13/07/14.
//  Copyright (c) 2015 Julio Montoya. All rights reserved.
//
//  Copyright (c) 2015 AvionicsDev
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import SpriteKit
import AVFoundation

// Math Helpers
extension Float {
  static func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
    if (value > max) {
      return max
    } else if (value < min) {
      return min
    } else {
      return value
    }
  }
    
  static func range(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
  }
}

extension CGFloat {
    func degrees_to_radians() -> CGFloat {
        return CGFloat(M_PI) * self / 180.0
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Bird
    var bird: SKSpriteNode!
    var inAir = "false"
    var audioPlayer : AVAudioPlayer!
    

//    var coin: SKSpriteNode!
    
    // Background
    var background: SKNode!
    let background_speed = 100.0
    
    // Score
    var score = 0
    var highscore = 0
    var label_score: SKLabelNode!
    var high_score : SKLabelNode!
    
    // Instructions
    var instructions: SKSpriteNode!
    
    // Pipe Origin
    let pipe_origin_x: CGFloat = 382.0
    
    // Time Values
    var delta = NSTimeInterval(0)
    var last_update_time = NSTimeInterval(0)
    
    // Floor height
    let floor_distance: CGFloat = 72.0
    
    // Physics Categories
    let FSBoundaryCategory: UInt32 = 1 << 0
    let FSPlayerCategory: UInt32   = 1 << 1
    let FSPipeCategory: UInt32     = 1 << 2
    let FSGapCategory: UInt32      = 1 << 3
    let FSCoinCategory: UInt32     = 1 << 4
    let FSMegaCoinCategory: UInt32 = 1 << 5
    let FSUltraCoinCategory: UInt32 = 1 << 6
    
    // 1
    enum FSGameState: Int {
        case FSGameStateStarting
        case FSGameStatePlaying
        case FSGameStateEnded
    }
    
    // 2
    var state:FSGameState = .FSGameStateStarting
    
  // MARK: - SKScene Initializacion
  override func didMoveToView(view: SKView) {
    initWorld()
    
    initBackground()
    
    initBird()
    
    initHUD()
    
    createCoin()
    createMegaCoin()
    createUltraCoin()
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.runBlock(createCoin),
            SKAction.waitForDuration(0.3)
            ])
        ))
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.runBlock(createMegaCoin),
            SKAction.waitForDuration(3.0)
            ])
        ))
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.runBlock(createUltraCoin),
            SKAction.waitForDuration(6.0)
            ])
        ))
    
//    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.runBlock { self.initPipes()}])))
    
  }
    
  // MARK: - Init Physics
  func initWorld() {
    
    // 1
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
    physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0.0, y: floor_distance, width: size.width, height: size.height - floor_distance))
    physicsBody?.categoryBitMask = FSBoundaryCategory
    physicsBody?.collisionBitMask = FSPlayerCategory
    
  }
    
  // MARK: - Init Bird
  func initBird() {
    
    bird = SKSpriteNode(imageNamed: "bird1")
    bird.position = CGPoint(x: self.size.width/2, y: 72)
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2.5)
    bird.physicsBody?.categoryBitMask = FSPlayerCategory
    bird.physicsBody?.contactTestBitMask = FSPipeCategory | FSGapCategory | FSBoundaryCategory
    bird.physicsBody?.collisionBitMask = FSPipeCategory | FSBoundaryCategory
    // 1
    bird.physicsBody?.affectedByGravity = false
    bird.physicsBody?.allowsRotation = false
    bird.physicsBody?.restitution = 0.0
    bird.zPosition = 50
    bird.size = CGSize(width: 34*0.9, height: 44*0.9)
    addChild(bird)
    
    let texture1 = SKTexture(imageNamed: "man1")
    let texture2 = SKTexture(imageNamed: "man2")
    let texture3 = SKTexture(imageNamed: "man3")
    let texture4 = SKTexture(imageNamed: "man4")
    let textures = [texture1, texture2, texture3, texture4]
    
    bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.2)))
  }
    
  // MARK: - Background Functions
  func initBackground() {
    
    // 1
    background = SKNode()
    addChild(background)
    
    // 2
    for i in 0...2 {
        let tile = SKSpriteNode(imageNamed: "bg")
        tile.anchorPoint = CGPointZero
        tile.position = CGPoint(x: CGFloat(i) * 640.0, y: 0.0)
        tile.name = "bg"
        tile.zPosition = 10
        background.addChild(tile)
    }

  }
    
  func moveBackground() {
    
    // 3
    let posX = -background_speed * delta
    background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0)
    
    // 4
    background.enumerateChildNodesWithName("bg") { (node, stop) in
        let background_screen_position = self.background.convertPoint(node.position, toNode: self)
        
        if background_screen_position.x <= -node.frame.size.width {
            node.position = CGPoint(x: node.position.x + (node.frame.size.width * 2), y: node.position.y)
        }
        
    }

  }
    
  // MARK: - Pipes Functions
  func initPipes() {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let isWideScreen: Bool = (screenSize.height > 480)
    // 1
    let bottom = getPipeWithSize(CGSize(width: 62, height: Float.range(40, max: isWideScreen ? 360 : 280)), side: false)
    bottom.position = convertPoint(CGPoint(x: pipe_origin_x, y: CGRectGetMinY(frame) + bottom.size.height/2 + floor_distance), toNode: background)
    bottom.physicsBody = SKPhysicsBody(rectangleOfSize: bottom.size)
    bottom.physicsBody?.categoryBitMask = FSPipeCategory;
    bottom.physicsBody?.contactTestBitMask = FSPlayerCategory;
    bottom.physicsBody?.collisionBitMask = FSPlayerCategory;
    bottom.physicsBody?.dynamic = false
    bottom.zPosition = 20
    background.addChild(bottom)
    
    
    // 2
    let threshold = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: 10, height: 100))
    threshold.position = convertPoint(CGPoint(x: pipe_origin_x, y: floor_distance + bottom.size.height + threshold.size.height/2), toNode: background)
    threshold.physicsBody = SKPhysicsBody(rectangleOfSize: threshold.size)
    threshold.physicsBody?.categoryBitMask = FSGapCategory
    threshold.physicsBody?.contactTestBitMask = FSPlayerCategory
    threshold.physicsBody?.collisionBitMask = 0
    threshold.physicsBody?.dynamic = false
    threshold.zPosition = 20
    background.addChild(threshold)
    
    // 3
    let topSize = size.height - bottom.size.height - threshold.size.height - floor_distance
    
    // 4
    let top = getPipeWithSize(CGSize(width: 62, height: topSize), side: true)
    top.position = convertPoint(CGPoint(x: pipe_origin_x, y: CGRectGetMaxY(frame) - top.size.height/2), toNode: background)
    top.physicsBody = SKPhysicsBody(rectangleOfSize: top.size)
    top.physicsBody?.categoryBitMask = FSPipeCategory;
    top.physicsBody?.contactTestBitMask = FSPlayerCategory;
    top.physicsBody?.collisionBitMask = FSPlayerCategory;
    top.physicsBody?.dynamic = false
    top.zPosition = 20
    background.addChild(top)

  }
    
  func getPipeWithSize(size: CGSize, side: Bool) -> SKSpriteNode {
    // 1
    let textureSize = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    let backgroundCGImage = UIImage(named: "pipe")!.CGImage
    
    // 2
    UIGraphicsBeginImageContext(size)
    let context = UIGraphicsGetCurrentContext()
    CGContextDrawTiledImage(context, textureSize, backgroundCGImage)
    let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // 3
    let backgroundTexture = SKTexture(CGImage: tiledBackground.CGImage)
    let pipe = SKSpriteNode(texture: backgroundTexture)
    pipe.zPosition = 1
    
    // 4
    let cap = SKSpriteNode(imageNamed: "bottom")
    cap.position = CGPoint(x: 0.0, y: side ? -pipe.size.height/2 + cap.size.height/2 : pipe.size.height/2 - cap.size.height/2)
    cap.zPosition = 5
    pipe.addChild(cap)
    
    // 5
    if side == true {
        let angle:CGFloat = 180.0
        cap.zRotation = angle.degrees_to_radians()
    }
    
    return pipe
  }
    
    // MARK: - Score
    
    func initHUD() {
        
        
        // 1
        high_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        high_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 50)
        high_score.text = "0"
        high_score.zPosition = 50
        addChild(high_score)
        
        // 1
        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "0"
        label_score.zPosition = 50
        addChild(label_score)
        
        // 2
        instructions = SKSpriteNode(imageNamed: "TapToStart")
        instructions.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 10)
        instructions.zPosition = 50
        addChild(instructions)
    }
    
  // MARK: - Game Over helpers
  func gameOver() {
    
    
    // 1
    state = .FSGameStateEnded
    
    // 2
    bird.physicsBody?.categoryBitMask = 0
    bird.physicsBody?.collisionBitMask = FSBoundaryCategory
    
    // 3
    var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("restartGame"), userInfo: nil, repeats: false)
    
  }
    
  func restartGame() {
    
    // 5
    state = .FSGameStateStarting
    bird.removeFromParent()
    background.removeAllChildren()
    background.removeFromParent()
    
    // 6
    instructions.hidden = false
    removeActionForKey("generator")
    
    // 7
    score = 0
    label_score.text = "0"
    
    // 8
    initBird()
    initBackground()
    
  }
    
  // MARK: - SKPhysicsContactDelegate
  func didBeginContact(contact: SKPhysicsContact) {
    
    let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
    
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
    } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
    }
    
    // 1
    if collision == (FSPlayerCategory | FSGapCategory) {
        score++
        label_score.text = "\(score)"
    }
    
    // 2
    if collision == (FSPlayerCategory | FSPipeCategory) {
        gameOver()
    }
    
    // 3
    if collision == (FSPlayerCategory | FSBoundaryCategory) {
        
        
        if highscore <= score && score != 0 {
            
            highscore = score
            high_score.text = "\(score)"
        }
        println("hitground")
        score = 0
        label_score.text = "\(score)"
        
        if bird.position.y < 150 {
//            gameOver()
        }
    }
    
    if collision == (FSPlayerCategory | FSCoinCategory) {
        
        score++
        label_score.text = "\(score)"
        removeCoin(secondBody.node as SKSpriteNode)
        println("GOT COIN")
//        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
//        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//        AVAudioSession.sharedInstance().setActive(true, error: nil)
//        
//        var error:NSError?
//        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
//        audioPlayer.prepareToPlay()
//        audioPlayer.play()
        
    }
    
    if collision == (FSPlayerCategory | FSMegaCoinCategory) {
        
        score+=10
        label_score.text = "\(score)"
        removeCoin(secondBody.node as SKSpriteNode)
        println("GOT MEGA COIN")
//        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
//        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//        AVAudioSession.sharedInstance().setActive(true, error: nil)
//        
//        var error:NSError?
//        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
//        audioPlayer.prepareToPlay()
//        audioPlayer.play()
        
    }
    if collision == (FSPlayerCategory | FSUltraCoinCategory) {
        
        score+=25
        label_score.text = "\(score)"
        removeCoin(secondBody.node as SKSpriteNode)
        println("GOT MEGA COIN")
        //        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
        //        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        //        AVAudioSession.sharedInstance().setActive(true, error: nil)
        //
        //        var error:NSError?
        //        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        //        audioPlayer.prepareToPlay()
        //        audioPlayer.play()
        
    }
    
  }
    
    func removeCoin (coin:SKSpriteNode) {
        
        coin.removeFromParent()
        
    }
    
  // MARK: - Touch Events
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    
    // 1
    if state == .FSGameStateStarting {
        state = .FSGameStatePlaying
        
        instructions.hidden = true
        
        bird.physicsBody?.affectedByGravity = true
//        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25))
        
        
//        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.runBlock { self.initPipes()}])), withKey: "generator")
    }
        
        // 2
    else if state == .FSGameStatePlaying {
        
        if inAir == "true" {
            
            
            
        }else {
            inAir = "true"
           bird.runAction(SKAction.rotateByAngle(CGFloat(-M_PI*2), duration: 0.5))
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 14))
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("notInAir"), userInfo: nil, repeats: false)

        }
    }
    
  }
    
    func notInAir() {
        
//        bird.r
        inAir = "false"
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func createCoin() {
        
        
        let coin = SKSpriteNode(imageNamed: "bird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 132)
        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(10.0), max: CGFloat(20.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 132), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: nil)
        }
        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        
    }
    
    func createMegaCoin() {
        
        let coin = SKSpriteNode(imageNamed: "bird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSMegaCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 232)
        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 50, height: 50)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(10.0), max: CGFloat(20.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 232), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        
    }
    
    func createUltraCoin() {
        
        let coin = SKSpriteNode(imageNamed: "bird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSUltraCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 402)
        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 10, height: 10)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(10.0), max: CGFloat(20.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 402), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        
    }

    
  // MARK: - Frames Per Second
  override func update(currentTime: CFTimeInterval) {
    
    delta = (last_update_time == 0.0) ? 0.0 : currentTime - last_update_time
    last_update_time = currentTime
    
    // 1
    if state != .FSGameStateEnded {
        moveBackground()
        
        let velocity_x = bird.physicsBody?.velocity.dx
        let velocity_y = bird.physicsBody?.velocity.dy
        
//        if bird.physicsBody?.velocity.dy > 280 {
//            bird.physicsBody?.velocity = CGVector(dx: velocity_x!, dy: 280)
//        }
        
//        bird.zRotation = Float.clamp(-1, max: 0.0, value: velocity_y! * (velocity_y < 0 ? 0.003 : 0.001))
    } else {
        // 2
        bird.zRotation = CGFloat(M_PI)
        bird.removeAllActions()
    }

  }
}
