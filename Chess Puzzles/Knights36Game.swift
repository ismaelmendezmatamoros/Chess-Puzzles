//
//  Knights36Game.swift
//  BrainGames3D
//
//  Created by eicke on 18/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

/*
 * Clase del juego de recorrer el tablero con el caballo. El objetivo del juego es recorrer el tablero sin pasar dos veces por la misma casilla
 * Esta clase esta fuertemente basada en la clase KnightsGame
 */
class Knights36Game: BoardGameViewController
{
    
    var impossibleSquares:[Piece:[(x:Int, y:Int)]] = [:]
    var imposibleSquaresArray:[(x:Int, y:Int)] = []
    var piece_name = "Knight"
    let team_names = ["white"]
    var initial_positions:[String:[(x:Int, y:Int)]] = [:]
    var lightNode:SCNNode = SCNNode()
    var numKnights = 0
    var board_size = 0

    var knight_selected:Knight? = nil
    var possiblesFor:[Piece:[(x:Int, y:Int)]] = [:]
    let initial_position:(x:Int, y:Int) = (x:0, y:0)
    var visited_squares:[(x:Int, y:Int)] = []                               //Array de casillas por las que hemos pasado
    let marks_color = UIColor.red                                           //Color de las marcas que va dejando
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupGame() {                                         //Tablero de 6x6. Solo hay un caballo
        self.numKnights = 1
        self.board_size = 6
        super.setupGame()
    }
    
    /*
     * Inicia la escena. Funcion muy similar a la de BishopsGame con algunos cambios
     */
    override func setupScene()
    {
        self.scene.background.contents = UIColor.black
        let map = Array.init(repeating: Array.init(repeating: 1, count: self.board_size), count: self.board_size)
        self.pieces = self.loadModelsFromFile(filename: "Piecescollada-3.dae", names: [self.piece_name], color: UIColor.init(red: 81/255, green: 32/255, blue: 65/255, alpha: 1))
        let size = (self.pieces.values.first?.node.boundingBox.max.x)! - (self.pieces.values.first?.node.boundingBox.min.x)!
        self.board = Board.init(map: map, squaresize: Float(size), squareheight: size * 0.2 , color1: UIColor.brown, color2: UIColor.darkGray, piece_height: (self.pieces.values.first?.node.boundingBox.max.y)!)
        
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
        self.scene.rootNode.castsShadow = true
        let constraint = SCNLookAtConstraint(target: self.board)
        lightNode.constraints = [constraint]
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        self.scene.rootNode.addChildNode(board!)
        self.board?.addChildNode(lightNode)
        self.board?.position.y = (self.pieces.values.first?.node.boundingBox.min.y)! - (board?.boundingBox.max.y)!

        self.knight_selected = Knight(piece: self.pieces[piece_name]!)
        knight_selected?.setName(name: self.piece_name)
        self.placePiece(piece: self.knight_selected!, position: self.initial_position)
        self.knight_selected?.node.eulerAngles.y = Float(0.5 * 3.14  )
        Piece.default_y_position = (self.board?.pieces_on_board.keys.first?.node.position.y)!                       //En este caso solo hay que poner una pieza
        
        self.showOverlays()
        super.setupScene()
    }
    
    /*
     El numero de casillas visitadas ingual al numero de casillas del tablero menos 1 (la que ocupamos en ese momento)
     */
    override func victoryConditionCheck() -> Bool {
        return self.visited_squares.count == (self.board_size * self.board_size) - 1
    }
    
    /*
     *Si la casilla en la que terminamos el turno es la ultima visitada, estamos volviendo sobre nuestros pasos. Se queta la marca y se elimina de las casillas visitadas
     */
    override func turnsEnd(player: Int) {
        let position = self.board?.pieces_on_board[self.knight_selected!]
        if (self.squareArrayContains(array: self.visited_squares, element: position!) == false)
        {
            //self.visited_squares.append(position!)
        }
        else
        {
            self.visited_squares.removeLast()
            self.board?.removeMarkFromSquare(position: position!)
        }
        self.moves.text = "moves: \(self.turns)"
        super.turnsEnd(player: player)
    }
    
    /*
     * Las casillas posibles son las casillas al alcance que no hayan sido visitadas o bien la ultima visitada
     */
    func getPossiblesFor(piece:Piece) -> [(x:Int, y:Int)]
    {
        let lambda = {
            (a:(x:Int, y:Int)) -> Bool in
            let last_visited = (a.x == (self.visited_squares.last?.x)! && a.y == (self.visited_squares.last?.y)!)
            let no_visited = self.squareArrayContains(array: self.visited_squares , element: a) == false
            return (  no_visited ||  last_visited)
        }
        if (self.visited_squares.isEmpty)                           //Al empezar las casillas posibles son las que estabn ak alcance
        {
            return self.impossibleSquares[knight_selected!]!
        }
        else
        {
            return (self.impossibleSquares[knight_selected!]?.filter(lambda))!
        }

    }
    
    /*
     * Antes de empezar el turno simplemente ilumina aquillas casillas que podemios usar
     */
    override func beforeTurnStarts(player: Int) -> Bool {
        self.impossibleSquares.removeAll()
        self.impossibleSquares[self.knight_selected!] = self.knight_selected?.possiblesMovements(board: self.board!, position: (self.board?.pieces_on_board[self.knight_selected!])!)
        self.possiblesFor[self.knight_selected!] = self.getPossiblesFor(piece: self.knight_selected!)
        self.highLightSquares(squares: self.possiblesFor[self.knight_selected!]!, color: UIColor.blue, duration: 3.0)
        super.beforeTurnStarts(player: player)
        return true
    }
    
    /*
     *Misma que el resto de clases
     */
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        self.board?.placePiece(piece: piece, position: position)
        piece.node.runAction(SCNAction.fadeIn(duration: 10))
        let possibles = piece.possiblesMovements(board: board!, position: position)
        self.impossibleSquares[piece] = possibles
    }
    
    /*
     * Realiza un movimiento de pieza y su animacion. No es necesario esperar a que termine
     */
    func movePiece(piece:Piece, position:(x:Int, y:Int))
    {
        var square_position = self.board?.board[(position.x)][(position.y)]?.node?.position
        piece.node.removeAllActions()
        piece.node.position.y = Piece.default_y_position
        square_position?.y = (piece.node.position.y)
        self.board?.pieces_on_board[piece] = position
        piece.node.runAction((SCNAction.move(to: square_position!, duration: 1.0)))
        
    }
    
    
    /*
     * Funcion que recibe los toques de pantalla desde la superclase y los procesa
     */
    override func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        let movement = CGFloat(self.board!.size) * CGFloat(0.1)
        let touched = self.getTouchedElements(gestureRecognize)
        if touched.count > 0
        {
            for i in (self.board?.pieces_on_board.keys)!                                            //Si tocamos la pieza ilumina las casillas posibles
            {
                print (i.node.name! + " " + (touched.first?.node.name)!)
                if (i.node.name == touched.first?.node.name || (i.node.childNode(withName:(touched.first?.node.name)!, recursively: true)) != nil) ///
                {
                    self.highLightSquares(squares: self.possiblesFor[i]!, color: UIColor.red, duration: 1.0)
                    print( self.possiblesFor[i]!.description )
                    return
                }
            }
            let position = self.board?.getSquarePosition(node: (touched.first?.node)!)
            if(position == nil)
            {
                return
            }
                if (self.squareArrayContains(array: self.possiblesFor[self.knight_selected!]!, element: position!))     //Hemos tocado casilla
                {
                    let old_position = self.board?.pieces_on_board[self.knight_selected!]                               //Almacena la posicion antigua antes de pasar ala nueva
                    let last_visited = self.visited_squares.last
                    if (self.squareArrayContains(array: self.visited_squares, element: old_position!) == false && (position!.x != last_visited?.x || position?.y != last_visited?.y) ) //no esta visitada ni es la ultima visitada
                    {
                        self.visited_squares.append(old_position!)                                                  //mueve a la nueva casilla y coloca una marca numerica en la vieja
                        self.board?.setNumberOnSquare(position: old_position!, num: self.visited_squares.count, text_color: self.marks_color)
                    }
                    self.movePiece(piece: self.knight_selected!, position: position!)
                    self.finalizeTurn()
                    return
                }
                else
                {
                    let vibrate_action_fast = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.1),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.1)]), count: 3)
                    self.knight_selected?.node.runAction(vibrate_action_fast)
                    self.highLightSquares(squares: self.possiblesFor[self.knight_selected!]!, color: UIColor.blue, duration: 1.0)   //Si tocamos una casilla imposible vibra e ilumina las posibles
                }
            return
        }
    }
    
    
    
}
