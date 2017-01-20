
import Foundation
import SceneKit


/*
 * Clase del juego de los alfiles. El objetivo del juego es llevar a todos los alfiles de un color al extremo opuesto sin que se coman entre ellos
 * Esta clase esta fuertemente basada en la clase nQueens game
 */

class BishopsGame: BoardGameViewController
{
    var impossibleSquares:[Piece:[(x:Int, y:Int)]] = [:]                                    //CAsillas al alcance de cada pieza, indexadas por pieza. Conserva el mismo nombre nQueensGame aunque aqui ese nombre bo tiene sentido
    var imposibleSquaresArray:[(x:Int, y:Int)] = []                                         //Conjuento de casillas imposibles
    let piece_name = "Bishop"
    let team_names = ["white", "red"]                                                       //Nombre de cada equipo. Se colocan como prefijo en el nombre cada pieza
    var initial_positions:[String:[(x:Int, y:Int)]] = [:]                                   //Posiciones iniciales de cada equipo. Son las posicionales del contrario
    
    let team_colors = [UIColor.white, UIColor.red]
    var lightNode:SCNNode = SCNNode()
    var numBishops = 0
    var board_x = 5                                                                         //Ancho del tablero. El alto es el numero de alfiles
    var bishop_selected:Piece? = nil                                                        //pieza seleccionada con el dedo
    var possiblesFor:[Piece:[(x:Int, y:Int)]] = [:]                                         //CAsillas al alcance de cada pieza una vez aplicadas todas las reestricciones
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     * Dimensiones del tablero y numero de alfiles por equipo
     */
    override func setupGame() {
        self.numBishops = 4
        self.board_x = 5
        super.setupGame()
    }
    
    /*
     *Igual que en nQueens game. COn algunos cambios
     */
    override func setupScene()
    {
        self.scene.background.contents = UIColor.black
        
        let map = Array.init(repeating: Array.init(repeating: 1, count: self.board_x), count: self.numBishops)
        self.pieces = self.generateTeamsPieces(modelsfilename: "Piecescollada-3.dae", teams: self.team_names, piecenames: [self.piece_name], color: self.team_colors)           //Genera dos equipos con alfiles de distinto color
        let size = (self.pieces.values.first?.node.boundingBox.max.x)! - (self.pieces.values.first?.node.boundingBox.min.x)!
        self.board = Board.init(map: map, squaresize: Float(size), squareheight: size * 0.2 , color1: UIColor.darkGray, color2: UIColor.black, piece_height: (self.pieces.values.first?.node.boundingBox.max.y)!)

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
        for n in 0...self.team_names.count - 1 {
            self.initial_positions[self.team_names[n]] = []
            for i in 0...self.numBishops - 1 {                                                                  //Se colocan las piezas de cada equipo
                let bishop = Bishop(piece: self.pieces[team_names[n] + "-" + self.piece_name]! )
                bishop.setName(name: bishop.node.name! + String(i))
                bishop.team = n
                bishop.node.eulerAngles.y = Float(0.5 * 3.14 * [1.0, -1.0][n])                                  //rota cada pieza  90 o 270 grados para que los dos equipos aparezcan enfrentados
                let position = (x: i , y: n * (self.board_x - 1))
                bishop.node.runAction(SCNAction.fadeOut(duration: 0))
                self.placePiece(piece: bishop, position: position)
                self.initial_positions[team_names[n]]?.append(position)
                self.initial_positions[self.team_names[n]]?.append(position)
                self.board?.setSingleCharacterOnSquare(position: position, text: "x", text_color: self.team_colors.reversed()[n])      //crea las marcas en las casillas iniciales
            }
        }
        Piece.default_y_position = (self.board?.pieces_on_board.keys.first?.node.position.y)!                                           //pega la pieza al tablero
        self.showOverlays()
        super.setupScene()
    }
    
    /*
     *Comprueba que las posiciones de cada pieza estan en las casillas iniciales del equipo contrario
     */
     override func victoryConditionCheck() -> Bool {
        var name = self.team_names.first
        let lambda = {
            (a:Piece) -> Bool in
            return self.team_names[a.team] == name
        }
        let team1 = self.board?.pieces_on_board.keys.filter(lambda).reversed()
        name = self.team_names[1]
        let team2 = self.board?.pieces_on_board.keys.filter(lambda).reversed()                              //Separa las piezas de cada equipo
     
        //////team1
            let cond2 = team1?.filter({ (a:Piece) -> Bool in
                return  self.squareArrayContains(array: self.initial_positions[self.team_names[1]]!, element: (self.board?.pieces_on_board[a])!) == false   //comprueba que todas las piezas de un equipo estan en alguna de las posiciones iniciales del otro
            }).isEmpty
        ///////team2
        let cond1 = team2?.filter({ (a:Piece) -> Bool in
                return  self.squareArrayContains(array: self.initial_positions[self.team_names[0]]!, element: (self.board?.pieces_on_board[a])!) == false
        }).isEmpty
     
     return cond1! && cond2!        //Si ambos equipos cumplen las condiciones victoria
     }
    
    /*
     *Actualiza el contador de turno y coloca las casillas accesibles de cada pieza con las nuevas posciones
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
     * Calcula las casillas posibles para una pieza y las devuelve en un array
     */
    func getPossiblesFor(piece:Piece) -> [(x:Int, y:Int)]
    {
        let rivals = self.board?.pieces_on_board.keys.filter({ (a:Piece) -> Bool in
            return a.team != piece.team
        })                                                                                          //Extrae las piezas del equipo contrario
        var rivals_possibles:[(x:Int, y:Int)] = []
        var final_possible:[(x:Int, y:Int)] = []
        for i in rivals!
        {
            for n in self.impossibleSquares[i]!
            {
                rivals_possibles.append(n)                                                          //Mete todas las casillas accesibles al equipo contrario en un array
            }
        }
        
        final_possible = impossibleSquares[piece]!.filter({ (a:(x: Int, y: Int)) -> Bool in
            return (self.squareArrayContains(array: rivals_possibles, element:a) == false && self.squareArrayContains(array: (self.board?.pieces_on_board.values.reversed())!, element: a) == false)
        })                                                                                         //comprueba si cada una de las casillas accesibles de la pieza estan ocupadas o son accesibles para el rivañ
        return final_possible
    }
    
    /*
     * Acode a la nueva situacion del tablero calcula qu casillas son habitables para cada pieza
     */
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
     * Mueve la pieza de una casilla a otra
     */
    func movePiece(piece:Piece, position:(x:Int, y:Int))
    {
        var square_position = self.board?.board[(position.x)][(position.y)]?.node?.position     // actualiza la posicion
        piece.node.removeAllActions()                                                           //hace que la pieza deje de moverse
        piece.node.position.y = Piece.default_y_position                                        //Una pieza elegida esta subiendo y bajando. aqui se pega de nuevo al tablero
        square_position?.y = (piece.node.position.y)
        let control = semaphore_t.init(0)
        self.board?.pieces_on_board[piece] = position
        piece.node.runAction((SCNAction.move(to: square_position!, duration: 1.0)), completionHandler: {
            semaphore_signal(control)
        })                                                                                      //realiza la animacion y espera a que termine
        semaphore_wait(control)
        
    }
    /*
     * Funcion que recibe los toques desde la subclase y los procesa
     */
    override func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        let movement = CGFloat(self.board!.size) * CGFloat(0.1)
        let touched = self.getTouchedElements(gestureRecognize)
        if touched.count > 0
        {
            for i in (self.board?.pieces_on_board.keys)!                                        //se ha tocado una pieza
            {
                if (i.node.name == touched.first?.node.name || (i.node.childNode(withName:(touched.first?.node.name)!, recursively: true)) != nil) //Compueva si el nodo o algun subnodo es el nodo tocado
                {
                    if(self.bishop_selected != nil)                                             //Si ya habia una piieza seleccionada se deja quieta
                    {
                        self.bishop_selected?.node.removeAllActions()
                        self.bishop_selected?.node.position.y = Piece.default_y_position        //pegada al tablero
                    }
                    let vibrate_action_slow = SCNAction.repeat(SCNAction.sequence([SCNAction.moveBy(x: 0, y: movement, z: 0, duration: 0.5),SCNAction.moveBy(x: 0, y: -movement, z: 0, duration: 0.5)]), count: 3)                                                      //Movimiento de subisr y bajar de la pieza seleccionada
                    self.bishop_selected = i
                    self.bishop_selected?.node.runAction(SCNAction.repeatForever(vibrate_action_slow))
                    self.highLightSquares(squares: self.possiblesFor[i]!, color: UIColor.blue, duration: 1.0)
                    return
                }
            }
            let position = self.board?.getSquarePosition(node: (touched.first?.node)!)         //Si ha tocado una casilla coge su posicion
            if(position == nil)
            {
                return
            }
            if (self.bishop_selected != nil)
            {
                if (self.squareArrayContains(array: self.possiblesFor[self.bishop_selected!]!, element: position!)) //si la casilla es apta para el alfil seleccionado la mueve y termina
                {
                    self.movePiece(piece: self.bishop_selected!, position: position!)
                    self.bishop_selected = nil
                    self.finalizeTurn()
                    return
                }
                for i in (self.board?.pieces_on_board.keys)!                    //Si no es apta hace vibrar los alfiles contrarios que la pueden atacar
                {
                    if (self.squareArrayContains(array: self.impossibleSquares[i]!, element: position!) && i.team != self.bishop_selected?.team) ///
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
