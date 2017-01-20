
//
//  nQueensGame.swift
//  BrainGames3D
//
//  Created by eicke on 12/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit

/*
 * Clase del juego de las 8 reinas. El objetivo es colocar 8 reinas en el tablero sin que se coman las unas a las otras
 * Esta clase fue la primera en ser implementada y mucho codigo las otras parte de este con ligeras modificaciones
 */
class nQueensGame: BoardGameViewController
{
    var impossibleSquares:[Piece:[(x:Int, y:Int)]] = [:]                //Representa las casillas a las que una pieza puede llegar. En el caso de las 8 reinas son casillas inhabitables
    var imposibleSquaresArray:[(x:Int, y:Int)] = []                     //Array con todas las casillas imposibles
    var numQueens = 0                                                   //Numero de reinas. Define tambien las dimensiones del tablero
    let piece_name = "Queen"                                            //Nombre y modelo de pieza que se va a usar
    var lightNode:SCNNode = SCNNode()                                   //Luz que ilumina el tablero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.numplayers = 1
    }

    /*
     * Por si mas adelante se quiere configurar el numero de reinas desde el menu...
     */
    override func setupGame()
    {
        self.numQueens = self.parameters["numQueens"] as! Int
    }

    /*
     * Inicializa la escena.
     */
    override func setupScene()
    {
        self.scene.background.contents = UIColor.black
        let map = Array.init(repeating: Array.init(repeating: 1, count: self.numQueens), count: self.numQueens)
        self.pieces = self.loadModelsFromFile(filename: "Piecescollada-3.dae", names: [piece_name], color:UIColor.red)              //Extrae el modelo queen del fichero 3D
        let size = (self.pieces[piece_name]?.node.boundingBox.max.x)! - (self.pieces[piece_name]?.node.boundingBox.min.x)!
        self.board = Board.init(map: map, squaresize: Float(size), squareheight: size * 0.2 , color1: UIColor.gray, color2: UIColor.black, piece_height: (pieces[piece_name]?.node.boundingBox.max.y)!)
        self.pieces[piece_name] = Queen(piece: pieces[piece_name]!)
        lightNode.light = SCNLight()
        
        lightNode.light?.type = .omni                                                   //inicia y coloca la luz que ilumna el tablero de frente
        lightNode.light?.spotInnerAngle = 75;
        lightNode.light?.spotOuterAngle = 75;
        lightNode.light?.shadowRadius = 100.0;
        lightNode.light?.intensity = 1500
        lightNode.light?.zFar = 10000;
        lightNode.light?.castsShadow = true
        lightNode.position.x = (self.board?.boundingBox.max.x)! / 2
        lightNode.position.z = (self.board?.boundingBox.max.z)! * 1                     //Ajusta la altura y posicion de la luz dependiendo de las dimensiones del tablero
        lightNode.position.y = size * 2.5
        self.scene.rootNode.castsShadow = true
        let constraint = SCNLookAtConstraint(target: self.board)
        lightNode.constraints = [constraint]                                            //Mirando al tablero

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        self.scene.rootNode.addChildNode(board!)
        self.board?.addChildNode(lightNode)
        self.board?.position.y = (pieces[piece_name]?.node.boundingBox.min.y)! - (board?.boundingBox.max.y)!
        self.showOverlays()                                                             //Coloca el boton de salir y el contador de turnos
        super.setupScene()
    }    
    
    /*
     *Coloca una pieza en el tablero por primera vez
     */
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        self.board?.placePiece(piece: piece, position: position)
        let possibles = piece.possiblesMovements(board: board!, position: position)
        self.impossibleSquares[piece] = possibles
    }

    /*
     *Al final de cada turno se recalculan que casillas son inhabitables
     */
    override func turnsEnd(player: Int) {
        
        self.impossibleSquares.removeAll()
        for i in (self.board?.pieces_on_board.keys)!
        {
        self.impossibleSquares[i] = i.possiblesMovements(board: self.board!, position: (self.board?.pieces_on_board[i])!)   //por cada pieza se añades las casillas a su alcance
        }
        self.moves.text = "moves: \(self.turns)"                                                                            //actualiza el contador de turnos en pantalla
        super.turnsEnd(player: player)
    }
    
    /*
     *Coloca todas las casillas inhabitables en un unico array
     */
    func loadImposibleSquaresArray()
    {
        var squares:[(x:Int, y:Int)] = []
        let other_pieces = self.board?.pieces_on_board.values.reversed()                                                     //Reversed para que devuelva un array, el orden da igual
        for i in self.impossibleSquares.values
        {
            for pos in i {
                if  (self.squareArrayContains(array: squares, element: pos) == false && self.squareArrayContains(array: other_pieces!, element: pos) == false) //evita repetidos y casillas con pieza
                {
                    squares.append(pos)
                }
            }
        }
        self.imposibleSquaresArray = squares
    }

    /*
     *Al principio de cada turno se juntan todas las inhabitables en un mismo array y se ilumninan
     */
    override func beforeTurnStarts(player: Int) -> Bool
    {
        self.loadImposibleSquaresArray()
        self.highLightSquares(squares: self.imposibleSquaresArray, color: UIColor.blue, duration: 1.0)
        return super.beforeTurnStarts(player: player)
        
    }
 
    /*
     * reimplementa ala de la superclase.
     */
    override func victoryConditionCheck() -> Bool {
        if (self.board?.pieces_on_board.count == self.numQueens)
        {
            _ = super.victoryConditionCheck()
            return true
        }
        return false
    }
    
    /*
     * Quita una pieza del tablero con un fdadeout
     */
    func removePiece(piece:Piece)
    {
        let step2 = {
            piece.node.removeFromParentNode()
        }
        _ = self.board?.pieces_on_board.removeValue(forKey: piece)
        _ = self.impossibleSquares.removeValue(forKey: piece)
        self.loadImposibleSquaresArray()
        piece.node.runAction(SCNAction.fadeOut(duration: 1), completionHandler: step2)                              //UIna vez desaparecida la quita del arbol
    }
    
    /*
     * Funcion que recibe los toques de pantalla desde la superclase y los procesa
     */
    override func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        let touched = self.getTouchedElements(gestureRecognize)
        if touched.count > 0
        {
            for i in (self.board?.pieces_on_board.keys)!                                                            //Comprueba si hemos tocado una de las piezas
            {
                if (i.node.name == touched.first?.node.name || (i.node.childNode(withName:(touched.first?.node.name)!, recursively: true)) != nil) ///
                {
                    self.removePiece(piece: i)                                                                      //Si hemos tocado una pieza la quita
                    return
                }
            }
            let position = self.board?.getSquarePosition(node: (touched.first?.node)!)                              //Comprueba si hemos tocado una casilla
            if(position == nil)                                                                                     //Si no hemos tocado nodo sale
            {
                return
            }
            if (self.squareArrayContains(array: self.imposibleSquaresArray, element: position!))                    //Si hemos tocado una casilla inhabitable
            {
                let movement = CGFloat(self.board!.size) * CGFloat(0.1)
                let vibrate_action = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.1),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.1)]), count: 3)                                                                                               //Animacion de vibracion
                for i in (self.board?.pieces_on_board.keys)!
                {
                    if (self.squareArrayContains(array: self.impossibleSquares[i]!, element: position!))            //Todas las piezas que puedan atacar la casilla inhabitable vibran
                    {
                        i.node.runAction(vibrate_action)
                    }
                }
                self.highLightSquares(squares: self.imposibleSquaresArray, color: UIColor.blue, duration: 1.0)      //Ilumnia todas las casilla inhabitables como recordatorio
                return
            }
            let queen = Queen.init(piece: pieces[piece_name]!)                                                      //La casilla es valida: crea una reina nueva, la coloca y termina turno
            queen.setName(name: piece_name + String(self.turns))
            self.placePiece(piece: queen, position: position!)
            self.finalizeTurn()
        }
    }
    

}
