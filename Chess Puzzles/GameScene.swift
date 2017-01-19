//
//  GameScene.swift
//  BrainGame
//
//  Created by eicke on 9/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import SpriteKit
import GameplayKit
import SceneKit




class GameScene: SKScene {  
    
    
    private enum status {case START_SCREEN, GAME_SELECT_SCREEN, GAME_SELECTED_SCREEN, GAME_SCREEN}
    
    
    var viewController:GameViewController? //
    private var gameStatus = status.START_SCREEN
    private var title : SKLabelNode?
    private var start : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var center = CGPoint()
    private var relative_width_Max:Float = 0.0
    private var relative_height_Max:Float = 0.0
    private var controls:[GameButton] = []
    private var bgImage:SKSpriteNode = SKSpriteNode()
    private var brainGuy:SKSpriteNode = SKSpriteNode()
    private let bgImageName:String = "bg.png"
    private let brainGuyName:String = "brainguy.png"
    private var sptitesLayers:[[SKSpriteNode]] = []
    private var veil:SKSpriteNode = SKSpriteNode()

    private var game_selection_node = SKSpriteNode()
    private var game_ok_cancel_node = SKSpriteNode()
    private var game_selection_ok_node = GameButton(imageNamed: "ok.png")
    private var game_selection_cancel_node = GameButton(imageNamed: "cancel.png")
    private var game_description:[String:String] = [:]
    private var game_description_labelnode:[String:SKLabelNode] = [:]

    let image_names = ["reinas.gif", "bishop.png", "knight.png", "knights36.png"]
    let handler_functions = [#selector(GameScene.nQueensGame(button:)), #selector(GameScene.bishopsGame(button:)), #selector(GameScene.KnightsGame(button:)), #selector(GameScene.Knights36(button:))]
    
    var game_selected:String = ""
    
    
    static func multipleLineText(labelInPut: SKLabelNode) -> SKLabelNode {
        let text = labelInPut.text!
        
        let subStrings:[String] = text.components(separatedBy: "\n")
        var labelOutPut = SKLabelNode()
        var subStringNumber:Int = 0
        for subString in subStrings {
            let labelTemp = SKLabelNode(fontNamed: labelInPut.fontName)
            labelTemp.text = subString
            labelTemp.fontColor = labelInPut.fontColor
            labelTemp.fontSize = labelInPut.fontSize
            labelTemp.position = labelInPut.position
            labelTemp.horizontalAlignmentMode = labelInPut.horizontalAlignmentMode
            labelTemp.verticalAlignmentMode = labelInPut.verticalAlignmentMode
            let y:CGFloat = CGFloat(subStringNumber) * labelInPut.fontSize
            print("y is \(y)")
            if subStringNumber == 0 {
                labelOutPut = labelTemp
                subStringNumber += 1
            } else {
                labelTemp.position = CGPoint(x: 0, y: -y)
                labelOutPut.addChild(labelTemp)
                subStringNumber += 1
            }
        }
        return labelOutPut
    }
    
    
    
    func createGameSelectionMenu()
    {
        let QueensGameDescription =  "Pace eight queens without threaten between them."
        let BishopsGameDescription = "Place the bishops on the squares with their color mark."
        let KnightsGameDescription = "Place the knights on the squares with their color mark."
        let Knights36GameDescription = "Go throug all the squares using the knight without stepping any of them twice."
        self.game_description["nQueens"] = QueensGameDescription
        self.game_description["Bishops"] = BishopsGameDescription
        self.game_description["Knights"] = KnightsGameDescription
        self.game_description["Knights36"] = Knights36GameDescription

        for i in self.game_description.keys
        {
            let label = GameScene.multipleLineText(labelInPut: SKLabelNode(text: self.game_description[i]))
            label.color = UIColor.black
            label.fontColor = UIColor.white
            label.fontSize = 18
            self.game_description_labelnode[i] = label
            label.isHidden = false
            label.name = i
            label.alpha = 0
            self.addChild(label)
        }
        self.game_selection_ok_node.name =  "ok"////
        self.game_selection_cancel_node.name = "cancel"
        
        //self.game_ok_cancel_node.position.y = -self.game_selection_node.size.height
        
        let scale_x = self.size.width / self.game_selection_ok_node.size.width

        self.game_selection_cancel_node.setScale(scale_x * 0.05)
        self.game_selection_ok_node.setScale(scale_x * 0.05)
        self.game_selection_ok_node.position.x =  -self.size.width * 0.1////
        self.game_selection_cancel_node.position.x = -self.game_selection_ok_node.position.x
        for i in self.game_description.keys
        {
            self.game_selection_node.childNode(withName: i)?.alpha = 0.0 //isHidden = true
        }
        self.game_selection_node.position.y = -self.size.height * 0.1
        self.game_selection_cancel_node.position.y = -self.size.height * 0.2
        self.game_selection_ok_node.position.y = self.game_selection_cancel_node.position.y
        
        self.addChild(self.game_selection_ok_node)
        self.addChild(self.game_selection_cancel_node)
        self.veil.addChild(self.game_selection_node)
        self.game_selection_ok_node.alpha = 0.0
        self.game_selection_cancel_node.alpha = self.game_selection_ok_node.alpha

    }
    
    override func didMove(to view: SKView) {
        
        
        
        
        self.size = CGSize(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.relative_height_Max = 1.0
        self.relative_width_Max = Float(self.size.width) / Float(self.size.height)
        self.backgroundColor = SKColor(red: 107/255.0, green: 88/255.0, blue: 193/255.0, alpha: 1.0)
        self.center = CGPoint(x: self.size.width / 2, y: self.size.height / 2 )
        self.anchorPoint = CGPoint(x: 0.5 , y: 0.5 )
        self.showSplashScreen()
        
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: 0.01, height: 0.01), cornerRadius: w * 0.3)
        self.createGameSelectionMenu()
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    /////////////////
    func createSwingingActions(node:SKNode, num_vectors:Int, max_vector_lenght:Double) -> [SKAction]
    {
        var moves:[SKAction] = []
        var inverses = moves
        for _ in 0...num_vectors
        {
            /*
             let point_x = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght))) //+ i.position.x
             let point_y = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght))) //+ i.position.y
             let absoluteDisplacement = self.absolutePosition(relative: CGPoint(x: point_x, y: point_y))
             let point = CGPoint(x: node.position.x + absoluteDisplacement.x, y: node.position.y + absoluteDisplacement.y)
             */
            let point_x = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght))) //+ i.position.x
            let point_y = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght))) //+ i.position.y
            let absoluteDisplacement = self.absolutePosition(relative: CGPoint(x: point_x, y: point_y))
            let point = CGVector(dx: /*node.position.x + absoluteDisplacement.x*/point_x, dy: /*node.position.y + absoluteDisplacement.y*/ point_y)
            moves.append(SKAction.move(by: point, duration: 1.0))
            ////////////////
            let inverse = CGVector(dx: -point_x, dy: -point_y)
            inverses.append(SKAction.move(by: inverse, duration: 1.0))
        }
        moves.append(contentsOf: inverses.reversed())
        //moves.append(SKAction.move(to: node.position, duration: 1.0))
        return moves
    }
    /////////////////
    
    
    func randomFloat(min:Float, max:Float) -> Float
    {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(min - max) + (min < max ? min : max)
    }
    
    func showSelectGameScreen()
    {
        var start_seq = [SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]
        start_seq = [SKAction.repeat(SKAction.sequence(start_seq), count: 7)]
        start_seq.append(SKAction.move(to: absolutePosition(relative: CGPoint(x: 0, y:-2)), duration: 0.5))
        
        let step4 = {
            self.start?.removeFromParent()
            self.start?.position = self.absolutePosition(relative: CGPoint(x:0, y: -0.4))
            let transitions = [SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5)]
            self.start?.text = "Select a game"
            self.start?.run(SKAction.repeatForever(SKAction.sequence(transitions)))
            //self.start?.addChild(self.game_selection_node)///////////////////////////
            self.bgImage.addChild(self.start!)
        
        }
        
        let step3 =
            {
                
                let num_vectors = 8
                var moves:[SKAction] = []///hacer los moves
                let max_vector_lenght = 5.0
                //let image_names = ["reinas.gif", "bishop.png", "knight.png", "knights36.png"]
                //let handler_functions = ["GameScene.nQueensGame(_:)", "bishopsGame", "horsesGame", "niputaIdeaGame"]
                //let handler_functions = [#selector(GameScene.nQueensGame(button:)), #selector(GameScene.bishopsGame(button:)), #selector(GameScene.KnightsGame(button:)), #selector(GameScene.Knights36(button:))]
                self.controls = self.createButtons(images_paths: self.image_names, handler_functions: self.handler_functions, handler: self)
                self.controls = self.setButtonsRowPosition(buttons: self.controls, area_: CGSize(width: 0.25, height: 0.25), surface: CGRect(x: 0.15, y: 0.4, width: 1.0, height: 0.4))
                let common_node = SKNode()
                //common_node.position.y = 0.2
                for i in self.controls
                {
                    /*for _ in 0...num_vectors
                    {
                        let point_x = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght))) //+ i.position.x
                        let point_y = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght))) //+ i.position.y
                        let absoluteDisplacement = self.absolutePosition(relative: CGPoint(x: point_x, y: point_y))
                        let point = CGPoint(x: i.position.x + absoluteDisplacement.x, y: i.position.y + absoluteDisplacement.y)
                        moves.append(SKAction.move(to: point, duration: 1.0))
                    }
                    moves.append(SKAction.move(to: i.position, duration: 1.0))*/
                    moves = self.createSwingingActions(node: i, num_vectors: num_vectors, max_vector_lenght: max_vector_lenght)
                    i.run(SKAction.repeatForever(SKAction.sequence(moves)))
                    common_node.addChild(i)
                    moves.removeAll()
                }
                
                    let position_aux = self.controls[0].position.y * 0                                                          //0 respecto del padre commonnode
                    common_node.position.y = self.absolutePosition(relative: CGPoint(x: 0, y: -2)).y
                    let mov_seq = [SKAction.moveTo(y: position_aux * -1.5, duration: 1), SKAction.moveTo(y: position_aux * 1.5, duration: 0.2),SKAction.moveTo(y: position_aux, duration: 0.2)]
                    //    SKAction.repeatForever(SKAction.sequence(moves))]
                    common_node.run(SKAction.sequence(mov_seq), completion: step4)//(y: position_aux, duration: 1))
                    self.addChild(common_node)
                
                    
                    /*
                    moves.append(SKAction.move(to: i.position, duration: 1.0))
                    let position_aux = i.position.y
                    i.position.y = self.absolutePosition(relative: CGPoint(x: 0, y: -2)).y
                    let mov_seq = [SKAction.moveTo(y: position_aux * -1.5, duration: 1), SKAction.moveTo(y: position_aux * 1.5, duration: 0.2),SKAction.moveTo(y: position_aux, duration: 0.2),SKAction.repeatForever(SKAction.sequence(moves))]
                    i.run(SKAction.sequence(mov_seq))//(y: position_aux, duration: 1))
                    self.addChild(i)
                    moves.removeAll()*/
                //}
        }
        
        let step2 = {
            self.title?.run(SKAction.move(to: self.absolutePosition(relative: CGPoint(x:0, y:0.30)), duration:0.5 ), completion: step3)
            print("hecho")
        }
        let step1 = {
            self.veil.run(SKAction.fadeOut(withDuration: 0.3), completion: step2)
            print("hecho")
        }
        
        
        self.start?.run(SKAction.sequence(start_seq), completion: step1)

    
    }
    
    
    func showSplashScreen()
    {
        
        //self.gameStatus = status.START_SCREEN
        
        self.veil.size = self.size
        self.veil.color = SKColor.black
        self.veil.alpha = 0.8
        
        self.backgroundColor = SKColor(red: 107/255.0, green: 88/255.0, blue: 193/255.0, alpha: 1.0)
        self.brainGuy = SKSpriteNode(imageNamed: brainGuyName)//(imageNamed: self.bgImageName)
        self.bgImage = SKSpriteNode(imageNamed: bgImageName)
        self.bgImage.position = CGPoint.zero
        self.bgImage.size.width /= self.bgImage.size.height / self.size.height
        self.bgImage.size.height = self.size.height
        var  brainguy_animation = [SKAction.rotate(byAngle: -0.30, duration: 0.7), SKAction.rotate(byAngle: 0.30, duration: 0.7)]
        brainguy_animation.append(contentsOf: brainguy_animation.reversed())
        
        self.brainGuy.position = self.bgImage.position
        self.brainGuy.position.y -= absolutePosition(relative: CGPoint(x:0, y:0.060)).y
        self.brainGuy.size.height /= self.brainGuy.size.width / self.bgImage.size.width
        self.brainGuy.size.width = self.bgImage.size.width
        self.brainGuy.setScale(0.7)
        self.brainGuy.run(SKAction.repeatForever(SKAction.sequence(brainguy_animation)))
  
        self.start = SKLabelNode()
        self.start?.text = "Touch to start"
        self.start?.fontName = "Arial"
        self.start?.alpha = 0.5
        self.start?.fontSize = 20
        self.start?.position = absolutePosition(relative: CGPoint(x:0, y: -0.1))
      
        self.title = SKLabelNode()
        self.title?.text = "BRAIN GAMES"
        self.title?.fontName = "Chalkduster"
        self.title?.fontSize = 85
        self.title?.position = absolutePosition(relative: CGPoint(x:0, y: -0.15))
        self.title?.setScale(0.0)
        var title_shows_actions = [SKAction.scale(to: 0.8, duration: 0.1), SKAction.scale(to: 1.2, duration: 0.1)]
        title_shows_actions.append(contentsOf: title_shows_actions)
        //title_beats_actions.append(contentsOf: title_beats_actions)
        title_shows_actions.insert(SKAction.scale(to: 1.2, duration: 0.8), at: 0)
        title_shows_actions.append(SKAction.scale(to: 1.0, duration: 0.1))
        //title_shows_actions.append(SKAction.move(to: absolutePosition(relative: CGPoint(x:0, y:0.25)), duration:0.5 ))
        var title_shows_actions_loop = [SKAction.scale(to: 0.9, duration: 1.0), SKAction.scale(to: 1.0, duration: 1.0)]
        title_shows_actions_loop.append(contentsOf: title_shows_actions_loop)
        title_shows_actions.append(SKAction.repeatForever(SKAction.sequence(title_shows_actions_loop)))
        self.title?.run(SKAction.sequence(title_shows_actions))
        
        //self.title?.run(SKAction.repeatForever(SKAction.sequence(title_shows_actions)))
       
        self.bgImage.addChild(self.brainGuy)
        self.bgImage.addChild(self.veil)
        self.title?.addChild(self.start!)
        self.bgImage.addChild((self.title)!)
        //////////////////////////////////////////////////
        //self.title?.addChild(self.game_selection_node)///////////////////////////

        /////////////////////////////////////////////////
        self.addChild(self.bgImage)

        
    }
    
    func unselectGame()
    {
        self.gameStatus = status.GAME_SELECT_SCREEN
        //self.game_selection_node.run(SKAction.fadeOut(withDuration: 1), completion: lambda)
        self.veil.run(SKAction.fadeOut(withDuration: 1))
        //self.game_selection_cancel_node.removeFromParent()
        //self.game_selection_ok_node.removeFromParent()
        self.game_selection_ok_node.run(SKAction.fadeOut(withDuration: 1))
        self.game_selection_cancel_node.run(SKAction.fadeOut(withDuration: 1))
        for i in self.game_description_labelnode.values
        {
            i.run(SKAction.fadeOut(withDuration: 1))
        }
        self.game_selected = ""
        
        for i in self.controls
        {
            i.run(SKAction.fadeIn(withDuration: 1))
        }
    }
    
    
    
    
    func showGameSelectedScreen(button:GameButton, gamename:String)
    {
    let time_ = 0.4
    let button_position = absolutePosition(relative: CGPoint(x: 0.0, y: 0.25))
    self.game_selection_node.alpha = 1.0
    
    self.game_description_labelnode[gamename]?.run(SKAction.fadeIn(withDuration: 1))
    self.veil.run(SKAction.fadeAlpha(by: 1.0, duration: time_))
    self.game_selected = gamename
    //let actions = [SKAction.move(to:button_position, duration: time_), SKAction.fadeIn(withDuration: time_)]
    //button.run(SKAction.sequence(actions))
    self.game_selection_ok_node.run(SKAction.fadeIn(withDuration: 1))
    self.game_selection_cancel_node.run(SKAction.fadeIn(withDuration: 1))
        for i in self.controls
        {
            i.run(SKAction.fadeOut(withDuration: 1))
        }
    
    }
    
    
    
    func nQueensGame(button:Any)
    {
        let name = "nQueens"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
        //self.removeAllChildren()
        //self.viewController?.changeToGameScene(game: name, options: [:])
    }
    
    func bishopsGame(button:Any)
    {
        let name = "Bishops"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
        //self.removeAllChildren()
        //self.viewController?.changeToGameScene(game: name, options: [:])
    }
    
    func KnightsGame(button:Any)
    {
        let name = "Knights"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
        //self.removeAllChildren()
        //self.viewController?.changeToGameScene(game: name, options: [:])
    
    }
    
    func Knights36(button:Any)
    {
        let name = "Knights36"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
        //self.removeAllChildren()
        //self.viewController?.changeToGameScene(game: name, options: [:])
    }
    
    func createButtons(images_paths:[String], handler_functions:[Selector], handler:NSObject) -> [GameButton]
    {
        var buttons:[GameButton] = Array(repeating: GameButton(), count: images_paths.count)
        for i in 0...buttons.count - 1
        {
            buttons[i] = GameButton(imageNamed: images_paths[i])
            //let sel = NSSelectorFromString(handler_functions[i] + "(_:)")
            buttons[i].handler_function = handler_functions[i]
            buttons[i].handler_object = handler
        }
        return buttons
    }
    
    
    func createButtons(images_paths:[String], handler_functions:[String], handler:NSObject) -> [GameButton]
    {
        var buttons:[GameButton] = Array(repeating: GameButton(), count: images_paths.count)
        for i in 0...buttons.count - 1
        {
            buttons[i] = GameButton(imageNamed: images_paths[i])
            let sel = NSSelectorFromString(handler_functions[i] + "(_:)")
            buttons[i].handler_function = sel//#selector(sel("_:"))
            buttons[i].handler_object = handler
        }
        return buttons
    }
    
    func setButtonsRowPosition(buttons:[GameButton], area_:CGSize, surface:CGRect) -> [GameButton]
    {
        var area = area_
        area.width /= CGFloat(self.relative_width_Max)
        if(surface.size.height < area.height || surface.size.width < area.width)
        {
            return []
        }
        let offset = Float ((Float(surface.size.width) - (Float(area.width) * Float(buttons.count)) ) / Float(buttons.count))
        var pos:Float = 0.0
        for i in 0...buttons.count - 1
        {
            buttons[i].size = CGSize(width: area.width * self.size.width , height: area.height * self.size.height )
            buttons[i].position = surface.origin
            buttons[i].position.x += CGFloat(pos)
            buttons[i].position = absolutePosition(relative: buttons[i].position)
            buttons[i].position.x -= absolutePosition(relative:self.anchorPoint).x                                                      //Remiendo de mierda
            buttons[i].position.y -= absolutePosition(relative:self.anchorPoint).y
            pos += Float(area.width) + offset
        }
        return buttons
    }
    
    
    func absolutePosition(relative:CGPoint) -> CGPoint
    {
        return CGPoint(x: self.size.width * relative.x , y: self.size.height * relative.y)
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        switch self.gameStatus
        {
        case status.START_SCREEN:
                self.gameStatus = status.GAME_SELECT_SCREEN
                self.showSelectGameScreen()
        return
        
        case status.GAME_SELECTED_SCREEN:
            let nodes = self.nodes(at: position)
           //for i in nodes
            //{
               print("NODE: " + String(describing: self.game_selection_cancel_node.position))
            if(self.game_selection_cancel_node.contains(pos))
            {
                self.unselectGame()
            }
            if(self.game_selection_ok_node.contains(pos))
            {
                self.removeAllChildren()
                self.viewController?.changeToGameScene(game: self.game_selected, options: [:])
            }
            
            //}
            break
            
        case status.GAME_SELECT_SCREEN:
            for i in self.controls
            {
                if(i.isHidden)
                {
                    continue
                }
                if(i.contains(pos))
                {
                    i.handler_object.performSelector(onMainThread: i.handler_function, with: i as Any, waitUntilDone: true)
                }
            }
            break
        default:
        break
        }
        
        
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)*/

        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
