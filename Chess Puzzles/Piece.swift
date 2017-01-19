//
//  Piece.swift
//  BrainGames3D
//
//  Created by eicke on 12/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit

/*
 * Esta clase reperesenta una pieza en el juego
 */
class Piece: NSObject
{
    var node: SCNNode = SCNNode()                           //Nodo que contiene la pieza y su geometria
    var team:Int = 0                                        //Equipo al que pertenece la piece
    static var default_y_position:Float = 0.0               //Variable estatica que guarda la posicion Y para que la pieza este encima del tablero
    
    
    override init()
    {
        self.node.castsShadow = false
        let lambda =
            { (a:SCNNode, b:UnsafeMutablePointer<ObjCBool>) in
                a.castsShadow = false
                a.geometry?.firstMaterial?.isLitPerPixel = true
                a.geometry?.firstMaterial?.specular.contents = UIColor.black
        }
        self.node.enumerateChildNodes(lambda)                               //La geometria de la pieza puede tener varios subniveles en subnodos. Hay que ponerles 
                                                                            //nombre para identificarlos cuando se toquen
    }
    
    /*
     * Esta funcion coloca el nombre de la pieza delante al nombre de todos los nodos
     */
    func setName(name:String)
    {
        let lambda =
            { (a:SCNNode, b:UnsafeMutablePointer<ObjCBool>) in
                a.name = a.name! + "-" + name
        }
        self.node.enumerateChildNodes(lambda)
        self.node.name = name
    }
    
    /*
     * Constructor copia
     */
    init(piece:Piece)
    {
        self.node = piece.node.clone()
        self.team = piece.team
        self.node.castsShadow = false
        let lambda =
            { (a:SCNNode, b:UnsafeMutablePointer<ObjCBool>) in
                a.castsShadow = false
        }
        self.node.enumerateChildNodes(lambda)
        
    }
    
    
    /*
     * Implementada en la subclase devuelve las posiciones hacia las que se puede mover la pieza SIN TENER EN CUENTA SI ESTAN OCUPADAS
     */
    func possiblesMovements(board:Board, position:(x:Int,y:Int)) -> [(x:Int,y:Int)]
    {
        return []
    }

}
