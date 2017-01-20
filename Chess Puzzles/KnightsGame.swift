//
//  KnightsGame.swift
//  BrainGames3D
//
//  Created by eicke on 17/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//


import Foundation
import SceneKit


/*
 * Clase del juego de recorrer el tablero con el caballo. El objetivo del juego es recorrer el tablero sin pasar dos veces por la misma casilla
 * Esta clase esta fuertemente basada en la clase BishopsGame
 */
class KnightsGame: BoardGameViewController
{
    var impossibleSquares:[Piece:[(x:Int, y:Int)]] = [:]                                            //CAsillas al alcance de cada pieza, indexadas por pieza. Conserva el mismo nombre nQueensGame aunque aqui no tiene sentido
    var imposibleSquaresArray:[(x:Int, y:Int)] = []
    let piece_name = "Knight"
    let team_names = ["white", "red"]
    var initial_positions:[String:[(x:Int, y:Int)]] = [:]                                           //Ver BishpsGame para el resto de atributos
    
    let team_colors = [UIColor.init(red: 250/255, green: 203/255, blue: 122/255, alpha: 1), UIColor.init(red: 81/255, green: 32/255, blue: 65/255, alpha: 1)]
    var lightNode:SCNNode = SCNNode()
    var numKnights = 0
    var board_x = 0
    var board_y = 0
    var knight_selected:Piece? = nil
    var possiblesFor:[Piece:[(x:Int, y:Int)]] = [:]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func setupGame()
    {
        self.numKnights = 2                         //Dos caballos por equipo
        self.board_x = 4                            //tablero de 4x4 aunque algunas casillas estaran vacias
        self.board_y = 4
        super.setupGame()
        
    }
    
    /*
     * Inicia la escena. Funcion muy similar a la de BishopsGame con algunos cambios
     */
    override func setupScene()
    {
        self.scene.background.contents = UIColor.black
        var map = Array.init(repeating: Array.init(repeating: 1, count: self.board_x), count: self.board_y)
        map[0][3] = 0                                                                                           //0 indica que estas xcasillas estaran vacias
        map[0][1] = map[0][3]
        map[0][2] = map[0][3]
        map[2][3] = map[0][3]
        map[3][2] = map[0][3]
        map[3][3] = map[0][3]
        
        self.pieces = self.generateTeamsPieces(modelsfilename: "Piecescollada-3.dae", teams: self.team_names, piecenames: [self.piece_name], color: self.team_colors)
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
        lightNode.position.z = (self.board?.boundingBox.max.z)! * 1
        lightNode.position.y = size * 2.5
        self.scene.rootNode.castsShadow = true
        let constraint = SCNLookAtConstraint(target: self.board)
        lightNode.constraints = [constraint]

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        self.scene.rootNode.addChildNode(board!)
        self.board?.addChildNode(lightNode)
        self.board?.position.y = (self.pieces.values.first?.node.boundingBox.min.y)! - (board?.boundingBox.max.y)!

        let positions = [[(x:1, y:3),(x:2, y:1)],[(x:0, y:0),(x:2, y:0)]]                       //posiciones iniciales de cada equipo
        
        for n in 0...self.team_names.count - 1 {
            self.initial_positions[self.team_names[n]] = []
            for i in 0...self.numKnights - 1 {
                let knight = Knight(piece: self.pieces[team_names[n] + "-" + self.piece_name]! )
                knight.setName(name: knight.node.name! + String(i))
                knight.team = n
                let position = positions[n][i]
                knight.node.eulerAngles.y = Float(0.5 * 3.14 * [-1.0, 1.0][n])                  //se rotan para que esten enfrentados
                self.placePiece(piece: knight, position: position)
                self.initial_positions[team_names[n]]?.append(position)
                self.initial_positions[self.team_names[n]]?.append(position)
                self.board?.setSingleCharacterOnSquare(position: position, text: "x", text_color: self.team_colors.reversed()[n])       //Marca la casilla inicial con el color del otro equipo
            }
        }
        Piece.default_y_position = (self.board?.pieces_on_board.keys.first?.node.position.y)!
        self.showOverlays()
        super.setupScene()
    }
    
    /*
     * La misma que en BishopsGame
     */
    override func victoryConditionCheck() -> Bool {
        var name = self.team_names.first
        let lambda = {
            (a:Piece) -> Bool in
            return self.team_names[a.team] == name
        }
        let team1 = self.board?.pieces_on_board.keys.filter(lambda).reversed()
        name = self.team_names[1]
        let team2 = self.board?.pieces_on_board.keys.filter(lambda).reversed()
        
        let cond2 = team1?.filter({ (a:Piece) -> Bool in
            return  self.squareArrayContains(array: self.initial_positions[self.team_names[1]]!, element: (self.board?.pieces_on_board[a])!) == false
        }).isEmpty
        let cond1 = team2?.filter({ (a:Piece) -> Bool in
            return  self.squareArrayContains(array: self.initial_positions[self.team_names[0]]!, element: (self.board?.pieces_on_board[a])!) == false
        }).isEmpty
        
        return cond1! && cond2!
    }
    
    
    /*
     * La misma que en BishopsGame
     */
    override func turnsEnd(player: Int) {
        self.impossibleSquares.removeAll()
        for i in (self.board?.pieces_on_board.keys)!
        {
            self.impossibleSquares[i] = i.possiblesMovements(board: self.board!, position: (self.board?.pieces_on_board[i])!)
        }
        self.moves.text = "moves: \(self.turns)"
        super.turnsEnd(player: player)
    }
    
    
    /*
     * Calcula las casillas a las que puede saltar. En este caso no importa si el rival `puede atacar
     */
    func getPossiblesFor(piece:Piece) -> [(x:Int, y:Int)]
    {
        var final_possible:[(x:Int, y:Int)] = []
        final_possible = impossibleSquares[piece]!.filter({ (a:(x: Int, y: Int)) -> Bool in
            return (self.squareArrayContains(array: (self.board?.pieces_on_board.values.reversed())!, element: a) == false) //La unica reestriccion es que la casilla este libre
        })
        print(piece.node.name! + final_possible.description)
        return final_possible
    }
    /*
     *Calcula las casillas que estan alalcance de cada pieza
     **/
    override func beforeTurnStarts(player: Int) -> Bool {
        for i in (self.board?.pieces_on_board.keys)!
        {
            self.possiblesFor[i] = self.getPossiblesFor(piece: i)
        }
        super.beforeTurnStarts(player: player)
        return true
    }
    
    /*
     * Coloca una pieza en el tablero por primera vez
     */
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        self.board?.placePiece(piece: piece, position: position)
        piece.node.runAction(SCNAction.fadeIn(duration: 10))
        let possibles = piece.possiblesMovements(board: board!, position: position)
        self.impossibleSquares[piece] = possibles
    }
    
    /*
     * Mueve una pieza y realiza la animacion
     */
    func movePiece(piece:Piece, position:(x:Int, y:Int))
    {
        var square_position = self.board?.board[(position.x)][(position.y)]?.node?.position
        piece.node.removeAllActions()
        piece.node.position.y = Piece.default_y_position
        square_position?.y = (piece.node.position.y)
        let control = semaphore_t.init(0)
        self.board?.pieces_on_board[piece] = position
        piece.node.runAction((SCNAction.move(to: square_position!, duration: 1.0)), completionHandler: {            //espera que termine
            semaphore_signal(control)
        })
        semaphore_wait(control)
        
    }
    
    /*
     * Funcion que recibe los toques de pantalla desde la superclase y los procesa. Misma Que en BIshopsGame
     */
    override func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        let movement = CGFloat(self.board!.size) * CGFloat(0.1)
        let touched = self.getTouchedElements(gestureRecognize)
        if touched.count > 0
        {
            for i in (self.board?.pieces_on_board.keys)!
            {
                if (i.node.name == touched.first?.node.name || (i.node.childNode(withName:(touched.first?.node.name)!, recursively: true)) != nil)
                {
                    if(self.knight_selected != nil)
                    {
                        self.knight_selected?.node.removeAllActions()
                        self.knight_selected?.node.position.y = Piece.default_y_position
                    }
                    let vibrate_action_slow = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.5),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.5)]), count: 3)
                    self.knight_selected = i
                    self.knight_selected?.node.runAction(SCNAction.repeatForever(vibrate_action_slow))
                    self.highLightSquares(squares: self.possiblesFor[i]!, color: UIColor.blue, duration: 1.0)
                    return
                }
            }
            let position = self.board?.getSquarePosition(node: (touched.first?.node)!)
            if(position == nil)
            {
                return
            }
            if (self.knight_selected != nil)
            {
                if (self.squareArrayContains(array: self.possiblesFor[self.knight_selected!]!, element: position!))
                {
                    self.movePiece(piece: self.knight_selected!, position: position!)
                    self.knight_selected = nil
                    self.finalizeTurn()
                    return
                }
                for i in (self.board?.pieces_on_board.keys)!
                {
                    if (self.squareArrayContains(array: self.impossibleSquares[i]!, element: position!) && i.team != self.knight_selected?.team) ///
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
