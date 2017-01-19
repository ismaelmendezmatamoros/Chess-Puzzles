//
//  KnightsGame.swift
//  BrainGames3D
//
//  Created by eicke on 17/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//


import Foundation
import SceneKit

class KnightsGame: BoardGameViewController
{
    
    var impossibleSquares:[Piece:[(x:Int, y:Int)]] = [:]
    var imposibleSquaresArray:[(x:Int, y:Int)] = []
    let piece_name = "Knight"
    let team_names = ["white", "red"]
    var initial_positions:[String:[(x:Int, y:Int)]] = [:]
    
    let team_colors = [UIColor.init(red: 250/255, green: 203/255, blue: 122/255, alpha: 1), UIColor.init(red: 81/255, green: 32/255, blue: 65/255, alpha: 1)]
    var lightNode:SCNNode = SCNNode()
    var numBishops = 0
    var board_x = 0
    var board_y = 0
    var bishop_selected:Piece? = nil
    var possiblesFor:[Piece:[(x:Int, y:Int)]] = [:]
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        //self.setupGame()
        //self.setupScene()
    }
    
    override func setupGame() {
        
        self.numBishops = 2
        self.board_x = 4
        self.board_y = 4
        super.setupGame()
        
    }
    
    override func setupScene()
    {
        self.scene.background.contents = UIColor.black
        
        var map = Array.init(repeating: Array.init(repeating: 1, count: self.board_x), count: self.board_y)
        map[0][3] = 0
        map[0][1] = map[0][3]
        map[0][2] = map[0][3]
        map[2][3] = map[0][3]
        map[3][2] = map[0][3]
        map[3][3] = map[0][3]
        
        // let whites = self.loadModelsFromFile(filename: "Piecescollada-3.dae", names: [piece_name], color:UIColor.red)
        self.pieces = self.generateTeamsPieces(modelsfilename: "Piecescollada-3.dae", teams: self.team_names, piecenames: [self.piece_name], color: self.team_colors)
        
        let size = (self.pieces.values.first?.node.boundingBox.max.x)! - (self.pieces.values.first?.node.boundingBox.min.x)!
        self.board = Board.init(map: map, squaresize: Float(size), squareheight: size * 0.2 , color1: UIColor.brown /*self.team_colors[0]*/, color2: /*self.team_colors[1]*/ UIColor.darkGray, piece_height: (self.pieces.values.first?.node.boundingBox.max.y)!)
        //////////
        //self.pieces[piece_name] = Queen(piece: pieces[piece_name]!)
        //let lightNode = SCNNode()
        lightNode.light = SCNLight()
        
        
        lightNode.light?.type = .omni
        lightNode.light?.spotInnerAngle = 75;
        lightNode.light?.spotOuterAngle = 75;
        lightNode.light?.shadowRadius = 100.0;
        lightNode.light?.intensity = 1500
        lightNode.light?.zFar = 10000;
        lightNode.light?.castsShadow = false
        lightNode.position.x = (self.board?.boundingBox.max.x)! / 2
        lightNode.position.z = (self.board?.boundingBox.max.z)! * 1 // 2
        lightNode.position.y = size * 2.5
        //lightNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 10, y: 0, z: 3.5, duration: 2)))
        self.scene.rootNode.castsShadow = true
        //self.board?.addChildNode(lightNode)
        //lightNode.addChildNode(self.board!)
        let constraint = SCNLookAtConstraint(target: self.board)
        lightNode.constraints = [constraint]
        //self.scene.rootNode.addChildNode(lightNode)
        
        
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        //////////
        
        //let floor = SCNNode(geometry: SCNPlane(width: CGFloat(size * 50) , height: CGFloat(size * 50)))
        //self.board?.addChildNode(floor)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        //scene.rootNode.addChildNode(cameraNode)
        
        
        //self.scene.rootNode.runAction(SCNAction.rotateBy(x: 0.40, y: 0.0, z: 0, duration: 1))
        //cameraNode.addChildNode(self.board!)
        self.scene.rootNode.addChildNode(board!)
        self.board?.addChildNode(lightNode)
        self.board?.position.y = (self.pieces.values.first?.node.boundingBox.min.y)! - (board?.boundingBox.max.y)!
        
        //////////////////
        //var piece = Knight(piece: self.pieces[piece_name])
        //piece.setna
        
        let positions = [[(x:1, y:3),(x:2, y:1)],[(x:0, y:0),(x:2, y:0)]]
        
        //sleep(2)
        for n in 0...self.team_names.count - 1 {
            self.initial_positions[self.team_names[n]] = []
            for i in 0...self.numBishops - 1 {
                let knight = Knight(piece: self.pieces[team_names[n] + "-" + self.piece_name]! )
                knight.setName(name: knight.node.name! + String(i))
                knight.team = n
                let position = positions[n][i]
                knight.node.eulerAngles.y = Float(0.5 * 3.14 * [-1.0, 1.0][n])
                //knight.node.runAction(SCNAction.fadeOut(duration: 0))
                self.placePiece(piece: knight, position: position)
                self.initial_positions[team_names[n]]?.append(position)
                self.initial_positions[self.team_names[n]]?.append(position)
                self.board?.setSingleCharacterOnSquare(position: position, text: "x", text_color: self.team_colors.reversed()[n])
                //self.dropPiecesAnimation(piece: knight, duration: 1)
                //knight.node.runAction(SCNAction.fadeIn(duration: 0))
            }
        }
        Piece.default_y_position = (self.board?.pieces_on_board.keys.first?.node.position.y)!
        self.showExitButton()
        super.setupScene()

        

        
        //////////////////
    }
    
    override func victoryConditionCheck() -> Bool {
        var name = self.team_names.first
        let lambda = {
            (a:Piece) -> Bool in
            return self.team_names[a.team] == name
        }
        let team1 = self.board?.pieces_on_board.keys.filter(lambda).reversed()
        name = self.team_names[1]
        let team2 = self.board?.pieces_on_board.keys.filter(lambda).reversed()
        
        //////team1
        let cond2 = team1?.filter({ (a:Piece) -> Bool in
            return  self.squareArrayContains(array: self.initial_positions[self.team_names[1]]!, element: (self.board?.pieces_on_board[a])!) == false
        }).isEmpty
        ///////team2
        let cond1 = team2?.filter({ (a:Piece) -> Bool in
            return  self.squareArrayContains(array: self.initial_positions[self.team_names[0]]!, element: (self.board?.pieces_on_board[a])!) == false
        }).isEmpty
        
        return cond1! && cond2!
    }
    
    override func turnsEnd(player: Int) {
        self.impossibleSquares.removeAll()
        for i in (self.board?.pieces_on_board.keys)!
        {
            self.impossibleSquares[i] = i.possiblesMovements(board: self.board!, position: (self.board?.pieces_on_board[i])!)
        }
        self.moves.text = "moves: \(self.turns)"
        super.turnsEnd(player: player)
    }
    
    func getPossiblesFor(piece:Piece) -> [(x:Int, y:Int)]
    {
        let rivals = self.board?.pieces_on_board.keys.filter({ (a:Piece) -> Bool in
            return a.team != piece.team
        })
        
        var final_possible:[(x:Int, y:Int)] = []
        /*var rivals_possibles:[(x:Int, y:Int)] = []
        for i in rivals!
        {
            for n in self.impossibleSquares[i]!
            {
                rivals_possibles.append(n)
            }
            
        }
         */
        
        final_possible = impossibleSquares[piece]!.filter({ (a:(x: Int, y: Int)) -> Bool in
            return (/*self.squareArrayContains(array: rivals_possibles, element:a) == false && */self.squareArrayContains(array: (self.board?.pieces_on_board.values.reversed())!, element: a) == false)
        })
        print(piece.node.name! + final_possible.description)
        return final_possible
    }
    
    override func beforeTurnStarts(player: Int) -> Bool {
        for i in (self.board?.pieces_on_board.keys)!
        {
            self.possiblesFor[i] = self.getPossiblesFor(piece: i)
        }
        super.beforeTurnStarts(player: player)
        return true
    }
    
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        //piece.node.name = piece_name + String(self.turns)
        
        self.board?.placePiece(piece: piece, position: position)
        //piece.node.rotation.y = Float(2)// +  Float(1)
        piece.node.runAction(SCNAction.fadeIn(duration: 10))
        let possibles = piece.possiblesMovements(board: board!, position: position)
        self.impossibleSquares[piece] = possibles
    }
    
    
    func movePiece(piece:Piece, position:(x:Int, y:Int))
    {
        var square_position = self.board?.board[(position.x)][(position.y)]?.node?.position
        piece.node.removeAllActions()
        piece.node.position.y = Piece.default_y_position
        square_position?.y = (piece.node.position.y)
        let control = semaphore_t.init(0)
        self.board?.pieces_on_board[piece] = position
        piece.node.runAction((SCNAction.move(to: square_position!, duration: 1.0)), completionHandler: {
            
            semaphore_signal(control)
            
        })
        semaphore_wait(control)
        
    }
    
    override func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        let movement = CGFloat(self.board!.size) * CGFloat(0.1)
        let touched = self.getTouchedElements(gestureRecognize)
        if touched.count > 0
        {
            for i in (self.board?.pieces_on_board.keys)!
            {
                print (i.node.name! + " " + (touched.first?.node.name)!)
                if (i.node.name == touched.first?.node.name || (i.node.childNode(withName:(touched.first?.node.name)!, recursively: true)) != nil) ///
                {
                    if(self.bishop_selected != nil)
                    {
                        self.bishop_selected?.node.removeAllActions()
                        self.bishop_selected?.node.position.y = Piece.default_y_position
                    }
                    let vibrate_action_slow = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.5),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.5)]), count: 3)
                    self.bishop_selected = i
                    self.bishop_selected?.node.runAction(SCNAction.repeatForever(vibrate_action_slow))
                    print("Slected: " + i.node.name!)
                    self.highLightSquares(squares: self.possiblesFor[i]!, color: UIColor.blue, duration: 1.0)
                    print( self.possiblesFor[i]!.description )
                    return
                }
            }
            let position = self.board?.getSquarePosition(node: (touched.first?.node)!)
            print(String(describing: position))
            if(position == nil)
            {
                return
            }
            if (self.bishop_selected != nil)
            {
                if (self.squareArrayContains(array: self.possiblesFor[self.bishop_selected!]!, element: position!))
                {
                    self.movePiece(piece: self.bishop_selected!, position: position!)
                    self.bishop_selected = nil
                    self.finalizeTurn()
                    return
                    
                }
                for i in (self.board?.pieces_on_board.keys)!
                {
                    if (self.squareArrayContains(array: self.impossibleSquares[i]!, element: position!) && i.team != self.bishop_selected?.team) ///
                    {
                        let vibrate_action_fast = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.1),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.1)]), count: 3)
                        i.node.runAction(vibrate_action_fast)
                    }
                    
                }
                return
            }
        }
    }
    
    
    
    
}
