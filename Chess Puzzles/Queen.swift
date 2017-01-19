//
//  Queen.swift
//  BrainGames3D
//
//  Created by eicke on 12/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit

class Queen:  Piece
{
    
    override init(piece:Piece)
    {
        super.init(piece: piece)
    }
    
    override func possiblesMovements(board:Board, position:(x:Int,y:Int)) -> [(x:Int,y:Int)]
    {
        var possibles:[(x:Int,y:Int)] = []
        for i in 0...board.board.count - 1
        {
            for j in 0...board.board[i].count - 1
            {
                
                if(( abs(position.x - i) == abs(position.y - j)) || position.x - i == 0 || position.y - j == 0)     //Diagonales y axiales
                {
                    possibles.append((x:i, y:j))
                }
            }
        }
        return possibles
    }
    
}
