//
//  GameScene.swift
//  SwiftTeamSelect
//
//  Created by Kamil Burczyk on 16.06.2014.
//  Copyright (c) 2014 Sigmapoint. All rights reserved.
//

import SpriteKit
import GameKit
import StoreKit

class MenuScene: SKScene, EasyGameCenterDelegate, GKGameCenterControllerDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
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
    var label_score : SKLabelNode!
    var restorePurchaseLabel : SKLabelNode!
    var exitButton: SKSpriteNode!
    var removeAdsButton: SKSpriteNode!
    var soundButton: SKSpriteNode!
    
    var swipeLabel : SKLabelNode!
    var tapToSelectLabel : SKLabelNode!
    
    var testString: String?
    
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
    
    override func willMoveFromView(view: SKView) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
        
    }
    
    
    override func didMoveToView(view: SKView) {
        
        
        // Set IAPS
        if(SKPaymentQueue.canMakePayments()) {
            println("IAP is enabled, loading")
            var productID:NSSet = NSSet(objects: "removeAds", "bundle id")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            println("please enable IAPS")
        }

        /*** Set Delegate UIViewController ***/
        EasyGameCenter.sharedInstance(self)
        
        //Set New view controller delegate, that's when you change UIViewController
        EasyGameCenter.delegate = self
        
        /*** If you want not message just delete this ligne ***/
        EasyGameCenter.debugMode = true
        
        
        placePlayersOnPositions()
        calculateZIndexesForPlayers()
        initBackground()
        initLeaderBoardButton()
        initExitButton()
//        initRestorePurchaseButton()
        
        initSoundButton()
        
        if Defaults["premium"].string != nil {
            
        }else{
        initRemoveAdsButton()
        initRestorePurchaseButton()
        }
    }
    
    func initSoundButton() {
    
        if Defaults["sound"].string == nil || Defaults["sound"].string == "on" {
            
            soundButton = SKSpriteNode(imageNamed: "soundOn")
            soundButton.position = CGPoint(x: CGRectGetMidX(frame)-140, y: CGRectGetMaxY(frame) - 20)
            soundButton.size = CGSize(width: 44*0.6, height: 44*0.6)
        
            soundButton.zPosition = 60
            addChild(soundButton)
            
        }else {
            
            soundButton = SKSpriteNode(imageNamed: "soundOff")
            soundButton.position = CGPoint(x: CGRectGetMidX(frame)-140, y: CGRectGetMaxY(frame) - 20)
            soundButton.size = CGSize(width: 44*0.6, height: 44*0.6)
            
            soundButton.zPosition = 60
            addChild(soundButton)
            
        }
    
    }
    // MARK: - Background Functions
    func initBackground() {
        
        
        // 1
        tapToSelectLabel = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        tapToSelectLabel.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 210)
        tapToSelectLabel.text = "Tap to Select"
        tapToSelectLabel.zPosition = 801
        tapToSelectLabel.name = "taptoselect"
        tapToSelectLabel.fontSize = 40/3
        addChild(tapToSelectLabel)
        
        
        // 1
        swipeLabel = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        swipeLabel.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 370)
        swipeLabel.text = "<< Swipe >>"
        swipeLabel.zPosition = 801
        swipeLabel.name = "swipeLabel"
        swipeLabel.fontSize = 40/3
        addChild(swipeLabel)
        
        
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
    
    func initRemoveAdsButton() {
        
        
        removeAdsButton = SKSpriteNode(imageNamed: "unlockAdsBigBanner")
        removeAdsButton.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 440)
        removeAdsButton.size = CGSize(width: 573*0.5, height: 154*0.5)
        
        removeAdsButton.zPosition = 60
        addChild(removeAdsButton)
        
        
    }
    
    func initExitButton() {
        
        
        exitButton = SKSpriteNode(imageNamed: "closeButton")
        exitButton.position = CGPoint(x: CGRectGetMidX(frame) + 140, y: CGRectGetMaxY(frame) - 20)
        exitButton.size = CGSize(width: 44*0.7, height: 44*0.7)
        
        exitButton.zPosition = 60
        addChild(exitButton)
        
        
    }
    
    func initRestorePurchaseButton() {
        
        restorePurchaseLabel = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        restorePurchaseLabel.position = CGPoint(x: CGRectGetMidX(frame)+90, y: CGRectGetMaxY(frame) - 500)
        restorePurchaseLabel.text = "Restore Purchase"
        restorePurchaseLabel.zPosition = 801
        restorePurchaseLabel.fontColor = UIColor.grayColor()
        restorePurchaseLabel.name = "restorePurchase"
        restorePurchaseLabel.fontSize = 40/3
        addChild(restorePurchaseLabel)
        
        
    }
    
    func initLeaderBoardButton() {
        
        // 1
        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        label_score.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - 100)
        label_score.text = "Leaderboards"
        label_score.zPosition = 801
        label_score.name = "leaderboards"
        addChild(label_score)
        
    }
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createPlayers() {
        

        
        if Defaults["premium"].string != nil {
        
        let characters = ["babyBig","kingBig","greenguyBig"]
        
        for i in 0..<3 {
            
            var names = ["King","Baby","Bird Lover"]
            let player = SKSpriteNode(imageNamed: characters[i])
            player.size = CGSizeMake(100, 100)
            player.name = characters[i]
            
            players.append(player)
            
            
        }
        }else{
            
            let characters = ["hiddenBaby","kingBig","hiddenGreen"]
            
            for i in 0..<3 {
                
                var names = ["King","Baby","Bird Lover"]
                let player = SKSpriteNode(imageNamed: characters[i])
                player.size = CGSizeMake(100, 100)
                player.name = characters[i]
                
                players.append(player)
            
            }
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
            
            if removeAdsButton != nil {
            
            if CGRectContainsPoint(removeAdsButton.frame, location) {
                println("Remove Ads Pressed")
                
                
                self.view?.userInteractionEnabled = false
//                removeAdsButton.hidden = true
                btnRemoveAds()
                

                
            }

            }
            
            if CGRectContainsPoint(exitButton.frame, location) {
                println("Touched Option")
                
                Defaults["fireInterstitial"] = "true"
                
                //                optionView.hidden = false
                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
                
                let scene = GameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                
                //                self.scene!.view!.presentScene(scene, transition: transition)
                self.scene!.view!.presentScene(scene)
                
                
            } 

            
        if CGRectContainsPoint(self.label_score!.frame, location) {
            
            
            var vc = self.view?.window?.rootViewController
            var gc = GKGameCenterViewController()
            gc.gameCenterDelegate = self
            vc?.presentViewController(gc, animated: true, completion: nil)
            
            }
            if self.restorePurchaseLabel != nil {
            
        if CGRectContainsPoint(self.restorePurchaseLabel!.frame, location) {
                
                println("RESTORE PRESSED")
                RestorePurchases()
                
            }
            }
            
        if CGRectContainsPoint(self.centerPlayer!.frame, location) {
            
            
            if self.centerPlayer!.name == "kingBig" || self.centerPlayer!.name == "greenguyBig" || self.centerPlayer!.name == "babyBig" {
                
                println(self.centerPlayer!.name)
                
                Defaults["fireInterstitial"] = "true"
                
                Defaults["currentPlayer"] = self.centerPlayer!.name
                
                let scene = GameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                
                //            self.scene!.view!.presentScene(scene, transition: transition)
                self.scene!.view!.presentScene(scene)
              
                
            }else {
                
                println(self.centerPlayer!.name)
                
            }
            }
//            if self.centerPlayer!.name != "hiddenBaby" || self.centerPlayer!.name != "hiddenGreen" {
//                
//                println(self.centerPlayer!.name)
//                
//            }
            //            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
//            let scene = GameScene(size: self.scene!.size)
//            scene.scaleMode = SKSceneScaleMode.AspectFill
//            
//            //            self.scene!.view!.presentScene(scene, transition: transition)
//            self.scene!.view!.presentScene(scene)
            
//            }
        
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
            
            let location = touch.locationInNode(self)
            


                
                if CGRectContainsPoint(soundButton.frame, location) {
                    println("Sound Altered")
                    
                    if Defaults["sound"].string == nil || Defaults["sound"].string == "on" {
                        
                        println("ON FIRED")
                        soundButton.removeFromParent()
                        
                        soundButton = SKSpriteNode(imageNamed: "soundOff")
                        soundButton.position = CGPoint(x: CGRectGetMidX(frame)-140, y: CGRectGetMaxY(frame) - 20)
                        soundButton.size = CGSize(width: 44*0.6, height: 44*0.6)
                        
                        soundButton.zPosition = 60
                        addChild(soundButton)
                        
                        Defaults["sound"] = "off"
                        
                    }else{
                        
                        println("OFF FIRED")
                        soundButton.removeFromParent()
                        
                        soundButton = SKSpriteNode(imageNamed: "soundOn")
                        soundButton.position = CGPoint(x: CGRectGetMidX(frame)-140, y: CGRectGetMaxY(frame) - 20)
                        soundButton.size = CGSize(width: 44*0.6, height: 44*0.6)
                        
                        soundButton.zPosition = 60
                        addChild(soundButton)
                        Defaults["sound"] = "on"
                        
                    }
                    
                    
                    
                }
        
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
    
    //ALL IAP STUFF=====================================
    
    // 2
    func btnRemoveAds() {
        for product in list {
            var prodID = product.productIdentifier
            if(prodID == "removeAds") {
                p = product
                buyProduct()
                break;
            }
        }
        
    }
    // 4
    func removeAds() {
        println("ads removed")
        Defaults["premium"] = "true"
        NSNotificationCenter.defaultCenter().postNotificationName("RemoveAds", object: nil)
        
        if removeAdsButton != nil {
            
            removeAdsButton.hidden = true
            removeAdsButton = nil
        }
        if restorePurchaseLabel != nil {
            
            restorePurchaseLabel.hidden = true
            restorePurchaseLabel = nil
        }
        
//                let scene = ThankYouScene(size: self.scene!.size)
//                scene.scaleMode = SKSceneScaleMode.AspectFill
//                self.scene!.view!.presentScene(ThankYouScene(size: self.scene!.size))
        
//        removeAdsButton.hidden = true
//        leftPlayer?.removeFromParent()
//        rightPlayer?.removeFromParent()
//        centerPlayer?.removeFromParent()
//        
//        
//        createPlayers()
////        centerPlayer = players[players.count/2]
////        setLeftAndRightPlayers()
//        
//        
//        placePlayersOnPositions()
//        calculateZIndexesForPlayers()
//        

    }
    
    // 5
    func addCoins() {
        println("added 50 coins")
    }
    
    // 6
    func RestorePurchases() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    // 2
    func buyProduct() {
        println("buy " + p.productIdentifier)
        var pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    //3
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("product request")
        var myProduct = response.products
        
        for product in myProduct {
            println("product added")
            println(product.productIdentifier)
            println(product.localizedTitle)
            println(product.localizedDescription)
            println(product.price)
            
            list.append(product as! SKProduct)
        }
    }
    
    // 4
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("transactions restored")
        
        var purchasedItemIDS = []
        for transaction in queue.transactions {
            var t: SKPaymentTransaction = transaction as! SKPaymentTransaction
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "removeAds":
                println("remove ads")
                removeAds()
            case "bundleid":
                println("add coins to account")
                addCoins()
            default:
                println("IAP not setup")
            }
            
        }
    }
    
    // 5
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("add paymnet")
        
        for transaction:AnyObject in transactions {
            var trans = transaction as! SKPaymentTransaction
            println(trans.error)
            
            switch trans.transactionState {
                
            case .Purchased:
                println("buy, ok unlock iap here")
                self.view?.userInteractionEnabled = true
                println(p.productIdentifier)
//                Defaults["premium"] = "true"
//                //TRANSITION SCENE AFTER PURCHASE
//                let scene = GameScene(size: self.scene!.size)
//                scene.scaleMode = SKSceneScaleMode.AspectFill
//                self.scene!.view!.presentScene(scene)
//                //===============================
                
                let prodID = p.productIdentifier as String
                switch prodID {
                case "removeAds":
                    println("remove ads")
                    removeAds()
                case "bundle id":
                    println("add coins to account")
                    addCoins()
                default:
                    println("IAP not setup")
                }
                
                queue.finishTransaction(trans)
                break;
            case .Failed:
                println("buy error")
                self.view?.userInteractionEnabled = true
//                removeAdsButton.hidden = false
                queue.finishTransaction(trans)
                break;
            default:
                println("default")
                break;
                
            }
        }
    }
    
    // 6
    func finishTransaction(trans:SKPaymentTransaction)
    {
        println("finish trans")
        //TRANSITION SCENE AFTER PURCHASE
//        dispatch_async(dispatch_get_main_queue()) {
//            // update some UI
//        
//        let scene = GameScene(size: self.scene!.size)
//        scene.scaleMode = SKSceneScaleMode.AspectFill
//        self.scene!.view!.presentScene(scene)
//        }
//        //===============================
    }
    
    //7
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!)
    {
        println("remove trans");
    }
    
}