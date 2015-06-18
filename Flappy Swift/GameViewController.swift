//
//  GameViewController.swift
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

import UIKit
import SpriteKit
import GameKit
import iAd

class GameViewController: UIViewController, EasyGameCenterDelegate, GKGameCenterControllerDelegate,ADInterstitialAdDelegate {
    
  @IBOutlet var skView: SKView!
    var scene:GameScene!
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    /*** Set Delegate UIViewController ***/
    EasyGameCenter.sharedInstance(self)
    
    //Set New view controller delegate, that's when you change UIViewController
    EasyGameCenter.delegate = self
    
    /*** If you want not message just delete this ligne ***/
    EasyGameCenter.debugMode = true
    
    


//    skView.showsFPS = true
//    skView.showsNodeCount = true
//    skView.showsPhysics   = true
    
    var gameCenter = GKGameCenterViewController()
    gameCenter.gameCenterDelegate = self
    
    if skView.scene == nil {
      let scene = GameScene(size: skView.bounds.size)
      skView.presentScene(scene)
    }
  }

  override func shouldAutorotate() -> Bool {
    return true
  }
    

    func openGameCenter() {
        var gameCenter = GKGameCenterViewController()
        gameCenter.gameCenterDelegate = self
        self.presentViewController(gameCenter, animated: true, completion: nil)
    }
    
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }

  override func supportedInterfaceOrientations() -> Int {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    } else {
      return Int(UIInterfaceOrientationMask.All.rawValue)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
    
    //INTERSTITIAL ADS-----------------------------------------------------------------------
    func loadInterstitialAd() {
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        interstitialAdView = UIView()
        interstitialAdView.frame = self.view.bounds
        view.addSubview(interstitialAdView)
        
        interstitialAd.presentInView(interstitialAdView)
        UIViewController.prepareInterstitialAds()
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()

    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()

    }
}
