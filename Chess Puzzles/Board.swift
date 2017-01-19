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


class Board: SCNNode
{
    struct Square  {
        var node:SCNNode? = nil
        var mark_node:SCNNode? = nil
        var type:Int = 0                                 //Puede que en futuro haya q distinguir entre tipos de casillas
    }
    var pieces_node = SCNNode()
    var board:[[Square?]] = []
    var pieces_on_board:[Piece:(x:Int, y:Int)] = [:]
    var board_node = SCNNode()
    
    var size:Float = 0
    
    init(map:[[Int]], squaresize:Float, squareheight:Float, color1:UIColor, color2:UIColor, piece_height:Float)
    {
        super.init()
        self.size = squaresize
        self.castsShadow = true
        for i in 0...map.count - 1
        {
            board.append([])
            for j in 0...map[i].count - 1
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
                square.node?.position.x = Float(j) * squaresize
                square.node?.position.z = Float(i) * squaresize
                square.node?.name = "(" + String(i) + "," + String(j) + ")"
                nodegeom.name = "(" + String(i) + "," + String(j) + ")"
                print(nodegeom.name! + String(((i + j) % 2 == 0)))
                nodegeom.geometry?.firstMaterial?.diffuse.contents = ( ((i + j) % 2 == 0) ? color1 : color2)
                square.node?.addChildNode(nodegeom)
                board[i].append(square)
                self.board_node.addChildNode(square.node!)
                //self.s_node.position.y += squaresize
            }            
        }
        //self.board_node.position.y -= abs(self.boundingBox.max.y) + abs(self.boundingBox.min.y) //* 0.01
        //self.pieces_node.position.y += squareheight
   
        self.board_node.addChildNode(pieces_node)
        //self.position = (self.board[map.count/2][map.count/2]?.node?.position)!

        self.addChildNode(self.board_node)
        //self.addChildNode(self.pieces_node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSquarePosition(node:SCNNode) -> (x:Int,y:Int)?
    {
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
    func createBorder() -> SCNNode
    {
        //let limits = self.board_node.boundingBox
        
    
    }*/
    
    func dropPiecesAnimation(piece:Piece, duration:Int)
    {
        piece.node.scale.x = 0.0
        piece.node.scale.y = 0.0
        piece.node.scale.z = 0.0
        piece.node.runAction(SCNAction.rotateBy(x: 0.0, y: 3.1416 * 2.0 * 2.0, z: 0.0, duration: TimeInterval(duration))) //(to: 1.0, duration: TimeInterval(duration)))
        piece.node.runAction(SCNAction.scale(to: 1.0, duration: TimeInterval(duration))) //(by: 360, around: SCNVector3.init(1.0, 0.0, 0.0), duration: TimeInterval(duration)))
        /*
        var float = CGFloat(duration)
        float.multiply(by: CGFloat(0.001))

        piece.node.runAction(SCNAction.fadeIn(duration: TimeInterval(float)))
         let position0 =  piece.node.position
        
        let lambda = { () in
            piece.node.position = position0
        }
        piece.node.position.y = 2000.0
        piece.node.runAction(SCNAction.move(to: position0, duration: TimeInterval(float)), completionHandler: lambda)
        //print(String(piece.node.position.y) + " xxxxx " + String(position.y))
        
        usleep (useconds_t(Int(Float(duration) * 1000 + 600))) //piece.node.position = position0
        */
    }
    
    
    
    
    func setNumberOnSquare(position:(x:Int, y:Int), num:Int, text_color:UIColor)
    {
        let movement = size * 0.05
        let num_string = (num < 10 ? "0" : "") + String(num)
        let tex = SCNText.init(string: num_string, extrusionDepth: 2.0)
        tex.firstMaterial?.diffuse.contents = text_color
        let text_node = SCNNode(geometry: tex)
        let action = [SCNAction.moveBy(x: 0, y: CGFloat(movement), z: 0, duration: 0.5),SCNAction.moveBy(x: 0, y: -(CGFloat)(movement), z: 0, duration: 0.5)]
        text_node.runAction(SCNAction.repeatForever(SCNAction.sequence(action)))
        text_node.name = self.board[position.x][position.y]?.node?.name
        let tx = text_node.boundingBox.max.x - text_node.boundingBox.min.x
        let tz = text_node.boundingBox.max.y - text_node.boundingBox.min.y
        //text_node.eulerAngles.z = Float(3.14)
        
        text_node.eulerAngles.x = Float(1.5 * 3.14)//Float(0.5 * 3.14)        /////////
        //
        ///////
        text_node.position.y = size * 0.1
        text_node.position.z = +(self.size  * 0.25) + tz //* 0.5
        text_node.position.x = -(self.size  * 0.25) - tx

        
        let scale =  0.5 * ((self.board[position.x][position.y]?.node?.boundingBox.max.x)! - (self.board[position.x][position.y]?.node?.boundingBox.min.x)!) /  (text_node.boundingBox.max.x - text_node.boundingBox.min.x)
        text_node.scale = SCNVector3.init(x: scale, y: scale, z: scale)
        self.board[position.x][position.y]?.node?.addChildNode(text_node)
        self.board[position.x][position.y]?.mark_node = text_node
    }
    
    
    func removeMarkFromSquare(position:(x:Int, y:Int))
    {
        self.board[position.x][position.y]?.mark_node?.removeFromParentNode()
    }
    
    
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
        //text_node.eulerAngles.z = Float(3.14) 
        
        text_node.eulerAngles.x = Float(1.5 * 3.14)//Float(0.5 * 3.14)        /////////
        //
        ///////
        text_node.position.y = size * 0.1
        //text_node.position.z = +(self.size  * 0.25) + tz //* 0.5
        //text_node.position.x = -(self.size  * 0.25) - tx
        text_node.position.z =  tz + (self.size  * 0.5) //* 0.5
        text_node.position.x = -tx  - (self.size  * 0.25)// - tx
        
        let scale =  0.5 * ((self.board[position.x][position.y]?.node?.boundingBox.max.x)! - (self.board[position.x][position.y]?.node?.boundingBox.min.x)!) /  (text_node.boundingBox.max.x - text_node.boundingBox.min.x)
        text_node.scale = SCNVector3.init(x: scale, y: scale, z: scale)
        self.board[position.x][position.y]?.node?.addChildNode(text_node)
        self.board[position.x][position.y]?.mark_node = text_node

    }
    
    func placePiece(piece:Piece, position:(x:Int, y:Int))
    {
        let np = piece//Piece.init(piece: piece)
        self.pieces_on_board[np] = position
        np.node.position.y += abs(np.node.boundingBox.min.z)
        np.node.position.x = (self.board[position.x][position.y]?.node?.position.x)!
        np.node.position.z = (self.board[position.x][position.y]?.node?.position.z)!
        
        self.pieces_node.addChildNode(np.node)
        self.dropPiecesAnimation(piece: np, duration: 1)
    }
    
}
