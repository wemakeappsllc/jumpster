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
import iAd

// Math Helpers

extension SKAction {
    static func oscillation(amplitude a: CGFloat, timePeriod t: CGFloat, midPoint: CGPoint) -> SKAction {
        let action = SKAction.customActionWithDuration(Double(t)) { node, currentTime in
            let displacement = a * sin(2 * 3.14 * currentTime / t)
            node.position.y = midPoint.y + displacement
        }
        
        return action
    }
}

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

class GameScene: SKScene, SKPhysicsContactDelegate, ADBannerViewDelegate {
    
    
    //SOUNDS
    
    var playSoundEffect: SKAction!
    var playHighScoreEffect: SKAction!
    var playBackgroundMusic: SKAction!
    
    // Ad Banner
    var adBannerView : ADBannerView?
    
    // Option Button
    
    var optionButton: SKSpriteNode!
    var optionView: UIView!
    
    
    // Baby
    
    var baby: SKSpriteNode!
    // Bird
    var bird: SKSpriteNode!
    var inAir = "false"
    var audioPlayer : AVAudioPlayer!
    
    var jumpcount : Int?
    

//    var coin: SKSpriteNode!
    
    // Background
    var background: SKNode!
    let background_speed = 100.0
    
    // Score
    var score = 0
    var highscore = 0
    var totalscore = 0
    var label_score: SKLabelNode!
    var high_score : SKLabelNode!
    var total_score : SKLabelNode!
    
    //HUD
    var birdHudNode : SKSpriteNode!

    
    // Instructions
    var instructions: SKSpriteNode!
    
    // Pipe Origin
    let pipe_origin_x: CGFloat = 382.0
    
    // Time Values
    var delta = NSTimeInterval(0)
    var last_update_time = NSTimeInterval(0)
    
    // Floor height
    let floor_distance: CGFloat = 72.0
    var floorNode: SKSpriteNode!
    
    // Physics Categories
    let FSBoundaryCategory: UInt32 = 1 << 0
    let FSPlayerCategory: UInt32   = 1 << 1
    let FSPipeCategory: UInt32     = 1 << 2
    let FSGapCategory: UInt32      = 1 << 3
    let FSCoinCategory: UInt32     = 1 << 4
    let FSMegaCoinCategory: UInt32 = 1 << 5
    let FSUltraCoinCategory: UInt32 = 1 << 6
    let FSImpossibleCoinCategory: UInt32 = 1 << 7
    let FSFloorCategory: UInt32 = 1 << 8
    let FSRareBirdCategory: UInt32 = 1 << 9
    let FSYellowCategory: UInt32 = 1 << 10
    
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
    
    NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: "becameActive:",
        name: UIApplicationDidBecomeActiveNotification,
        object: nil)
    
    playSoundEffect = SKAction.playSoundFileNamed("SFX_Powerup_49.wav", waitForCompletion: false)
    playHighScoreEffect = SKAction.playSoundFileNamed("SFX_Powerup_34.wav", waitForCompletion: true)
    playBackgroundMusic = SKAction.playSoundFileNamed("bossfight.mp3", waitForCompletion: true)
    
            var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bossfight", ofType: "mp3")!)
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
    
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
    
    state = .FSGameStatePlaying
    
    initWorld()
    
    initBackground()
    
    initBird()

    
    initHUD()
    
//    createCoin()
//    createMegaCoin()
//    createUltraCoin()
//    createImpossibleCoin()
    
    initFloor()
    
    initOptionButton()
    initOptionMenu()
    
//    loadAds()
    
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.runBlock(createCoin),
            SKAction.waitForDuration(0.3)
            ])
        ))
    
//    runAction(SKAction.repeatActionForever(
//        SKAction.sequence([
//            SKAction.runBlock(createPurpleBird),
//            SKAction.waitForDuration(0.6)
//            ])
//        ))
    
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
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.runBlock(createImpossibleCoin),
            SKAction.waitForDuration(10.0)
            ])
        ))
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.waitForDuration(100.0),
            SKAction.runBlock(createRareBird),
            SKAction.waitForDuration(100.0)
            ])
        ))
    
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.waitForDuration(20.0),
            SKAction.runBlock(rareBirdFrenzy),
            SKAction.waitForDuration(25.0)
            ])
        ))
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.waitForDuration(10.0),
            SKAction.runBlock(speedsterSpotted),
            SKAction.waitForDuration(10.0)
            ])
        ))
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.waitForDuration(14.0),
            SKAction.runBlock(brownBirdChaos),
            SKAction.waitForDuration(11.0)
            ])
        ))
    
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
            SKAction.waitForDuration(43.0),
            SKAction.runBlock(rainbowCircus),
            SKAction.waitForDuration(34.0)
            ])
        ))
    
    // 3
    var timer = NSTimer.scheduledTimerWithTimeInterval(107.0, target: self, selector: Selector("newFlock"), userInfo: nil, repeats: false)
    
    // 3
    var timerYellow = NSTimer.scheduledTimerWithTimeInterval(211.0, target: self, selector: Selector("newFlock2"), userInfo: nil, repeats: false)
    
//    // 3 TEST METHOD
//    var timerYellow = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("newFlock2"), userInfo: nil, repeats: false)
    
    var timerThomas = NSTimer.scheduledTimerWithTimeInterval(143.0, target: self, selector: Selector("thomasSighting"), userInfo: nil, repeats: true)
    
    var timerMysterious = NSTimer.scheduledTimerWithTimeInterval(247.0, target: self, selector: Selector("mysteryBirds"), userInfo: nil, repeats: true)
    
//    runAction(SKAction.repeatActionForever(playBackgroundMusic))
    
    
//    var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
//    AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//    AVAudioSession.sharedInstance().setActive(true, error: nil)
//    
//    var error:NSError?
//    audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
//    audioPlayer.stop()
//    audioPlayer.prepareToPlay()
    
//    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.runBlock { self.initPipes()}])))
    
  }
    func rainbowCircus() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
        //    label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        //    label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "Catch The Rainbow"
        //    label_score.zPosition = 701
        //    label_score.hidden = false
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(createRainbow),
                SKAction.waitForDuration(0.6)
                ]),count: 1
            ))
        
        
    }
    
    func mysteryBirds() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
        //    label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        //    label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "Pájaros Misteriosos"
        //    label_score.zPosition = 701
        //    label_score.hidden = false
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(createMysteryBird),
                SKAction.waitForDuration(0.6)
                ]),count: 24
            ))
        
        
    }

    
    func thomasSighting() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
        //    label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        //    label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "Thomas Sighting!"
        //    label_score.zPosition = 701
        //    label_score.hidden = false
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(createThomas),
                SKAction.waitForDuration(0.6)
                ]),count: 1
            ))
        
        
    }
    
    func speedsterSpotted() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
        //    label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        //    label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "Speedster Spotted!"
        //    label_score.zPosition = 701
        //    label_score.hidden = false
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(createSpeedster),
                SKAction.waitForDuration(0.6)
                ]),count: 1
            ))
        
        
    }
    
    func brownBirdChaos() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
        //    label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        //    label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "Brownbird Chaos!"
        //    label_score.zPosition = 701
        //    label_score.hidden = false
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(createBrownBird),
                SKAction.waitForDuration(0.6)
                ]),count: 12
            ))
        
        
    }
    
    func rareBirdFrenzy() {
    
    self.runAction(playHighScoreEffect)
    // 1
            label_score.hidden = false
//    label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
//    label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
    label_score.text = "Rare Bird Frenzy"
//    label_score.zPosition = 701
//    label_score.hidden = false
    
    // Create the actions
    let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
    let actionMoveDone = SKAction.hide()
    
    
    self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
    
    runAction(SKAction.repeatAction(
    SKAction.sequence([
    SKAction.runBlock(createRareBird),
    SKAction.waitForDuration(0.6)
        ]),count: 10
    ))
        
    
    }
    
    func newFlock() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
//        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
//        label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "A New Flock Arrived"
//        label_score.zPosition = 701
//        label_score.hidden = false
//        addChild(label_score)
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createPurpleBird),
                SKAction.waitForDuration(0.6)
                ])
            ))
        
        
    }
    
    func newFlock2() {
        
        self.runAction(playHighScoreEffect)
        // 1
        label_score.hidden = false
        //        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        //        label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "A New Flock Arrived"
        //        label_score.zPosition = 701
        //        label_score.hidden = false
        //        addChild(label_score)
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()
        
        
        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createYellowBird),
                SKAction.waitForDuration(0.7)
                ])
            ))
        
        
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
    
    func initFloor() {
        
        floorNode = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: self.view!.frame.width, height: 72))
        floorNode.position = CGPoint(x: self.view!.frame.width/2, y: 74)
        floorNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.view!.frame.width, height: 72))
        floorNode.physicsBody?.categoryBitMask = FSFloorCategory
        floorNode.physicsBody?.contactTestBitMask = FSPlayerCategory
        floorNode.physicsBody?.collisionBitMask = FSFloorCategory
        // 1
        floorNode.physicsBody?.affectedByGravity = false
        floorNode.physicsBody?.restitution = 0
//        floorNode.physicsBody?.allowsRotation = false
//        bird.physicsBody?.restitution = 0.0
        floorNode.zPosition = 0
        floorNode.size = CGSize(width: size.width, height: 1)
        
        addChild(floorNode)
        
    }
    
    func becameActive(notification : NSNotification){
        
        println("BECAME ACTIVE")

//            if self.bird.position.y != CGFloat(72.0) {
//                println("GOTCHA AIR")
//                inAir = "true"
//            }
        
        
        
    }
    
    func initGreenGuy() {
        
        bird = SKSpriteNode(imageNamed: "bird1")
        bird.position = CGPoint(x: self.size.width/2, y: 72)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2.5)
        bird.physicsBody?.categoryBitMask = FSPlayerCategory
        bird.physicsBody?.contactTestBitMask = FSPipeCategory | FSGapCategory | FSBoundaryCategory
        bird.physicsBody?.collisionBitMask = FSPipeCategory | FSBoundaryCategory
        // 1
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.restitution = 0.0
        bird.zPosition = 50
        bird.size = CGSize(width: 44*0.9, height: 44*0.9)
        addChild(bird)
        
        let texture1 = SKTexture(imageNamed: "greenguy1")
        let texture2 = SKTexture(imageNamed: "greenguy2")
        let texture3 = SKTexture(imageNamed: "greenguy3")
        let texture4 = SKTexture(imageNamed: "greenguy4")
        let textures = [texture1, texture2, texture3, texture4]
        
        bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.2)))
        
        
    }
    
    func initBaby() {
        
        bird = SKSpriteNode(imageNamed: "bird1")
        bird.position = CGPoint(x: self.size.width/2, y: 72)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2.5)
        bird.physicsBody?.categoryBitMask = FSPlayerCategory
        bird.physicsBody?.contactTestBitMask = FSPipeCategory | FSGapCategory | FSBoundaryCategory
        bird.physicsBody?.collisionBitMask = FSPipeCategory | FSBoundaryCategory
        // 1
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.restitution = 0.0
        bird.zPosition = 50
        bird.size = CGSize(width: 44*0.9, height: 44*0.9)
        addChild(bird)
        
        let texture1 = SKTexture(imageNamed: "baby1")
        let texture2 = SKTexture(imageNamed: "baby2")
        let texture3 = SKTexture(imageNamed: "baby3")
        let texture4 = SKTexture(imageNamed: "baby4")
        let textures = [texture1, texture2, texture3, texture4]
        
        bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.2)))
        
        
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
    bird.physicsBody?.affectedByGravity = true
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
        let tile = SKSpriteNode(imageNamed: "background")
        tile.anchorPoint = CGPointZero
        tile.position = CGPoint(x: CGFloat(i) * 640.0, y: 0.0)
        tile.name = "background"
        tile.zPosition = 10
        background.addChild(tile)
    }

  }
    
  func moveBackground() {
    
    // 3
    let posX = -background_speed * delta
    background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0)
    
    // 4
    background.enumerateChildNodesWithName("background") { (node, stop) in
        let background_screen_position = self.background.convertPoint(node.position, toNode: self)
        
        if background_screen_position.x <= -node.frame.size.width {
            node.position = CGPoint(x: node.position.x + (node.frame.size.width * 2), y: node.position.y)
        }
        
    }

  }
    
  // MARK: - Pipes Functions
//  func initPipes() {
//    
//    let screenSize: CGRect = UIScreen.mainScreen().bounds
//    let isWideScreen: Bool = (screenSize.height > 480)
//    // 1
//    let bottom = getPipeWithSize(CGSize(width: 62, height: Float.range(40, max: isWideScreen ? 360 : 280)), side: false)
//    bottom.position = convertPoint(CGPoint(x: pipe_origin_x, y: CGRectGetMinY(frame) + bottom.size.height/2 + floor_distance), toNode: background)
//    bottom.physicsBody = SKPhysicsBody(rectangleOfSize: bottom.size)
//    bottom.physicsBody?.categoryBitMask = FSPipeCategory;
//    bottom.physicsBody?.contactTestBitMask = FSPlayerCategory;
//    bottom.physicsBody?.collisionBitMask = FSPlayerCategory;
//    bottom.physicsBody?.dynamic = false
//    bottom.zPosition = 20
//    background.addChild(bottom)
//    
//    
//    // 2
//    let threshold = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: 10, height: 100))
//    threshold.position = convertPoint(CGPoint(x: pipe_origin_x, y: floor_distance + bottom.size.height + threshold.size.height/2), toNode: background)
//    threshold.physicsBody = SKPhysicsBody(rectangleOfSize: threshold.size)
//    threshold.physicsBody?.categoryBitMask = FSGapCategory
//    threshold.physicsBody?.contactTestBitMask = FSPlayerCategory
//    threshold.physicsBody?.collisionBitMask = 0
//    threshold.physicsBody?.dynamic = false
//    threshold.zPosition = 20
//    background.addChild(threshold)
//    
//    // 3
//    let topSize = size.height - bottom.size.height - threshold.size.height - floor_distance
//    
//    // 4
//    let top = getPipeWithSize(CGSize(width: 62, height: topSize), side: true)
//    top.position = convertPoint(CGPoint(x: pipe_origin_x, y: CGRectGetMaxY(frame) - top.size.height/2), toNode: background)
//    top.physicsBody = SKPhysicsBody(rectangleOfSize: top.size)
//    top.physicsBody?.categoryBitMask = FSPipeCategory;
//    top.physicsBody?.contactTestBitMask = FSPlayerCategory;
//    top.physicsBody?.collisionBitMask = FSPlayerCategory;
//    top.physicsBody?.dynamic = false
//    top.zPosition = 20
//    background.addChild(top)
//
//  }
//    
//  func getPipeWithSize(size: CGSize, side: Bool) -> SKSpriteNode {
//    // 1
//    let textureSize = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
//    let backgroundCGImage = UIImage(named: "pipe")!.CGImage
//    
//    // 2
//    UIGraphicsBeginImageContext(size)
//    let context = UIGraphicsGetCurrentContext()
//    CGContextDrawTiledImage(context, textureSize, backgroundCGImage)
//    let tiledBackground = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    // 3
//    let backgroundTexture = SKTexture(CGImage: tiledBackground.CGImage)
//    let pipe = SKSpriteNode(texture: backgroundTexture)
//    pipe.zPosition = 1
//    
//    // 4
//    let cap = SKSpriteNode(imageNamed: "bottom")
//    cap.position = CGPoint(x: 0.0, y: side ? -pipe.size.height/2 + cap.size.height/2 : pipe.size.height/2 - cap.size.height/2)
//    cap.zPosition = 5
//    pipe.addChild(cap)
//    
//    // 5
//    if side == true {
//        let angle:CGFloat = 180.0
//        cap.zRotation = angle.degrees_to_radians()
//    }
//    
//    return pipe
//  }
    
    // MARK: - Score
    
    func initHUD() {
        
        
        //bird UINODE
        
        birdHudNode = SKSpriteNode(imageNamed: "bluebird1")
        birdHudNode.position = CGPoint(x: 14, y: CGRectGetMaxY(frame) - 18)
        birdHudNode.zPosition = 700
        birdHudNode.size = CGSize(width: 16, height: 16)
        
        addChild(birdHudNode)
        // 1
        total_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        total_score.position = CGPoint(x: CGRectGetMidX(frame) - 132, y: CGRectGetMaxY(frame) - 26)
        
        if Defaults["totalscore"].int != nil {
        total_score.text = String(Defaults["totalscore"].int!)
        totalscore = Defaults["totalscore"].int!
        }else {
            total_score.text = "0"
        }
        total_score.zPosition = 50
        total_score.fontSize = 40/2
        total_score.horizontalAlignmentMode = .Left
        
        addChild(total_score)
        
        // 1
        high_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        high_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 32)
        high_score.text = "0"
        high_score.zPosition = 50
        addChild(high_score)
        
        // 1
        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = ""
        label_score.zPosition = 701
        label_score.hidden = true
        addChild(label_score)
        
        // 2
        instructions = SKSpriteNode(imageNamed: "TapToStart")
        instructions.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 10)
        instructions.zPosition = 50
//        addChild(instructions)
    }
    
    func displayHighScore() {
        
        // 1
        label_score.hidden = false
//        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
//        label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "New High Score"
//        label_score.zPosition = 701
       //        addChild(label_score)
        
        // Create the actions
        let actionLength = SKAction.moveTo(CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100), duration: NSTimeInterval(2.0))
        let actionMoveDone = SKAction.hide()


        self.label_score.runAction(SKAction.sequence([actionLength,actionMoveDone]))
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
        
        
//        if highscore <= score && score != 0 {
//            
//            highscore = score
//            high_score.text = "\(score)"
//        }
//        println("hitground")
//        score = 0
//        label_score.text = "\(score)"
//        
//        if bird.position.y < 150 {
////            gameOver()
//        }
    }
    
    if collision == (FSPlayerCategory | FSCoinCategory) {
        
        totalscore++
        total_score.text = "\(totalscore)"
        
        Defaults["totalscore"] = totalscore
        
        score++
//        label_score.text = "\(score)"
        removeCoin(secondBody.node as! SKSpriteNode)
        println("GOT COIN")
        
//        audioPlayer.stop()
//        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
//        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//        AVAudioSession.sharedInstance().setActive(true, error: nil)
//        
//        var error:NSError?
//        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
//        audioPlayer.stop()
//        audioPlayer.prepareToPlay()
//        audioPlayer.play()
        
    }
    
    if collision == (FSPlayerCategory | FSYellowCategory) {
        
        totalscore+=2
        total_score.text = "\(totalscore)"
        
        Defaults["totalscore"] = totalscore
        
        score+=2
        //        label_score.text = "\(score)"
        removeCoin(secondBody.node as! SKSpriteNode)
        println("GOT COIN")
        
        //        audioPlayer.stop()
        //        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
        //        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        //        AVAudioSession.sharedInstance().setActive(true, error: nil)
        //
        //        var error:NSError?
        //        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        //        audioPlayer.stop()
        //        audioPlayer.prepareToPlay()
        //        audioPlayer.play()
        
    }

    
    if collision == (FSPlayerCategory | FSMegaCoinCategory) {
        
        totalscore+=10
        total_score.text = "\(totalscore)"
        
        score+=10
//        label_score.text = "\(score)"
        removeCoin(secondBody.node as! SKSpriteNode)
        println("GOT MEGA COIN")
//        var randget = random(min:CGFloat(-0.2), max: CGFloat(0.2))
//        firstBody.applyImpulse(CGVector(dx: randget, dy: 0))
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
        
        totalscore+=25
        total_score.text = "\(totalscore)"
        
        score+=25
//        label_score.text = "\(score)"
        removeCoin(secondBody.node as! SKSpriteNode)
        println("GOT MEGA COIN")
        
//        var randget = random(min:CGFloat(-20.0), max: CGFloat(20.0))
//        firstBody.applyImpulse(CGVector(dx: randget, dy: 0))
        //        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
        //        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        //        AVAudioSession.sharedInstance().setActive(true, error: nil)
        //
        //        var error:NSError?
        //        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        //        audioPlayer.prepareToPlay()
//                audioPlayer.play()
        
    }
    
    if collision == (FSPlayerCategory | FSImpossibleCoinCategory) {
        
        totalscore+=65
        total_score.text = "\(totalscore)"
        
        score+=65
//        label_score.text = "\(score)"
        removeCoin(secondBody.node as! SKSpriteNode)
        println("GOT MEGA COIN")
        
        audioPlayer.stop()
        //                optionView.hidden = false
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
        
        let scene = TopBirdScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        
        //                self.scene!.view!.presentScene(scene, transition: transition)
        self.scene!.view!.presentScene(scene)
        
        
        
//        firstBody.applyImpulse(CGVector(dx: 0, dy: 25))
        //        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collectcoin", ofType: "wav")!)
        //        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        //        AVAudioSession.sharedInstance().setActive(true, error: nil)
        //
        //        var error:NSError?
        //        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        //        audioPlayer.prepareToPlay()
//                audioPlayer.play()
        
    }
    
    if collision == (FSPlayerCategory | FSRareBirdCategory) {
        
        totalscore+=5
        total_score.text = "\(totalscore)"
        
        score+=5
        //        label_score.text = "\(score)"
        removeCoin(secondBody.node as! SKSpriteNode)

        
    }

    
    if collision == (FSPlayerCategory | FSFloorCategory) {
        
        jumpcount = 0
       
        println("hit floor")
        if highscore < score && score != 0 {
            
            highscore = score
            high_score.text = "\(score)"
            self.runAction(playHighScoreEffect)
            displayHighScore()
        }
        println("hitground")
        score = 0
//        label_score.text = "\(score)"
        
        if bird.position.y < 150 {
            //            gameOver()
        }
        
    }
    
  }
    
    func removeCoin (coin:SKSpriteNode) {
        
        coin.removeFromParent()
//        playSoundEffect = SKAction.playSoundFileNamed("SFX_Powerup_49.wav", waitForCompletion: false)
        self.runAction(playSoundEffect)
        
    }
    
    func initOptionButton() {
        
        optionButton = SKSpriteNode(imageNamed: "man1")
        optionButton.position = CGPoint(x: CGRectGetMidX(frame) + 140, y: CGRectGetMaxY(frame) - 20)
        optionButton.size = CGSize(width: 44*0.9, height: 44*0.9)
        
        optionButton.zPosition = 60
        addChild(optionButton)
        
    }
    
  // MARK: - Touch Events
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    
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
        
//        if jumpcount < 2 {
//            
//            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 14))
//            bird.runAction(SKAction.rotateByAngle(CGFloat(-M_PI*2), duration: 0.5))
//            jumpcount!++
//        }
        
        if inAir == "true" {
            
            
            
        }else {
            inAir = "true"
           bird.runAction(SKAction.rotateByAngle(CGFloat(-M_PI*2), duration: 0.5))
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 14))
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("notInAir"), userInfo: nil, repeats: false)

        }
    }
    
  }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if CGRectContainsPoint(optionButton.frame, location) {
                println("Touched Option")
                
                audioPlayer.stop()
//                optionView.hidden = false
                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
                
                let scene = MenuScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                
//                self.scene!.view!.presentScene(scene, transition: transition)
                self.scene!.view!.presentScene(scene)
                
                
            } else {
                
                println("Nothing here")
            }
            
        }
    }
    
    func initOptionMenu() {
        
        optionView = UIView()
        optionView.frame = CGRectMake(CGRectGetMidX(frame) - 150,103,300,400)
        optionView.backgroundColor = UIColor.blackColor()
        optionView.layer.cornerRadius = 6.0
        optionView.layer.borderWidth = 4.0
        optionView.layer.borderColor = UIColor.darkGrayColor().CGColor
        optionView.hidden = true
        
        //                CGPoint(x: CGRectGetMidX(frame) - 100, y: CGRectGetMaxY(frame) - 50)
        self.view?.addSubview(optionView)
        
        // Add Character Frame
        // char size CGSize(width: 34*0.9, height: 44*0.9)
        var characterImageView = UIImageView()
        characterImageView.frame = CGRectMake(optionView.frame.width/2-130,20,44,44)
        var man = UIImage(named: "greenguy1")
        characterImageView.image = man
        optionView.addSubview(characterImageView)
        //------------------------
        
        // Add Close button
        var closeButton = UIButton()
        closeButton.frame = CGRectMake(optionView.frame.width-25,5,20,20)
        closeButton.backgroundColor = UIColor.redColor()
        closeButton.titleLabel?.text = "X"
        closeButton.titleLabel?.textColor = UIColor.blackColor()
        closeButton.addTarget(self, action: "closeMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        optionView.addSubview(closeButton)
        
    }
    
    func closeMenu(sender:UIButton!) {
        
        optionView.hidden = true
        bird.removeFromParent()
        initGreenGuy()

        
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
        
        
        let coin = SKSpriteNode(imageNamed: "bluebird1")
        
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
//        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 132), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: nil)
        }
        
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "bluebird1")
        let texture2 = SKTexture(imageNamed: "bluebird2")
//        let texture3 = SKTexture(imageNamed: "copper3")
//        let texture4 = SKTexture(imageNamed: "copper4")
//        let texture5 = SKTexture(imageNamed: "copper5")
//        let texture6 = SKTexture(imageNamed: "copper6")
//        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        

        
    }
    func createThomas() {
        
        
        let coin = SKSpriteNode(imageNamed: "redbird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSImpossibleCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 440)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(10.0), max: CGFloat(20.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 440), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "redbird1")
        let texture2 = SKTexture(imageNamed: "redbird2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }
    func createSpeedster() {
        
        
        let coin = SKSpriteNode(imageNamed: "blackbird1")
        
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
        
        let randomheight = random(min:CGFloat(130.0), max: CGFloat(340.0))
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: randomheight)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(3.0), max: CGFloat(5.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: randomheight), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "blackbird1")
        let texture2 = SKTexture(imageNamed: "blackbird2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }
    func createRainbow() {
        
        
        let coin = SKSpriteNode(imageNamed: "rainbow1")
        
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
        
        let randomheight = random(min:CGFloat(280.0), max: CGFloat(440.0))
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: randomheight)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(6.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: randomheight), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        //ORIGINAL METHODS---------------------------
//        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
//        //        coin.runAction(SKAction.sequence([oscillate]))
//        coin.runAction(SKAction.repeatActionForever(oscillate))
//        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        //-----------------------------------------------
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "rainbow1")
        let texture2 = SKTexture(imageNamed: "rainbow2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }

    func createBrownBird() {
        
        
        let coin = SKSpriteNode(imageNamed: "brownbird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSYellowCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        let randomheight = random(min:CGFloat(130.0), max: CGFloat(440.0))
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: randomheight)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(6.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: randomheight), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "brownbird1")
        let texture2 = SKTexture(imageNamed: "brownbird2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }
    
    func createMysteryBird() {
        
        
        let coin = SKSpriteNode(imageNamed: "bluegreen1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSYellowCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        let randomheight = random(min:CGFloat(280.0), max: CGFloat(480.0))
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: randomheight)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(6.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: randomheight), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "bluegreen1")
        let texture2 = SKTexture(imageNamed: "bluegreen2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }

    
    
    func createYellowBird() {
        
        
        let coin = SKSpriteNode(imageNamed: "yellowbird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSYellowCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 438)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 438), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
//        var oscillateforever = SKAction.repeatActionForever(oscillate)
//        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "yellowbird1")
        let texture2 = SKTexture(imageNamed: "yellowbird2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }



    
    func createPurpleBird() {
        
        
        let coin = SKSpriteNode(imageNamed: "purplebird1")
        
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
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 318)
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 318), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "purplebird1")
        let texture2 = SKTexture(imageNamed: "purplebird2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }

    func createRareBird() {
        
        
        let coin = SKSpriteNode(imageNamed: "whitebird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSRareBirdCategory
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
        //        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(3.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 132), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
        let oscillate = SKAction.oscillation(amplitude: 8, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "whitebird1")
        let texture2 = SKTexture(imageNamed: "whitebird2")
        //        let texture3 = SKTexture(imageNamed: "copper3")
        //        let texture4 = SKTexture(imageNamed: "copper4")
        //        let texture5 = SKTexture(imageNamed: "copper5")
        //        let texture6 = SKTexture(imageNamed: "copper6")
        //        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        var randomflapspeed = random(min:0.3, max: 0.6)
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(randomflapspeed))))
        
        
        
    }

    
    func createMegaCoin() {
        
        let coin = SKSpriteNode(imageNamed: "bigblue1")
        
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
//        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 50, height: 50)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 232), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
//        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        let oscillate = SKAction.oscillation(amplitude: 4, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-50, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "bigblue1")
        let texture2 = SKTexture(imageNamed: "bigblue2")
//        let texture3 = SKTexture(imageNamed: "copper3")
//        let texture4 = SKTexture(imageNamed: "copper4")
//        let texture5 = SKTexture(imageNamed: "copper5")
//        let texture6 = SKTexture(imageNamed: "copper6")
//        let texture7 = SKTexture(imageNamed: "copper7")
        let textures = [texture1, texture2]
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.5)))
        
        
    }
    
    func createUltraCoin() {
        
        let coin = SKSpriteNode(imageNamed: "orangebird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSUltraCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
//        coin.physicsBody?.affectedByGravity = true
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 402)
//        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 30, height: 30)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 402), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
//        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        let oscillate = SKAction.oscillation(amplitude: 6, timePeriod: 2, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "orangebird1")
        let texture2 = SKTexture(imageNamed: "orangebird2")
//        let texture3 = SKTexture(imageNamed: "silver3")
//        let texture4 = SKTexture(imageNamed: "silver4")
//        let texture5 = SKTexture(imageNamed: "silver5")
//        let texture6 = SKTexture(imageNamed: "silver6")
//        let texture7 = SKTexture(imageNamed: "silver7")
        let textures = [texture1, texture2]
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.3)))
        
//        coin.runAction(SKAction.repeatActionForever(SKAction.runBlock({ () -> Void in
////                    var randget = random(min:CGFloat(-0.2), max: CGFloat(0.2))
//                    coin.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0.2))
//        })))
        
        
            }

    func createImpossibleCoin() {
        
        let coin = SKSpriteNode(imageNamed: "topbird1")
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = FSImpossibleCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = FSPlayerCategory
        coin.physicsBody?.affectedByGravity = false
        coin.zPosition = 100
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min:coin.size.height/2, max: size.height - coin.size.height/2)
        let actualX = random(min:coin.size.width/2, max: size.width - coin.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: 502)
//        coin.zRotation = CGFloat(M_PI_2)
        coin.size = CGSize(width: 20, height: 20)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min:CGFloat(6.0), max: CGFloat(12.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width, y: 502), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            //            let gameOverScene = GameOverScene(size: self.size, won: false)
            //            self.view?.presentScene(gameOverScene, transition: nil)
        }
//        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        let oscillate = SKAction.oscillation(amplitude: 2, timePeriod: 4, midPoint: coin.position)
        //        coin.runAction(SKAction.sequence([oscillate]))
        coin.runAction(SKAction.repeatActionForever(oscillate))
        var moveBird = SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration))
        //        var oscillateforever = SKAction.repeatActionForever(oscillate)
        //        coin.runAction(SKAction.moveByX(-self.size.width-30, y: 0, duration: NSTimeInterval(actualDuration)))
        coin.runAction(SKAction.sequence([moveBird,actionMoveDone]))
        
        let texture1 = SKTexture(imageNamed: "brightgreen1")
        let texture2 = SKTexture(imageNamed: "brightgreen2")
        let texture3 = SKTexture(imageNamed: "coin3")
        let texture4 = SKTexture(imageNamed: "coin4")
        let texture5 = SKTexture(imageNamed: "coin5")
        let texture6 = SKTexture(imageNamed: "coin6")
        let texture7 = SKTexture(imageNamed: "coin7")
        let textures = [texture1, texture2]
        
        coin.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.3)))
        
        
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
    
    //=====================================================================================================
    // AD STUFF===========================================================================================================================================================================
    
    func loadAds(){
        adBannerView = ADBannerView(frame: CGRect.zeroRect)
        adBannerView!.center = CGPoint(x: adBannerView!.center.x, y: view!.bounds.size.height - adBannerView!.frame.size.height / 2)
        adBannerView!.delegate = self
        adBannerView!.hidden = true
        view!.addSubview(adBannerView!)
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        
        
        println("Banner will load Ad")
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        
        if adBannerView != nil {
            
            adBannerView!.hidden = false
            self.adBannerView!.alpha = 1.0
            
            println("Ad Loaded")
        }
        
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        
        
        println("Ad Banner Finished")
        
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        
        
        println("Ad Banner Begin")
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        
        if adBannerView != nil {
            
            adBannerView!.hidden = true
        }
    }

}
