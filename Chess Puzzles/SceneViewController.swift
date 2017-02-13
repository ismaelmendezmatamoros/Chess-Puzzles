//
//  GameViewController.swift
//  scene
//
//  Created by eicke on 11/1/17.
//  Copyright © 2017 eicke. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import Foundation
import  GoogleMobileAds

/*
 * Clase base para cada uno de los juegos. En esta clase se realiza el main loop de cada juego con cada uno de sus pasos
 *
 */

class BoardGameViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    
    let adUnitID = "ca-app-pub-1495047417563453/2347831524"
    let add_interval = 260
    private var semaphore:semaphore_t = semaphore_t()
    var numplayers:Int = 0                                                              //numero de jugadores del juego
    var turns:Int = 0                                                                   //turnos efectuados
    var rounds:Int = 0                                                                  //rondas efectuadas
    var scene = SCNScene()
    var touchEnabled = false
    var parameters:[String:Any] = [:]                                                   //opciones pasadas como parametros para el juego
    var board:Board?                                                                    //instancia de tablero del juego
    var pieces:[String:Piece] = [:]                                                     //tipos de Piezas diferentes organizadas por nombre. Dsitinto de las piezas del tablero
    var exitButton:SKLabelNode = SKLabelNode()                                          //Sprite que hace de boton de salida en el overlay de los juegos
    var moves:SKLabelNode = SKLabelNode()                                               //Sprite del numero de movimientos efectads
    var victory:Bool = false                                                            //Si la partida ha terminado o no
    
    
    let movement_semaphore = DispatchSemaphore.init(value: 0)                           //semaforos para controlar el avance en las etapas de la partida. ver mas adelante
    let before_turn_semaphore = DispatchSemaphore.init(value: 0)
    let turns_end_semaphore = DispatchSemaphore.init(value: 0)
    
    let before_round_semaphore = DispatchSemaphore.init(value: 0)
    let round_end_semaphore = DispatchSemaphore.init(value: 0)
    
    let victory_semaphore = DispatchSemaphore.init(value: 0)
    
    override func viewDidLoad() {
        
        scene = SCNScene()
        let scnView = self.view as! SCNView

        scnView.scene = scene
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
      
        // configure the view
        scnView.backgroundColor = UIColor.black
        scnView.antialiasingMode = .multisampling4X
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        scnView.addGestureRecognizer(tapGesture)
        self.performSelector(inBackground: #selector(BoardGameViewController.startGameLoop), with: nil)                    //Lanza la ejecucion del main loop del juego.ver funcion mas adelante
        self.performSelector(inBackground: #selector(BoardGameViewController.startAddLoop), with: nil)
    }
    
    func startAddLoop(){
        while(true){
            sleep(UInt32(self.add_interval))
            self.interstitial = createAndLoadInterstitial()
        }
    }
    
    /*
     *Mustra el boton de exit y el numero de turnos
     **/
    func showOverlays()
    {
        let vie = self.view as! SCNView
        let overlay = SKScene.init(size:  CGSize.init(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))                //Añade una capa de SKscene sobre la escena
        self.showOverlay(overlay: overlay ,node: self.exitButton, text: "exit", fontsize: CGFloat(30), x_relative: 0.95, y_relative: 0.05)              //Crea y añade los SKlabels
        self.showOverlay(overlay: overlay ,node: self.moves, text: "moves: 0", fontsize: CGFloat(20), x_relative: 0.5, y_relative: 0.95)
        vie.overlaySKScene = overlay
    }
    
    /*
     *Crea y coloca un SKlabelnode con lo pasado en la escena pasada
     */
    ////////////
    
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial =
            GADInterstitial(adUnitID: adUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }

    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }    }
    
    func interstitialDidDismissScreen(_ interstitial: GADInterstitial) {
        self.perform(#selector(createAndLoadInterstitial), with: nil, afterDelay: TimeInterval(add_interval))
    }
    
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        // Retrying failed interstitial loads is a rudimentary way of handling these errors.
        // For more fine-grained error handling, take a look at the values in GADErrorCode.
        self.interstitial = createAndLoadInterstitial()
    }    ////////////////
    
    
    func showOverlay(overlay:SKScene ,node:SKLabelNode, text:String, fontsize:CGFloat , x_relative:CGFloat , y_relative:CGFloat)
    {
        node.text = text
        node.fontColor = UIColor.white
        node.fontSize = fontsize
        node.position.x = UIScreen.main.bounds.size.width * x_relative                                                                                  //la posicion se calcula de forma relativa
        node.position.y = UIScreen.main.bounds.size.height * y_relative
        let fade = [SKAction.fadeAlpha(to: 0.3, duration: 2) ,SKAction.fadeAlpha(to: 1.0, duration: 2)]                                                 //Añade un efecto de fadein/fadeout
        node.run(SKAction.repeatForever(SKAction.sequence(fade)))
        overlay.addChild(node)
    }
    
    /*
     * Main loop del juego. Consta de las fases de: 
     *      -configuracion del juego
     *       -configuracion de la escena
     *           -hacer rondas hasta que se alcance la vitoria o se pulse salir
     *
     *Fases de rondas desglosadas mas adelante
     */
    func startGameLoop()
    {
        self.setupGame()
        self.setupScene()
        while (true)
        {
            self.doRound()
        }
    }
    
    /*
     * implementada en las subclases
     */
    func setupGame() {}
    
    
    /*
     * Funcionalidad implementada en las subclases. Aqui solo se hace una rotacion inicial del tablero
     */
    func setupScene()
    {
        self.board?.runAction(SCNAction.rotate(by: 3.1416 * 0.1, around: SCNVector3.init(1.0, -1.0, 0.0), duration: 0.5))
    }
    
    
    /*
     *Carga los modelos cuyo nombbre aparezaca en el array de un fichero 3D, añade color a los modelos y los devuelve en un diccionario catalogados por nombre
     */
    func loadModelsFromFile(filename:String, names:[String], color:UIColor) -> [String:Piece]
    {

        let scene_aux = SCNScene(named: filename)
        let lambda = { (node:SCNNode, b:UnsafeMutablePointer<ObjCBool>) -> Bool in             // funcion que extrae los nodos que coincidan con el nombre
            node.scale = SCNVector3.init(float3.init(1.0))                                     //Si estan escalados dentro de la escena del fichero los restituye
            if(node.geometry != nil)
            {
                node.geometry?.firstMaterial?.diffuse.contents = color
            }
            return names.contains(node.name!)
        }
        let nodes = scene_aux?.rootNode.childNodes(passingTest: lambda)                         //saca los nodos de la escena del fichero
        var dic:[String:Piece] = [:]
        for i in nodes!                                                                         //Por cada nodo sacado crea una pieza diferente
        {
            let piece:Piece = Piece()
            piece.node = i                                                                      //Asigna el nodo extraido a la pieza
            piece.node.castsShadow = true
            dic[piece.node.name!] = piece
        }
        return dic
    }
    
    /*
     *Genera tantos equipos con tantos colores de tantas piezas como los elementos pasados por arrays
     */
    func generateTeamsPieces(modelsfilename:String ,teams:[String], piecenames:[String],color:[UIColor]) -> [String:Piece]
    {
        var dic:[String:Piece] = [:]
        for i in 0...teams.count - 1
        {
            let team_pieces = self.loadModelsFromFile(filename: modelsfilename, names: piecenames, color: color[i])         //Cada equipo tiene su propia copia en memoria de las piezas
            
            let lambda = { (a:(key: String, value: Piece)) in
                a.value.setName(name: teams[i] + "-" + a.value.node.name!)                                                  //Cada pieza lleva en nombre del equipo delante del suyo
                a.value.node.geometry?.firstMaterial?.diffuse.contents = color[i]
                dic[a.value.node.name!] = a.value
            }
            team_pieces.forEach(lambda)
        }
        return dic
    }
    
    /*
     *Funciones que realiza cada etapa de un turno. La funcionalidad pertenece a la subclase, aqui solo se abre el semaforo para pasar a la siguiente cuando termina
     */
    
    /*Etapa de antes de comienzo de turno. reciben el numero del juegador del turno.
     */
    func beforeTurnStarts(player:Int) -> Bool
    {
        self.before_turn_semaphore.signal()
        return true
    }
    
    /*
     * Funcion que indica que el jugador ya ha movido
     */
    func finalizeTurn()
    {
        self.movement_semaphore.signal()
    }
    
    /*
     *Etapa de fin de turno
     */
    func turnsEnd(player:Int)
    {
        self.turns_end_semaphore.signal()
    }
    
    /*
     * Funcion que se llama despues de cada movimiento y dice si la partida se ha ganado.Desde la subclase se debe cabiar el valor del atributo victory para capturar los toques
     */
    func victoryConditionCheck() -> Bool
    {
        return false
    }
    
    /*
     * En caso de ganar el juego se ejecuta esta funcion. Muestra el texto y realiza las animaciones de la victoria
     */
    func onVictory(winner:Int)
    {
        let view = self.view as! SCNView
        let board_action = SCNAction.repeatForever(SCNAction.rotate(by: 15.5, around: SCNVector3.init(0.0, 1.0, 0.0), duration: 2.5))
        self.board?.runAction(board_action)
        let label = SKLabelNode()
        self.showOverlay(overlay: view.overlaySKScene!, node: label, text: "YOU MADE IT!", fontsize: 50, x_relative: 0.5, y_relative: 0.5)
        let label_action = [SKAction.scale(to: 1.5, duration: 0.6), SKAction.scale(to: 0.6, duration: 0.6)]
        label.run(SKAction.repeatForever(SKAction.sequence(label_action)))
        self.victory = true
    }
    
    /*
     *Funciones que realiza cada etapa de una etapa. La funcionalidad pertenece a la subclase, aqui solo se abre el semaforo para pasar a la siguiente cuando termina
     */
    func onRoundStarts()
    {
        self.before_round_semaphore.signal()
    }
    
    func onRoundEnds()
    {
        self.round_end_semaphore.signal()
    }
    
    /*
     * Funcion que ejecuta una ronda por etapas
     */
    func doRound()
    {
        self.rounds += 1
        self.onRoundStarts()
        self.before_round_semaphore.wait()
        for i in 0...numplayers                                                 //Por cada jugador se ejecuta un turno con todas sus etapas
        {
            self.doTurn(player: i)
            if(self.victoryConditionCheck())                                    //Si despues de un turno se llega ala victoria realiza lo que haya en onvictory y sale al tocar la pantalla
            {
                self.onVictory(winner: i)
                self.victory_semaphore.wait()
                self.exitToMenu()
            }
        }
        self.onRoundEnds()
        self.round_end_semaphore.wait()
    }
    
    /*
     *Funcion de jecucion de un turno y sus etapas:
     *  -Antes del turno
        -Interacciobn con el juegador
        - despues del turno
     *
     * hasta que no se llame finalizeturn() despues de la fase de interaccion los toques de pantalla se procesan como que forman parte de un turno
     */
    func doTurn(player:Int)
    {

        self.turns += 1
        
        print(self.turns)
        
        let executes_turn = self.beforeTurnStarts(player: player)
        self.before_turn_semaphore.wait()
        if(executes_turn == false)                                              //Si no se da una condicion propicia se salta el turno. Util si ghay dos jugadores y se pueden anular los turnos uno a otro
        {
            return
        }
        self.touchEnabled = true

        self.movement_semaphore.wait()                                          // Solo procesa los toques durante la ejecucion de un turno
        self.touchEnabled = false
        
        self.turnsEnd(player: player)
        self.turns_end_semaphore.wait()
    }
    
    /*
     * Termina un juego
     */
    func exitToMenu()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "MenuScreen") as! GameViewController
        self.present(resultViewController, animated:true, completion:nil)
        return
    }
    
    /*
     * Funcionalidad en la subclase donde procesan los toques. Aqui solo da por terminada la fase
     */
    func handleTouchOnTurn(_ gestureRecognize: UIGestureRecognizer)
    {
        self.finalizeTurn()
    }
    
    
    /*
     *Ilumina todos las casillas pasadas en el array a la vez
     **/
    func highLightSquares(squares:[(x:Int, y:Int)], color:UIColor, duration:Float)
    {
        let lambda = {
            (iter:Int) in
            let pos = squares[iter]
            self.highLightModel(model: (self.board?.board[pos.x][pos.y]?.node)! , color: color, duration: duration)
        }
        DispatchQueue.concurrentPerform(iterations: squares.count, execute: lambda)     //Ejcuta en paralelo todas las iluminaciones
    }

    /*
     * True si dentro del arra existe el elemento (x:Int, y:Int) paasado
     */
    func squareArrayContains(array:[(x:Int, y:Int)], element:(x:Int, y:Int) ) -> Bool
    {
            let compare_lambda =
                {
                    (a:(x:Int, y:Int)) in
                    return a.x == element.x && a.y == element.y
            }
        return  array.contains(where: compare_lambda)
    }
    
    /*
     * Ilumina cambiando las propiedades de la iluminacion emisiva del material de  la geometria del nodo pasado y todos sus hijos
     */
    func highLightModel(model:SCNNode, color:UIColor, duration:Float)
    {
        
       let lambda =  { (node:SCNNode, b:UnsafeMutablePointer<ObjCBool>)-> Void in
            if(node.geometry == nil)
            {
                return
            }
            let material = node.geometry!.firstMaterial!
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(duration)
            SCNTransaction.completionBlock = {
            SCNTransaction.begin()                                                      //Vuelta a la normalidad
            SCNTransaction.animationDuration = CFTimeInterval(duration)
            material.emission.contents = UIColor.black
            SCNTransaction.commit()
        }
        material.emission.contents = color
        SCNTransaction.commit()
        }
        model.enumerateChildNodes(lambda)
    }
    
    func getTouchedElements(_ gestureRecognize: UIGestureRecognizer) -> [SCNHitTestResult]
    {
        let scnView = self.view as! SCNView
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        return hitResults
    }
    
    /*
     * Funcion que sirve como colector de los toques. Segun el estado del juego delega su procesamiento en otras funciones
     */
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView 
        let scnView = self.view as! SCNView
        let point = gestureRecognize.location(in: scnView)
        let con_point = scnView.overlaySKScene?.convertPoint(fromView: point)
        if(self.exitButton.contains(con_point!) || self.victory)                                //Sise ha tocado el boton exit o ya se ha ganado sale del juego
        {
            self.exitToMenu()
        }
        if(self.touchEnabled)                                                                   //Si esta en medio de un turno llama a la funcion que debe ser completada en la subclase
        {
            self.handleTouchOnTurn(gestureRecognize)
        }
        return
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
