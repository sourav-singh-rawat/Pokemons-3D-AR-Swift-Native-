//
//  ViewController.swift
//  Pokemons
//
//  Created by Sourav Singh Rawat on 23/11/22.
//

import UIKit
import SceneKit
import ARKit

struct PokemonDetails {
    let identifier: String
    let model: String
}

let pokemonsRegistered: [String:PokemonDetails] = [
    "Eevee-card": PokemonDetails(identifier: "Eevee", model: "art.scnassets/Eevee/Eevee.scn"),
    "Oddish-card":PokemonDetails(identifier: "Oodish", model: "art.scnassets/Oddish/Oddish.scn")
]

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main){
            
            configuration.trackingImages = imageToTrack
            
            configuration.maximumNumberOfTrackedImages = 2
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let planeNode = createPlaneOverCard(withImageAnchor: imageAnchor)
            
            node.addChildNode(planeNode)
            
            if let pokemonNode = createPokemon3DModel(withImageAnchor: imageAnchor) {
                planeNode.addChildNode(pokemonNode)
            }
        }
        
        return node
    }
    
    //MARK: - Plane Methods
    
    func createPlaneOverCard(withImageAnchor imageAnchor: ARImageAnchor) -> SCNNode{
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi/2
        
        return planeNode
    }
    
    //MARK: - Pokemon methods
    
    func createPokemon3DModel(withImageAnchor imageAnchor: ARImageAnchor) -> SCNNode? {
        guard let pokemonName = imageAnchor.referenceImage.name else {
            fatalError("Pokemon not registered")
        }
        
        guard let pokemonDetails = pokemonsRegistered[pokemonName] else {
            fatalError("Pokemon details not registered")
        }
        
        let pokemonScene = SCNScene(named: pokemonDetails.model)
        
        if let pokemonNode = pokemonScene?.rootNode.childNode(withName: pokemonDetails.identifier, recursively: true) {
            pokemonNode.eulerAngles.x = .pi/2
            //TODO: Scale is not working for pokemon
//                pockemonNode.position = SCNVector3(0, 0, -0.99)
//                pockemonNode.transform = SCNMatrix4MakeRotation(-.pi/2, 0, 0, 1)
            
            return pokemonNode
        }
        
        return nil
    }
}
