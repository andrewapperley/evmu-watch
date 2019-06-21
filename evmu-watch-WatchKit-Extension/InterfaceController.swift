//
//  InterfaceController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-06-15.
//  Copyright © 2019 es. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit
import UIKit


class InterfaceController: WKInterfaceController {

	@IBOutlet weak var screen: WKInterfaceSCNScene!
	let device = gyVmuDeviceCreate()
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		guard let path = Bundle.main.path(forResource: "minigame", ofType: "dci") else {return}
		var status: VMU_LOAD_IMAGE_STATUS! = VMU_LOAD_IMAGE_STATUS(rawValue: 0)
		gyVmuFlashLoadImage(device, path, &status)
		
		let scene = SCNScene()
		let dummyAction = SCNAction.scale(by: 1.0, duration: 1.0)
		let repeatAction = SCNAction.repeatForever(dummyAction)
		scene.rootNode.runAction(repeatAction)
		screen.scene = scene
		screen.delegate = self
		
		
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
//		gyVmuDeviceDestroy(device)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension InterfaceController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		guard let scene = self.screen.scene else {
			return
		}
		gyVmuDeviceUpdate(device, 1)
		UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(VMU_DISP_PIXEL_WIDTH), height: CGFloat(VMU_DISP_PIXEL_HEIGHT)), true, 1)
		guard let context = UIGraphicsGetCurrentContext() else {return}
		for y in (0..<VMU_DISP_PIXEL_HEIGHT) {
			for x in (0..<VMU_DISP_PIXEL_WIDTH) {
				let rect = CGRect(x: Int(x), y: Int(y), width: 1, height: 1)
				context.setFillColor(gyVmuDisplayPixelGet(device, x, y) > 0 ? UIColor.black.cgColor : UIColor.white.cgColor)
				context.fill(rect)
			}
		}
		
		scene.background.contents = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	}
}
