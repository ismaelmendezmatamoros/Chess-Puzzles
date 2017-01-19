//
//  GameButton.swift
//  BrainGame
//
//  Created by eicke on 9/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import Foundation
import SpriteKit

    ///Extension de SKSPriteNode lleva un handler para indicar que lanzar al ser pulsado
class GameButton: SKSpriteNode
{    
    var handler_function:Selector = ""                              //Selector para activar la funcion. no se usa
    var handler_object:NSObject = NSObject()
}


