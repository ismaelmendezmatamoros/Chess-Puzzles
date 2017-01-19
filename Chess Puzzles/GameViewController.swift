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

class GameViewController: UIViewController {

    override func viewDidLoad() {  
         super.viewDidLoad()
        
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

    override var shouldAutorotate: Bool {
        return true
    }

    func changeToGameScene(game:String, options: [String:Any?])
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        switch(game)
        {
        case "nQueens":
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "QueensGameScreen") as! nQueensGame//BoardGameViewController
            resultViewController.parameters["numQueens"] = 8 as Any
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
