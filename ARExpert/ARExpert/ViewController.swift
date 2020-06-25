//
//  ViewController.swift
//  ARPlaneObject
//
//  Created by Malvin Santoso on 24/06/20.
//  Copyright © 2020 Malvin Santoso. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController{

    @IBOutlet weak var arView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToSceneView()
        
        configureLighting()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSceneView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        arView.session.pause()
    }
    
    func setupSceneView(){ // SETUP YANG HARUS ADA DI UNTUK PREPARE AR SCENEVIEW
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        arView.delegate = self
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }


    
    func configureLighting() {
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
    }

    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
            let tapLocation = recognizer.location(in: arView)
            let hitTestResults = arView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

            guard let hitTestResult = hitTestResults.first else { return }
            let translation = SCNMatrix4(hitTestResult.worldTransform)

            let hitVector = SCNVector3(translation.m41, translation.m42, translation.m43)

            guard let shipScene = SCNScene(named: "art.scnassets/ship.scn"),
                let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
                else { return }


            shipNode.position = hitVector
            arView.scene.rootNode.addChildNode(shipNode)
            print("masuk func nambahin kapal")
        }
        
        func addTapGestureToSceneView() {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addShipToSceneView(withGestureRecognizer:)))
            arView.addGestureRecognizer(tapGestureRecognizer)
            print("masuk")
        }
    }


extension ViewController:ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
         // 1
           guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
           
           // 2
           let width = CGFloat(planeAnchor.extent.x)
           let height = CGFloat(planeAnchor.extent.z)
           let plane = SCNPlane(width: width, height: height)
           
           // 3
           plane.materials.first?.diffuse.contents = UIColor.red
           
           // 4
           let planeNode = SCNNode(geometry: plane)
           
           // 5
           let x = CGFloat(planeAnchor.center.x)
           let y = CGFloat(planeAnchor.center.y)
           let z = CGFloat(planeAnchor.center.z)
           planeNode.position = SCNVector3(x,y,z)
           planeNode.eulerAngles.x = -.pi / 2
           
           // 6
           node.addChildNode(planeNode)
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
         
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
         
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)

    }
}

