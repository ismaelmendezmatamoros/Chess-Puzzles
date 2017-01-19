//
//  Board.swift
//  BrainGames3D
//
//  Created by eicke on 12/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

/*
 *Clase tablero almacena los nodos de las casillas y ademas guarda en diccionarios el estado actual del tablero
 */
class Board: SCNNode
{
    
    struct Square  {                                    //cada casilla esta representada con un struct de este tipo en una matriz del tamaño del tablero
        var node:SCNNode? = nil                         //nodo de la casilla en si
        var mark_node:SCNNode? = nil                    //Nodo de las marcas en las casillas
        var type:Int = 0                                //Puede que en futuro haya q distinguir entre tipos de casillas. 0 No hay casilla
    }
    var pieces_node = SCNNode()                         //Contiene las distintas piezas que hay en la partida
    var board:[[Square?]] = []                          //matriz de Square
    var pieces_on_board:[Piece:(x:Int, y:Int)] = [:]    //Diccionario con las piezas que hay en el tablero y su posicion
    var board_node = SCNNode()                          //nodo donde van todas las casillas del tablero
    var size:Float = 0                                  //Tamaño del lado de una casilla se calcula en proporcion al modelo de la pieza
    
    
    /*
     *Inicia un tablero
     */
    init(map:[[Int]], squaresize:Float, squareheight:Float, color1:UIColor, color2:UIColor, piece_height:Float)
    {
        super.init()
        self.size = squaresize
        self.castsShadow = true
        for i in 0...map.count - 1
        {
            board.append([])
            for j in 0...map[i].count - 1                                                       //Crea la matriz de casillas (arraty de arrays)
            {
                if(map[i][j] == 0)
                {
                    continue
                }
                var square = Square()
                let nodegeom = SCNNode(geometry: SCNBox(width: CGFloat(squaresize), height: CGFloat(squareheight), length: CGFloat(squaresize), chamferRadius: 0.0))
                
                square.node = SCNNode()
                square.node?.castsShadow = false
                square.node?.geometry?.firstMaterial?.isLitPerPixel = true
                square.node?.geometry?.firstMaterial?.specular.contents = UIColor.red
                square.node?.position.y = 0.0
                square.node?.position.x = Float(j) * squaresize                                                     //la posicion en funcion de su posicion en ele tablero y el tamaño de la casilla
                square.node?.position.z = Float(i) * squaresize
                square.node?.name = "(" + String(i) + "," + String(j) + ")"                                         //Con el bnombre se identifican despues al tocarse
                nodegeom.name = "(" + String(i) + "," + String(j) + ")"
                print(nodegeom.name! + String(((i + j) % 2 == 0)))
                nodegeom.geometry?.firstMaterial?.diffuse.contents = ( ((i + j) % 2 == 0) ? color1 : color2)
                square.node?.addChildNode(nodegeom)                                                                 //CAda nodo lleva su cuadrado independiente de la geometria del resto
                board[i].append(square)
                self.board_node.addChildNode(square.node!)
            }
        }
        self.board_node.addChildNode(pieces_node)                                                                   //Todo el tablero esta contenido en un mismo nodo
        self.addChildNode(self.board_node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     *Pilla el nomnre de una casilla y devuelve su posicion
     */
    func getSquarePosition(node:SCNNode) -> (x:Int,y:Int)?
    {//cambiar esto
        for i in 0...self.board.count - 1
        {
            for j in 0...self.board[i].count - 1
            {
                if((self.board[i][j]?.node?.name)! == node.name!)
                {
                    return (x:i, y:j)
                }
            }
        }
        return nil
    }
    
    /*
     *Aplica a la pieza una animacion la primera vez que la pieza se pone en el tablero
     */
    func dropPiecesAnimation(piece:Piece, duration:Int)
    {
        piece.node.scale.x = 0.0
        piece.node.scale.y = 0.0
        piece.node.scale.z = 0.0
        piece.node.runAction(SCNAction.rotateBy(x: 0.0, y: 3.1416 * 2.0 * 2.0, z: 0.0, duration: TimeInterval(duration)))
        piece.node.runAction(SCNAction.scale(to: 1.0, duration: TimeInterval(duration)))                                        //Rotar y escalar
    }
    
    /*
     *Coloca una marca en la casilla. Coloca un n umero de dos cifraz para que todos luzcan igual
     */
    func setNumberOnSquare(position:(x:Int, y:Int), num:Int, text_color:UIColor)
    {
        let movement = size * 0.05
        let num_string = (num < 10 ? "0" : "") + String(num)                                    //Si es menor de 10 le coloca un 0 delante
        let tex = SCNText.init(string: num_string, extrusionDepth: 2.0)
        tex.firstMaterial?.diffuse.contents = text_color
        let text_node = SCNNode(geometry: tex)
        let action = [SCNAction.moveBy(x: 0, y: CGFloat(movement), z: 0, duration: 0.5),SCNAction.moveBy(x: 0, y: -(CGFloat)(movement), z: 0, duration: 0.5)]
        text_node.runAction(SCNAction.repeatForever(SCNAction.sequence(action)))                                    //Accion de subir y bajar ligeramnte
        text_node.name = self.board[position.x][position.y]?.node?.name
        let tx = text_node.boundingBox.max.x - text_node.boundingBox.min.x
        let tz = text_node.boundingBox.max.y - text_node.boundingBox.min.y                                          //desplaza la marca a su centro (cambia de centro)
        text_node.eulerAngles.x = Float(1.5 * 3.14)                                                                 //En el fichero las figuras van tumbadas. LAs rota 270 grados
        text_node.position.y = size * 0.1
        text_node.position.z = +(self.size  * 0.25) + tz
        text_node.position.x = -(self.size  * 0.25) - tx                                                            //La coloca en el centro de la casilla
        let scale =  0.5 * ((self.board[position.x][position.y]?.node?.boundingBox.max.x)! - (self.board[position.x][position.y]?.node?.boundingBox.min.x)!) /  (text_node.boundingBox.max.x - text_node.boundingBox.min.x)                                                                             //La escala para qu entre en la casilla
        text_node.scale = SCNVector3.init(x: scale, y: scale, z: scale)
        self.board[position.x][position.y]?.node?.addChildNode(text_node)
        self.board[position.x][position.y]?.mark_node = text_node
    }
    
    /*
     * Elimina un marca de una casilla
     */
    func removeMarkFromSquare(position:(x:Int, y:Int))
    {
        self.board[position.x][position.y]?.mark_node?.removeFromParentNode()
    }
    
    /*
     *Coloca una marca pero esta vez un caracter. Es mas sencilla xq no hay que controlar que tenga 2 cifras
     */
    func setSingleCharacterOnSquare(position:(x:Int, y:Int), text:String, text_color:UIColor)
    {
        let movement = size * 0.05
        let tex = SCNText.init(string: text, extrusionDepth: 2.0)
        tex.firstMaterial?.diffuse.contents = text_color
        let text_node = SCNNode(geometry: tex)
        let action = [SCNAction.moveBy(x: 0, y: CGFloat(movement), z: 0, duration: 0.5),SCNAction.moveBy(x: 0, y: -(CGFloat)(movement), z: 0, duration: 0.5)]
        text_node.runAction(SCNAction.repeatForever(SCNAction.sequence(action)))
        text_node.name = self.board[position.x][position.y]?.node?.name
        let tx = text_node.boundingBox.max.x - text_node.boundingBox.min.x
        let tz = text_node.boundingBox.max.y - text_node.boundingBox.min.y
        text_node.eulerAngles.x = Float(1.5 * 3.14)
        text_node.position.y = size * 0.1
        text_node.position.z =  tz + (self.size  * 0.5)
        text_node.position.x = -tx  - (self.size  * 0.25)
        let scale =  0.5 * ((self.board[position.x][position.y]?.node?.boundingBox.max.x)! - (self.board[position.x][position.y]?.node?.boundingBox.min.x)!) /  (text_node.boundingBox.max.x - text_node.boundingBox.min.x)
        text_node.scale = SCNVector3.init(x: scale, y: scale, z: scale)
        self.board[position.x][position.y]?.node?.addChildNode(text_node)
        self.board[position.x][position.y]?.mark_node = text_node
    }
    
    /*
     *Coloca una nueva pieza en el teckado
     */
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        let np = piece//Piece.init(piece: piece)
        self.pieces_on_board[np] = position
        np.node.position.y += abs(np.node.boundingBox.min.z)                                                    //Pega la pieza al tablero
        np.node.position.x = (self.board[position.x][position.y]?.node?.position.x)!
        np.node.position.z = (self.board[position.x][position.y]?.node?.position.z)!
        self.pieces_node.addChildNode(np.node)
        self.dropPiecesAnimation(piece: np, duration: 1)                                                        //Animacion de entrada
    }
    
}
