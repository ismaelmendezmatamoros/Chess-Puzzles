
//
//  nQueensGame.swift
//  BrainGames3D
//
//  Created by eicke on 12/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit

class nQueensGame: BoardGameViewController
{
    var impossibleSquares:[Piece:[(x:Int, y:Int)]] = [:]
    var imposibleSquaresArray:[(x:Int, y:Int)] = []
    var numQueens = 0
    let piece_name = "Queen"
    var lightNode:SCNNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.numplayers = 1
    }
    
    override func setupGame()
    {
        self.numQueens = self.parameters["numQueens"] as! Int
    }

    override func setupScene()
    {
        self.scene.background.contents = UIColor.black
        let map = Array.init(repeating: Array.init(repeating: 1, count: self.numQueens), count: self.numQueens)
        self.pieces = self.loadModelsFromFile(filename: "Piecescollada-3.dae", names: [piece_name], color:UIColor.red)
        let size = (self.pieces[piece_name]?.node.boundingBox.max.x)! - (self.pieces[piece_name]?.node.boundingBox.min.x)!
        self.board = Board.init(map: map, squaresize: Float(size), squareheight: size * 0.2 , color1: UIColor.gray, color2: UIColor.black, piece_height: (pieces[piece_name]?.node.boundingBox.max.y)!)
        
        //////////
        self.pieces[piece_name] = Queen(piece: pieces[piece_name]!)
        //let lightNode = SCNNode()
        lightNode.light = SCNLight()

        
        lightNode.light?.type = .omni
        lightNode.light?.spotInnerAngle = 75;
        lightNode.light?.spotOuterAngle = 75;
        lightNode.light?.shadowRadius = 100.0;
        lightNode.light?.intensity = 1500
        lightNode.light?.zFar = 10000;
        lightNode.light?.castsShadow = true
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
        self.board?.position.y = (pieces[piece_name]?.node.boundingBox.min.y)! - (board?.boundingBox.max.y)!
        self.showOverlays()
        super.setupScene()
    }
    
    
    
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        //piece.node.name = piece_name + String(self.turns)
        
        self.board?.placePiece(piece: piece, position: position)
        //piece.node.isHidden = true
        /*let position0 = piece.node.position
        piece.node.position.y = 2000.0
        //piece.node.position = position0
        piece.node.runAction(SCNAction.move(to: position0, duration: 1))    */
        //self.dropPiecesAnimation(piece: piece, duration: 1) //piece.node.runAction(SCNAction.fadeIn(duration: 2.0))
        let possibles = piece.possiblesMovements(board: board!, position: position)
        self.impossibleSquares[piece] = possibles
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
    
    func loadImposibleSquaresArray()
    {
        var squares:[(x:Int, y:Int)] = []
        let other_pieces = self.board?.pieces_on_board.values.reversed()
        for i in self.impossibleSquares.values
        {
            for pos in i {
                if  (self.squareArrayContains(array: squares, element: pos) == false && self.squareArrayContains(array: other_pieces!, element: pos) == false)
                {
                    squares.append(pos)
                }
                
            }
        }
        self.imposibleSquaresArray = squares
    }

    override func beforeTurnStarts(player: Int) -> Bool
    {
        self.loadImposibleSquaresArray()
        self.highLightSquares(squares: self.imposibleSquaresArray, color: UIColor.blue, duration: 1.0)
        return super.beforeTurnStarts(player: player)
        
    }
 
    override func victoryConditionCheck() -> Bool {
        if (self.board?.pieces_on_board.count == self.numQueens)
        {
            _ = super.victoryConditionCheck()
            return true
        }
        return false
    }
    
    func removePiece(piece:Piece)
    {
        let step2 = {
            piece.node.removeFromParentNode()
            
            // self.finalizeTurn()
        }
        _ = self.board?.pieces_on_board.removeValue(forKey: piece)
        _ = self.impossibleSquares.removeValue(forKey: piece)
        self.loadImposibleSquaresArray()
        piece.node.runAction(SCNAction.fadeOut(duration: 1), completionHandler: step2)
    }
    
    override func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        let touched = self.getTouchedElements(gestureRecognize)
        if touched.count > 0
        {
            
            for i in (self.board?.pieces_on_board.keys)!
            {
                print (i.node.name! + " " + (touched.first?.node.name)!)
                if (i.node.name == touched.first?.node.name || (i.node.childNode(withName:(touched.first?.node.name)!, recursively: true)) != nil) ///
                {
                    self.removePiece(piece: i)      
                    return
                }
                
            }
            let position = self.board?.getSquarePosition(node: (touched.first?.node)!)
            print(String(describing: position))
            if(position == nil)
            {
                //self.finalizeTurn()
                return
            }
            if (self.squareArrayContains(array: self.imposibleSquaresArray, element: position!))
            {
                let movement = CGFloat(self.board!.size) * CGFloat(0.1)
                let vibrate_action = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.1),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.1)]), count: 3)
                for i in (self.board?.pieces_on_board.keys)!
                {
                    if (self.squareArrayContains(array: self.impossibleSquares[i]!, element: position!)) ///
                    {
                        i.node.runAction(vibrate_action)
                    }
                    
                }
                self.highLightSquares(squares: self.imposibleSquaresArray, color: UIColor.blue, duration: 1.0)
                
                //self.finalizeTurn()
                return
            }
            let queen = Queen.init(piece: pieces[piece_name]!)
            queen.node.rotation.x = -114
            //queen.node.rotation.y = 22.3
            //queen.node.runAction(SCNAction.rotateTo(x: -1.5, y: 0, z: 0, duration: 0))
            queen.setName(name: piece_name + String(self.turns))
            self.placePiece(piece: queen, position: position!)
            print(String( describing: self.scene.rootNode.camera?.technique?.dictionaryRepresentation))
            self.finalizeTurn()
        }
    }
    

}
