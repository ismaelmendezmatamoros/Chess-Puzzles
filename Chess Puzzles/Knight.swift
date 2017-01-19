//
//  Knight.swift
//  BrainGames3D
//
//  Created by eicke on 17/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SceneKit

class Knight:Piece
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
                
                if(( abs(position.x - i) == 1 && abs(position.y - j) == 2) || ( abs(position.x - i) == 2 && abs(position.y - j) == 1)) //pasa la casilla al sistema de coordenadas del callo y aplica la condicion
                {
                    possibles.append((x:i, y:j))
                }
            }
        }
        return possibles
    }

}
