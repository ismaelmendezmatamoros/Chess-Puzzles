//
//  GameScene.swift
//  BrainGame
//
//  Created by eicke on 9/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import SpriteKit
import GameplayKit
import SceneKit


//Clase del menu inicial

class GameScene: SKScene {  
    

    //Estado en que se encuentra la pantalla
    private enum status {case START_SCREEN,                                                     //Estado inicial. Esperando que se toque la pantalla para mostrar el menu
                                GAME_SELECT_SCREEN,                                             //Pantalla de eleccion de juego.Aqui se elige que juego jugar
                                GAME_SELECTED_SCREEN                                           //Una vez elegido el juego se mustra una descripcion y pide confirmacion
                                //GAME_SCREEN
                        }
    
    var viewController:GameViewController?
    private var gameStatus = status.START_SCREEN                                                //estado actual del menu
    private var title : SKLabelNode?                                                            //Label del titulo del juego
    private var start : SKLabelNode?                                                            //Label de "touch to start" de la pantalla inicial
    
    private var center = CGPoint()                                                              //Centro de la pantalla
    private var relative_width_Max:Float = 0.0                                                  //Tamaño relativo del ancho respecto al alto
    private var relative_height_Max:Float = 0.0
    private var controls:[GameButton] = []                                                      //Nodos de los botones de seleccion de juego
    private var bgImage:SKSpriteNode = SKSpriteNode()                                           //imagen de fondo
    private var brainGuy:SKSpriteNode = SKSpriteNode()                                          //Sprite del muñeco del menu
    private let bgImageName:String = "bg.png"
    private let brainGuyName:String = "brainguy.png"
    private var veil:SKSpriteNode = SKSpriteNode()                                              //Velo que se utiliza para ocurecer toda la pantalla

    private var game_selection_node = SKSpriteNode()                                            // Nodo para mostrar las descripciones de los juegos
    private var game_selection_ok_node = GameButton(imageNamed: "ok.png")
    private var game_selection_cancel_node = GameButton(imageNamed: "cancel.png")               //boton ok de la confirmacion de juego
    private var game_description:[String:String] = [:]
    private var game_description_labelnode:[String:SKLabelNode] = [:]                           //Diccionario con los labels de las descripciones segun nombre del juego

    let image_names = ["reinas.gif", "bishop.png", "knight.png", "knights36.png"]               //imagenes de los botones de seleccion
    let handler_functions = [#selector(GameScene.nQueensGame(button:)),                         //Selectores de las funciones que activa cada boton. Ya no tiene sentido pero se mantiene para mantener la integridad
                             #selector(GameScene.bishopsGame(button:)),
                             #selector(GameScene.KnightsGame(button:)),
                             #selector(GameScene.Knights36(button:))]
    
    var game_selected:String = ""                                                               //Nombre del juego elegido en GAME_SELECT_SCREEN
    
    
    
    
    /*
    Crea todo lo necesario para mostrar la pantalla de descripcion y confirmacion de un juego
    */
    func createGameSelectionMenu()
    {
        let QueensGameDescription =  "Place eight queens on the board without threaten between them."
        let BishopsGameDescription = "Place all the bishops on the squares with it's color mark."
        let KnightsGameDescription = "Place the all the knights on the squares with it's color mark."
        let Knights36GameDescription = "Go throug all the squares using the knight without stepping any twice."
        self.game_description["nQueens"] = QueensGameDescription
        self.game_description["Bishops"] = BishopsGameDescription
        self.game_description["Knights"] = KnightsGameDescription
        self.game_description["Knights36"] = Knights36GameDescription                                           //Descripciones segun el nombre

        for i in self.game_description.keys                                                                     //Posr cada entrada crea un label con la descripcion
        {
            let label = SKLabelNode(text: self.game_description[i])
            label.color = UIColor.black
            label.fontColor = UIColor.white
            label.fontSize = 18
            self.game_description_labelnode[i] = label
            label.isHidden = false
            label.name = i
            label.alpha = 0                                                                                     //Inicialmente iinvisible
            self.addChild(label)
        }
        self.game_selection_ok_node.name =  "ok"
        self.game_selection_cancel_node.name = "cancel"
        
        let scale_x = self.size.width / self.game_selection_ok_node.size.width                                  //Ajusta la esca dependiendo del tamaño de la pantall

        self.game_selection_cancel_node.setScale(scale_x * 0.05)
        self.game_selection_ok_node.setScale(scale_x * 0.05)
        self.game_selection_ok_node.position.x =  -self.size.width * 0.1                                        // OK y CANCEL se deplazan las mismas distancias en x pero en direcciones contrtias
        self.game_selection_cancel_node.position.x = -self.game_selection_ok_node.position.x
        for i in self.game_description.keys
        {
            self.game_selection_node.childNode(withName: i)?.alpha = 0.0                                        //Inicialmente transparente. Solo se ven euna vez elegido juego
        }
        self.game_selection_node.position.y = -self.size.height * 0.1                                           //Ajusta la altura de los botones ok y cancel de forma relativa al tamaño
        self.game_selection_cancel_node.position.y = -self.size.height * 0.2
        self.game_selection_ok_node.position.y = self.game_selection_cancel_node.position.y
        
        self.addChild(self.game_selection_ok_node)
        self.addChild(self.game_selection_cancel_node)
        self.veil.addChild(self.game_selection_node)
        self.game_selection_ok_node.alpha = 0.0
        self.game_selection_cancel_node.alpha = self.game_selection_ok_node.alpha

    }
    
    override func didMove(to view: SKView)
    {
        
        self.size = CGSize(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)                       //Realiza las inicializaciones iniciales
        self.relative_height_Max = 1.0
        self.relative_width_Max = Float(self.size.width) / Float(self.size.height)
        self.backgroundColor = SKColor(red: 107/255.0, green: 88/255.0, blue: 193/255.0, alpha: 1.0)
        self.center = CGPoint(x: self.size.width / 2, y: self.size.height / 2 )
        self.anchorPoint = CGPoint(x: 0.5 , y: 0.5 )
        self.showSplashScreen()                                                                                         //Crea el menu de confirmacion para luego
        self.createGameSelectionMenu()                                                                                  //muestra la pantalla inicial
    }
    
    /*
     *Crea un accion de balanceo. Esta accio es una serie de pequeños desplazamientos en direcciones aleatoria y vuelta al estad inicial
     */
    func createSwingingActions(node:SKNode, num_vectors:Int, max_vector_lenght:Double) -> [SKAction]
    {
        var moves:[SKAction] = []
        var inverses = moves
        for _ in 0...num_vectors                                                                                         //Genera vectores aleatorios con modulos en el rango +-max para que apunten a todas direcciones
        {
            let point_x = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght)))
            let point_y = CGFloat(self.randomFloat(min: -(Float)(max_vector_lenght), max: Float(max_vector_lenght)))
            let point = CGVector(dx: point_x, dy: point_y)
            moves.append(SKAction.move(by: point, duration: 1.0))
            let inverse = CGVector(dx: -point_x, dy: -point_y)                                                          //tambien añade el vector opuesto para hacer el camino de vuelta
            inverses.append(SKAction.move(by: inverse, duration: 1.0))
        }
        moves.append(contentsOf: inverses.reversed())                                                                   // los inversos van en orden contrario para deshacer los caminos P.Ej[1234][ -4 -3 -2 -1 ]
        return moves
    }
    
    
    func randomFloat(min:Float, max:Float) -> Float
    {
        return Float(arc4random()) / Float(UINT32_MAX) * abs(min - max) + (min < max ? min : max)
    }
    
    /*
     *Es funcion trabsiciona entre la pantalla inicial y la de seleccion de juego
     *Requieren que las animaciones terminen antes de empezar otras
     *S realiza en varios pasos enlazando con la funcion completion de runaction
     *Este codigo se ejecuta de abajo a arriba empezando por la ultima lnea
     */
    func showSelectGameScreen()
    {
        var start_seq = [SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]
        start_seq = [SKAction.repeat(SKAction.sequence(start_seq), count: 7)]
        start_seq.append(SKAction.move(to: absolutePosition(relative: CGPoint(x: 0, y:-2)), duration: 0.5))
        
        let step4 = {                                                               //el Label select game parapadea. Ultimo paso
            self.start?.removeFromParent()
            self.start?.position = self.absolutePosition(relative: CGPoint(x:0, y: -0.4))
            let transitions = [SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5)]
            self.start?.text = "Select a game"
            self.start?.run(SKAction.repeatForever(SKAction.sequence(transitions)))
            self.bgImage.addChild(self.start!)
        }
        
        let step3 =
            {
                
                let num_vectors = 8
                var moves:[SKAction] = []
                let max_vector_lenght = 5.0
                self.controls = self.createButtons(images_paths: self.image_names, handler_functions: self.handler_functions, handler: self)            //Crea los botones con sus imagenes
                self.controls = self.setButtonsRowPosition(buttons: self.controls, area_: CGSize(width: 0.25, height: 0.25), surface: CGRect(x: 0.15, y: 0.4, width: 1.0, height: 0.4))     //Calcula la posicion y escala de los botones para que vayan uniformemente desntro del rectangulo pasado
                let common_node = SKNode()                      //nodo comun de los botones
                for i in self.controls
                {
                    moves = self.createSwingingActions(node: i, num_vectors: num_vectors, max_vector_lenght: max_vector_lenght)
                    i.run(SKAction.repeatForever(SKAction.sequence(moves)))             //cada boton le asigna un balanceo diferente
                    common_node.addChild(i)
                    moves.removeAll()
                }
                    let position_aux = self.controls[0].position.y * 0                                                          //0 respecto del padre commonnode
                    common_node.position.y = self.absolutePosition(relative: CGPoint(x: 0, y: -2)).y
                    let mov_seq = [SKAction.moveTo(y: position_aux * -1.5, duration: 1), SKAction.moveTo(y: position_aux * 1.5, duration: 0.2),SKAction.moveTo(y: position_aux, duration: 0.2)]
                    common_node.run(SKAction.sequence(mov_seq), completion: step4)              //los botones suben desde abajo hasta la posicion calculada arriba
                    self.addChild(common_node)
        }
        
        let step2 = {                                                               //El titulo se va hacia arriba
            self.title?.run(SKAction.move(to: self.absolutePosition(relative: CGPoint(x:0, y:0.30)), duration:0.5 ), completion: step3)
            print("")
        }
        let step1 = {
            self.veil.run(SKAction.fadeOut(withDuration: 0.3), completion: step2)   //desvanece el velo negro de la pantalla y pasa al paso 2
            print("")                                                           //Print para que el compilador no se queje
        }
        
        self.start?.run(SKAction.sequence(start_seq), completion: step1)        //Paso 0 El label de start se va de la pantalla
    }
    
    /*
     *Muestra la pantalla inicial
     */
    func showSplashScreen()
    {
        self.veil.size = self.size                                                                              //El velo negro ocupa toda la pantalla
        self.veil.color = SKColor.black
        self.veil.alpha = 0.8
        
        self.backgroundColor = SKColor(red: 107/255.0, green: 88/255.0, blue: 193/255.0, alpha: 1.0)            //Dibuja el findo y escala el muñeco para que entre en el alto proporcionadamente
        self.brainGuy = SKSpriteNode(imageNamed: brainGuyName)
        self.bgImage = SKSpriteNode(imageNamed: bgImageName)
        self.bgImage.position = CGPoint.zero
        self.bgImage.size.width /= self.bgImage.size.height / self.size.height                                  //calcula la escala
        self.bgImage.size.height = self.size.height
        var  brainguy_animation = [SKAction.rotate(byAngle: -0.30, duration: 0.7), SKAction.rotate(byAngle: 0.30, duration: 0.7)]
        brainguy_animation.append(contentsOf: brainguy_animation.reversed())
        
        self.brainGuy.position = self.bgImage.position
        self.brainGuy.position.y -= absolutePosition(relative: CGPoint(x:0, y:0.060)).y
        self.brainGuy.size.height /= self.brainGuy.size.width / self.bgImage.size.width
        self.brainGuy.size.width = self.bgImage.size.width
        self.brainGuy.setScale(0.7)
        self.brainGuy.run(SKAction.repeatForever(SKAction.sequence(brainguy_animation)))                           //las acciones del monigote para que se mueva a ambos lados
  
        self.start = SKLabelNode()
        self.start?.text = "Touch to start"
        self.start?.fontName = "Arial"
        self.start?.alpha = 0.5
        self.start?.fontSize = 20
        self.start?.position = absolutePosition(relative: CGPoint(x:0, y: -0.1))
      
        self.title = SKLabelNode()
        self.title?.text = "CHESS PUZZLES"
        self.title?.fontName = "Chalkduster"
        self.title?.fontSize = 80
        self.title?.position = absolutePosition(relative: CGPoint(x:0, y: -0.15))
        self.title?.setScale(0.0)

        var title_shows_actions = [SKAction.scale(to: 0.8, duration: 0.1), SKAction.scale(to: 1.2, duration: 0.1)]
        title_shows_actions.append(contentsOf: title_shows_actions)
        title_shows_actions.insert(SKAction.scale(to: 1.2, duration: 0.8), at: 0)
        title_shows_actions.append(SKAction.scale(to: 1.0, duration: 0.1))
        var title_shows_actions_loop = [SKAction.scale(to: 0.9, duration: 1.0), SKAction.scale(to: 1.0, duration: 1.0)]
        title_shows_actions_loop.append(contentsOf: title_shows_actions_loop)
        title_shows_actions.append(SKAction.repeatForever(SKAction.sequence(title_shows_actions_loop)))
        self.title?.run(SKAction.sequence(title_shows_actions))                                                    //Inicia las acciones del titulo
       
        self.bgImage.addChild(self.brainGuy)
        self.bgImage.addChild(self.veil)
        self.title?.addChild(self.start!)
        self.bgImage.addChild((self.title)!)
        
        self.addChild(self.bgImage)
    }
    
    /*Transiciona entre la pantalla de juego elegido la de seleccion de juegos. Se llama cuando el jugador pulsa cancel al elegir un juego
     */
    func unselectGame()
    {
        self.gameStatus = status.GAME_SELECT_SCREEN                                             //restaura el esta del juego
        self.veil.run(SKAction.fadeOut(withDuration: 1))
        self.game_selection_ok_node.run(SKAction.fadeOut(withDuration: 1))
        self.game_selection_cancel_node.run(SKAction.fadeOut(withDuration: 1))
        for i in self.game_description_labelnode.values                                         //Quita todas las descripciones
        {
            i.run(SKAction.fadeOut(withDuration: 1))
        }
        self.game_selected = ""
        for i in self.controls
        {
            i.run(SKAction.fadeIn(withDuration: 1))                                             //Hace otra vez visibles los controles
        }
    }
    
    /*
     *transicion entre la pantalla de seleccion y la de confirmacion. La funcion de arriba y esta hacen lo mismo pero a la inversa
     */
    func showGameSelectedScreen(button:GameButton, gamename:String)
    {
    let time_ = 0.4
    self.game_selection_node.alpha = 1.0
    self.game_description_labelnode[gamename]?.run(SKAction.fadeIn(withDuration: 1))
    self.veil.run(SKAction.fadeAlpha(by: 1.0, duration: time_))
    self.game_selected = gamename
    self.game_selection_ok_node.run(SKAction.fadeIn(withDuration: 1))
    self.game_selection_cancel_node.run(SKAction.fadeIn(withDuration: 1))
        for i in self.controls
        {
            i.run(SKAction.fadeOut(withDuration: 1))
        }
    }
    
    
    /*
     *Lanza las pantallas de seleccion segun el juego elegido
     */
    func nQueensGame(button:Any)
    {
        let name = "nQueens"
        self.gameStatus = status.GAME_SELECTED_SCREEN                   //To esto va  a la mierda
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
    }
    
    func bishopsGame(button:Any)
    {
        let name = "Bishops"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
    }
    
    func KnightsGame(button:Any)
    {
        let name = "Knights"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
    
    }
    
    func Knights36(button:Any)
    {
        let name = "Knights36"
        self.gameStatus = status.GAME_SELECTED_SCREEN
        self.showGameSelectedScreen(button: button as! GameButton, gamename: name)
        self.veil.run(SKAction.fadeIn(withDuration: 0.4))
    }
    
    /*
     *Crea los botones de juegos con los nombres, imagenes y selectores pasados en los arrays
     */
    func createButtons(images_paths:[String], handler_functions:[Selector], handler:NSObject) -> [GameButton]
    {
        var buttons:[GameButton] = Array(repeating: GameButton(), count: images_paths.count)
        for i in 0...buttons.count - 1
        {
            buttons[i] = GameButton(imageNamed: images_paths[i])
            buttons[i].handler_function = handler_functions[i]
            buttons[i].handler_object = handler                                                                                     //funcion que va a llamar este boton al pulsarse
        }
        return buttons
    }
    
    /*
     * Calcula la posicion y scala de los botones para que cuadre en un rectangolo de forma equidistante. Con esto se calcula la posicion de los botones en pantalla
     */
    func setButtonsRowPosition(buttons:[GameButton], area_:CGSize, surface:CGRect) -> [GameButton]
    {
        var area = area_
        area.width /= CGFloat(self.relative_width_Max)                                                                              //Si el area por boton es mayor que el rectangulo termina
        if(surface.size.height < area.height || surface.size.width < area.width)
        {
            return []
        }
        let offset = Float ((Float(surface.size.width) - (Float(area.width) * Float(buttons.count)) ) / Float(buttons.count))       //distancia entre botones
        var pos:Float = 0.0
        for i in 0...buttons.count - 1
        {
            buttons[i].size = CGSize(width: area.width * self.size.width , height: area.height * self.size.height )
            buttons[i].position = surface.origin
            buttons[i].position.x += CGFloat(pos)
            buttons[i].position = absolutePosition(relative: buttons[i].position)
            buttons[i].position.x -= absolutePosition(relative:self.anchorPoint).x                                                  //Remiendo de mierda
            buttons[i].position.y -= absolutePosition(relative:self.anchorPoint).y
            pos += Float(area.width) + offset
        }
        return buttons
    }
    
    /*
     * Devielve las coordenadas absolutas a partir de las relativas
     */
    func absolutePosition(relative:CGPoint) -> CGPoint
    {
        return CGPoint(x: self.size.width * relative.x , y: self.size.height * relative.y)
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    /*
     *Aqui se procesamn los toques en la pantalla dependindo del estado en que se encuentre el menu
     */
    func touchUp(atPoint pos : CGPoint) {
        
        switch self.gameStatus
        {
        case status.START_SCREEN:                                                                                           //En la pantalla inicial cualquier toque avanza de pantalla
                self.gameStatus = status.GAME_SELECT_SCREEN
                self.showSelectGameScreen()
        return
        
        case status.GAME_SELECTED_SCREEN:                                                                                   //En la pantalla de confirmacion atiende las pulsaciones de ok y cancel

            if(self.game_selection_cancel_node.contains(pos))
            {
                self.unselectGame()                                                                                         //vuelve a la anterior pantalla
            }
            if(self.game_selection_ok_node.contains(pos))
            {
                self.removeAllChildren()
                self.viewController?.changeToGameScene(game: self.game_selected, options: [:])                              //Lanza el juego seleccionado segun la cadena atributo game selected
            }
        break
            
        case status.GAME_SELECT_SCREEN:                                                                                     //Pantalla de seleccion de juego. Lanza el handler del boton
            for i in self.controls
            {
                if(i.isHidden)
                {
                    continue                                                                                                //si no estan en pantallas no los considera
                }
                if(i.contains(pos))
                {
                    i.handler_object.performSelector(onMainThread: i.handler_function, with: i as Any, waitUntilDone: true)     //lanza el handler del boton
                }
            }
            break
        default:
        break
        }
      
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        
        }
    }
    /*
     *Autogeneradas no se usan
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
