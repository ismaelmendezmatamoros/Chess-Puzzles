//
//  Piece.swift
//  BrainGames3D
//
//  Created by eicke on 12/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit

class Piece: NSObject
{
    var node: SCNNode = SCNNode()
    var team:Int = 0
    static var default_y_position:Float = 0.0
    
    
    override init()
    {
        self.node.castsShadow = false
        let lambda =
            { (a:SCNNode, b:UnsafeMutablePointer<ObjCBool>) in
                a.castsShadow = false
                a.geometry?.firstMaterial?.isLitPerPixel = true
                a.geometry?.firstMaterial?.specular.contents = UIColor.black
        }
        
        self.node.enumerateChildNodes(lambda)
    }
    
    func setName(name:String)
    {
        let lambda =
            { (a:SCNNode, b:UnsafeMutablePointer<ObjCBool>) in
                a.name = a.name! + "-" + name
        }
        self.node.enumerateChildNodes(lambda)
        self.node.name = name
    }
    
    
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
    
    func possiblesMovements(board:Board, position:(x:Int,y:Int)) -> [(x:Int,y:Int)]
    {
        return []
    }

}
