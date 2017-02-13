//
//  GameViewController.swift
//  BrainGame
//
//  Created by eicke on 9/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import SceneKit
import GoogleMobileAds
class GameViewController: UIViewController, GADInterstitialDelegate {

var interstitial: GADInterstitial!
    
    let adUnitID = "ca-app-pub-1495047417563453/2347831524"
    static var first:Bool = true
    
    override func viewDidLoad() {  
         super.viewDidLoad()
        

        //sleep(5000)
        if !GameViewController.first {
        self.interstitial = createAndLoadInterstitial()
        } /////////
        GameViewController.first = false
        
        if let view = self.view as! SKView? {

            let scene =  GameScene()
            scene.viewController = self
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = false
            view.showsFPS = true
            view.showsNodeCount = true
 
        }
    }

    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial =
            GADInterstitial(adUnitID: adUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    //////////
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }    }
    
    func interstitialDidDismissScreen(_ interstitial: GADInterstitial) {

       }

    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        // Retrying failed interstitial loads is a rudimentary way of handling these errors.
        // For more fine-grained error handling, take a look at the values in GADErrorCode.
        self.interstitial = createAndLoadInterstitial()
    }
    
    ///////////
    override var shouldAutorotate: Bool {
        return true
    }
    /*
    * Segun el nombre del juego seleccionado en el menu lanza una pantalla con un juego distinto
    */
    func changeToGameScene(game:String, options: [String:Any?])
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        switch(game)
        {
        case "nQueens":
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "QueensGameScreen") as! nQueensGame//BoardGameViewController
            resultViewController.parameters["numQueens"] = 8 as Any                                        //Numero de reinas a colocar. Al final no se cambia desde el juego
            self.present(resultViewController, animated:true, completion:nil)
        break
            
        case "Bishops":
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "BishopsGameScreen") as! BishopsGame//BoardGameViewController
            self.present(resultViewController, animated:true, completion:nil)
        break
            
        case "Knights":
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "KnightsGameScreen") as! KnightsGame//BoardGameViewController
            self.present(resultViewController, animated:true, completion:nil)
            break

        case "Knights36":
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "Knights36GameScreen") as! Knights36Game//BoardGameViewController
            self.present(resultViewController, animated:true, completion:nil)
            break
            
        default:
            break
        }

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
