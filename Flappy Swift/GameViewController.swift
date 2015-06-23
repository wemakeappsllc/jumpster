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

class GameViewController: UIViewController, EasyGameCenterDelegate, GKGameCenterControllerDelegate,ADInterstitialAdDelegate, ADBannerViewDelegate {
    
  @IBOutlet var skView: SKView!
    var scene:GameScene!
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    // Ad Banner
    var adBannerView : ADBannerView?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    //OBSERVE FOR SHARE ==================================================================
       NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareSheet:", name: "SharePress", object: nil)
    //=====================================================================================
    
    //OBSERVE FOR SHARE ==================================================================
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideAds:", name: "RemoveAds", object: nil)
    //=====================================================================================
    
    /*** Set Delegate UIViewController ***/
    EasyGameCenter.sharedInstance(self)
    
    //Set New view controller delegate, that's when you change UIViewController
    EasyGameCenter.delegate = self
    
    /*** If you want not message just delete this ligne ***/
    EasyGameCenter.debugMode = true
    
    
    
    if Defaults["premium"].string != nil {
        
        if adBannerView != nil {
            adBannerView?.hidden = true
            adBannerView = nil
        }
        

        
    } else {
        
            loadAds()
        
    }


//    skView.showsFPS = true
//    skView.showsNodeCount = true
//    skView.showsPhysics   = true
    
    var gameCenter = GKGameCenterViewController()
    gameCenter.gameCenterDelegate = self
    
    if skView.scene == nil {
//      let scene = GameScene(size: skView.bounds.size)
      skView.presentScene(GameScene(size: skView.bounds.size))
    }
  }
    
    
    func hideAds(notification : NSNotification) {
        
        if adBannerView != nil {
            adBannerView?.hidden = true
            adBannerView = nil
        }
        
    }
    
    
    func shareSheet(notification : NSNotification) {
        
        var textToShare = "I Got Top Bird! Bet you can't :) "
        var myWebsite = "https://itunes.apple.com/us/app/king-top-bird/id1006423676?ls=1&mt=8"
        let objectsToShare = [textToShare, myWebsite]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
        
        
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
