//
//  GameViewController.swift
//  scene
//
//  Created by eicke on 11/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import Foundation

class BoardGameViewController: UIViewController {
    
    private var semaphore:semaphore_t = semaphore_t()
    var numplayers:Int = 0
    var turns:Int = 0
    var rounds:Int = 0
    var scene = SCNScene()
    var current_turn_player = 0
    var touchEnabled = false
    var parameters:[String:Any] = [:]
    var board:Board?
    var pieces:[String:Piece] = [:]
    var exitButton:SKLabelNode = SKLabelNode()
    var timer:SKLabelNode = SKLabelNode()
    var moves:SKLabelNode = SKLabelNode()
    var victory:Bool = false
    
    
    let movement_semaphore = DispatchSemaphore.init(value: 0)
    let before_turn_semaphore = DispatchSemaphore.init(value: 0)
    let turns_end_semaphore = DispatchSemaphore.init(value: 0)
    
    let before_round_semaphore = DispatchSemaphore.init(value: 0)
    let round_end_semaphore = DispatchSemaphore.init(value: 0)
    
    let victory_semaphore = DispatchSemaphore.init(value: 0)
    
    override func viewDidLoad() {
        
        scene = SCNScene()//named: "Piecescollada.dae")!
        let scnView = self.view as! SCNView
        //let x = scnView.technique?["passes"] as! [String:Any]
        //let g = x["cullMode"]
        // set the scene to the view
        scnView.scene = scene/*
        let overlay = SKScene(size: CGSize(width: 1000, height: 1000))
        overlay.anchorPoint = CGPoint.zero
        let button = SKSpriteNode(color: UIColor.red, size: CGSize(width: 10, height: 10))//SKSpriteNode(imageNamed: "brainguy.png")
        let framesize = overlay.size
        button.size.width = framesize.width * 0.1
        button.size.height = framesize.height * 0.1
        button.position.x = framesize.width - button.size.width
        button.position.y = framesize.height * 0.01
        
        //button.frame = CGRect(x: 0, y: 0, width: , height: )
        overlay.addChild(button)
        ////////////////////
        


        
        /////////////////////
        
        scnView.overlaySKScene? = overlay
        scnView.overlaySKScene?.isHidden = false
        scnView.overlaySKScene?.isUserInteractionEnabled = true
        scnView.overlaySKScene?.scaleMode = .resizeFill
 */
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        scnView.antialiasingMode = .multisampling4X
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        scnView.addGestureRecognizer(tapGesture)
        self.performSelector(inBackground: #selector(BoardGameViewController.startGameLoop), with: nil)
        
        
 }

    
    func showExitButton()
    {
        
        let vie = self.view as! SCNView
        let overlay = SKScene.init(size:  CGSize.init(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        //let sp = SKLabelNode(text: "EXIT")
        


        // set the scene to the view
        //vie.scene = self.scene
        self.showOverlay(overlay: overlay ,node: self.exitButton, text: "exit", fontsize: CGFloat(30), x_relative: 0.95, y_relative: 0.05)
        self.showOverlay(overlay: overlay ,node: self.moves, text: "moves: 0", fontsize: CGFloat(20), x_relative: 0.5, y_relative: 0.95)
        vie.overlaySKScene = overlay


        
    }
    
    
    
    func showOverlay(overlay:SKScene ,node:SKLabelNode, text:String, fontsize:CGFloat , x_relative:CGFloat , y_relative:CGFloat)
    {
        //let sp = node
        node.text = text
        node.fontColor = UIColor.white
        node.fontSize = fontsize
        node.position.x = UIScreen.main.bounds.size.width * x_relative//
        node.position.y = UIScreen.main.bounds.size.height * y_relative
        let fade = [SKAction.fadeAlpha(to: 0.3, duration: 2) ,SKAction.fadeAlpha(to: 1.0, duration: 2)]
        node.run(SKAction.repeatForever(SKAction.sequence(fade)))
        overlay.addChild(node)
        
    }
    

    
    
    
    
    func startGameLoop()
    {
        self.setupGame()
        self.setupScene()
        //self.time_counter = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(KnightsGame.updateTimer), userInfo: nil, repeats: true)
        //self.time?.
        while (true)
        {
            self.doRound()
        }
    }
    
    func setupGame() {}
    
    func setupScene()
    {
        self.board?.runAction(SCNAction.rotate(by: 3.1416 * 0.1, around: SCNVector3.init(1.0, -1.0, 0.0), duration: 0.5))
    }
    
    func loadModelsFromFile(filename:String, names:[String], color:UIColor) -> [String:Piece]
    {

        let scene_aux = SCNScene(named: filename)
        let lambda = { (node:SCNNode, b:UnsafeMutablePointer<ObjCBool>) -> Bool in
            print(node.name!)
            //node.position = SCNVector3.init(x: 0, y: 0, z: 0)
            node.scale = SCNVector3.init(float3.init(1.0))

            if(node.geometry != nil)
            {
                node.geometry?.firstMaterial?.diffuse.contents = color
            }
            return names.contains(node.name!)
        }
        let nodes = scene_aux?.rootNode.childNodes(passingTest: lambda)
        var dic:[String:Piece] = [:]
        for i in nodes!
        {

            
            //i.position = SCNVector3.init(x: 0, y: 0, z: 0)
            let piece:Piece = Piece()
            piece.node = i
            piece.node.castsShadow = true
            //piece.node.geometry = i.geometry.c
            dic[piece.node.name!] = piece //i.clone() as SCNNode
            
        }
        return dic
    }
    
    
    func generateTeamsPieces(modelsfilename:String ,teams:[String], piecenames:[String],color:[UIColor]) -> [String:Piece]
    {
        var dic:[String:Piece] = [:]
        for i in 0...teams.count - 1
        {
            let team_pieces = self.loadModelsFromFile(filename: modelsfilename, names: piecenames, color: color[i])
            
            let lambda = { (a:(key: String, value: Piece)) in
                a.value.setName(name: teams[i] + "-" + a.value.node.name!)
                a.value.node.geometry?.firstMaterial?.diffuse.contents = color[i]
                dic[a.value.node.name!] = a.value
            }
            team_pieces.forEach(lambda)
        }
        return dic
    }
    
    
    func beforeTurnStarts(player:Int) -> Bool
    {
        self.before_turn_semaphore.signal()
        return true
    }
    
    func finalizeTurn()
    {
        self.movement_semaphore.signal()
    }
    
    func turnsEnd(player:Int)
    {
        self.turns_end_semaphore.signal()
    }
    
    func victoryConditionCheck() -> Bool
    {
        return false
    }
    
    func onVictory(winner:Int)
    {
        let view = self.view as! SCNView
        let board_action = SCNAction.repeatForever(SCNAction.rotate(by: 15.5, around: SCNVector3.init(0.0, 1.0, 0.0), duration: 2.5))
        self.board?.runAction(board_action)
        let label = SKLabelNode()
        self.showOverlay(overlay: view.overlaySKScene!, node: label, text: "YOU MADE IT!", fontsize: 50, x_relative: 0.5, y_relative: 0.5)
        let label_action = [SKAction.scale(to: 1.5, duration: 0.6), SKAction.scale(to: 0.6, duration: 0.6)]
        label.run(SKAction.repeatForever(SKAction.sequence(label_action)))
        //view.overlaySKScene?.addChild(label)
        //self.victory_semaphore.signal()
        self.victory = true
    }
    
    func onRoundStarts()
    {
        self.before_round_semaphore.signal()
    }
    
    func onRoundEnds()
    {
        self.round_end_semaphore.signal()
    }
    
    func doRound()
    {
        self.rounds += 1
        self.onRoundStarts()
        self.before_round_semaphore.wait()
        for i in 0...numplayers
        {
            self.current_turn_player = i
            self.doTurn(player: i)
            if(self.victoryConditionCheck())
            {
                self.onVictory(winner: i)
                self.victory_semaphore.wait()
                self.exitToMenu()
            }
        }
        self.onRoundEnds()
        self.round_end_semaphore.wait()
    }
    
    func doTurn(player:Int)
    {

        self.turns += 1
        
        print(self.turns)
        
        let executes_turn = self.beforeTurnStarts(player: player)
        self.before_turn_semaphore.wait()
        if(executes_turn == false)
        {
            return
        }
        self.touchEnabled = true

        self.movement_semaphore.wait()
        self.touchEnabled = false
        
        self.turnsEnd(player: player)
        self.turns_end_semaphore.wait()
    }
    
    func exitToMenu()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "MenuScreen") as! GameViewController
        self.present(resultViewController, animated:true, completion:nil)
        return
    }
    
    func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        print("asdfasdf")
        self.finalizeTurn()
    }
    
    func highLightSquares(squares:[(x:Int, y:Int)], color:UIColor, duration:Float)
    {
        let lambda = {
            (iter:Int) in
            let pos = squares[iter]
            self.highLightModel(model: (self.board?.board[pos.x][pos.y]?.node)! , color: color, duration: duration)
        }
        DispatchQueue.concurrentPerform(iterations: squares.count, execute: lambda)
    }

    func squareArrayContains(array:[(x:Int, y:Int)], element:(x:Int, y:Int) ) -> Bool
    {
            let compare_lambda =
                {
                    (a:(x:Int, y:Int)) in
                    return a.x == element.x && a.y == element.y
            }
        return  array.contains(where: compare_lambda)
    }
    
    func highLightModel(model:SCNNode, color:UIColor, duration:Float)
    {
        
       let lambda =  { (node:SCNNode, b:UnsafeMutablePointer<ObjCBool>)-> Void in
            //let node = model
            if(node.geometry == nil)
            {
                return
            }
            let material = node.geometry!.firstMaterial!
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(duration)
            SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(duration)
            material.emission.contents = UIColor.black
            SCNTransaction.commit()
            //model.runAction(SCNAction.fadeOut(duration: 20))
        }
        
        material.emission.contents = color
        
        SCNTransaction.commit()
        }
        model.enumerateChildNodes(lambda)
    }
    
    func getTouchedElements(_ gestureRecognize: UIGestureRecognizer) -> [SCNHitTestResult]
    {
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        return hitResults
    }
    

    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView 
        let scnView = self.view as! SCNView
        let point = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(point, options: [:])
        let con_point = scnView.overlaySKScene?.convertPoint(fromView: point)
        
        
        if(self.exitButton.contains(con_point!) || self.victory)
        {
            self.exitToMenu()
        }
        
        if(self.touchEnabled)
        {
            self.handleTouchOnTurn(gestureRecognize)
        }
        return
        
        
        
        
        // check what nodes are tapped

        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
    
}
