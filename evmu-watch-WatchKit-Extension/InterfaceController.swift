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

struct InputQueues {
	var up: [Int32] = []
	var down: [Int32] = []
	var left: [Int32] = []
	var right: [Int32] = []
	
	var a: [Int32] = []
	var b: [Int32] = []
	
	var sleep: [Int32] = []
	var mode: [Int32] = []
}

class InterfaceController: WKInterfaceController {

	var inputQueues = InputQueues()
	
	@IBOutlet weak var screen: WKInterfaceSCNScene!
	
	let device = gyVmuDeviceCreate()
	var updateTime: TimeInterval = 0
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		guard let path = Bundle.main.path(forResource: "minigame", ofType: "dci") else {return}
		var status: VMU_LOAD_IMAGE_STATUS! = VMU_LOAD_IMAGE_STATUS(rawValue: 0)
		gyVmuFlashLoadImage(device, path, &status)
		
		guard status == VMU_LOAD_IMAGE_SUCCESS else {
			return
		}
		
		let scene = SCNScene()
		let action = SCNAction.scale(by: 1.0, duration: 1.0)
		let repeatAction = SCNAction.repeatForever(action)
		scene.rootNode.runAction(repeatAction)
		screen.scene = scene
		screen.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
	
	override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension InterfaceController {
	@IBAction func onUpTapped(_ sender: WKLongPressGestureRecognizer) {
		switch sender.state {
		case .began:
			inputQueues.up.append(1)
		case .ended, .cancelled, .failed:
			inputQueues.up.append(0)
		default:
			break
		}
	}
	@IBAction func onDownTapped(_ sender: WKLongPressGestureRecognizer) {
		switch sender.state {
		case .began:
			inputQueues.down.append(1)
		case .ended, .cancelled, .failed:
			inputQueues.down.append(0)
		default:
			break
		}
	}
	@IBAction func onLeftTapped(_ sender: WKLongPressGestureRecognizer) {
		switch sender.state {
		case .began:
			inputQueues.left.append(1)
		case .ended, .cancelled, .failed:
			inputQueues.left.append(0)
		default:
			break
		}
	}
	@IBAction func onRightTapped(_ sender: WKLongPressGestureRecognizer) {
		switch sender.state {
		case .began:
			inputQueues.right.append(1)
		case .ended, .cancelled, .failed:
			inputQueues.right.append(0)
		default:
			break
		}
	}
	
	@IBAction func onATapped(_ sender: WKLongPressGestureRecognizer) {
		switch sender.state {
		case .began:
			inputQueues.a.append(1)
		case .ended, .cancelled, .failed:
			inputQueues.a.append(0)
		default:
			break
		}
	}
	@IBAction func onBTapped(_ sender: WKLongPressGestureRecognizer) {
		switch sender.state {
		case .began:
			inputQueues.b.append(1)
		case .ended, .cancelled, .failed:
			inputQueues.b.append(0)
		default:
			break
		}
	}
	
	@IBAction func onSleepAndModeTapped(_ sender: WKPanGestureRecognizer) {
		let x = sender.velocityInObject().x
		switch sender.state {
//			Left is Mode
//			Right is Sleep
		case .began:
			if x > 0 {
				inputQueues.sleep.append(1)
			} else {
				inputQueues.mode.append(1)
			}
		case .ended, .cancelled, .failed:
			if x > 0 {
				inputQueues.sleep.append(0)
			} else {
				inputQueues.mode.append(0)
			}
		default:
			break
		}
	}
}

extension InterfaceController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		guard let scene = self.screen.scene else {
			return
		}
		if updateTime == 0.0 { updateTime = time }
		let deltaTime = time - updateTime
		updateTime = time
		
		gyVmuDeviceUpdate(device, Float(deltaTime))
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
		if (device != nil && device!.pointee.lcdFile != nil) {
			print(device!.pointee.lcdFile.pointee.state)
			
		}
		// Process input queue
		processInputQueue()
	}
	
	private func processInputQueue() {
		
		if inputQueues.up.count > 0 {
			gyVmuButtonStateSet(device, .init(0), inputQueues.up.remove(at: 0))
		}
		if inputQueues.down.count > 0 {
			gyVmuButtonStateSet(device, .init(1), inputQueues.down.remove(at: 0))
		}
		if inputQueues.left.count > 0 {
			gyVmuButtonStateSet(device, .init(2), inputQueues.left.remove(at: 0))
		}
		if inputQueues.right.count > 0 {
			gyVmuButtonStateSet(device, .init(3), inputQueues.right.remove(at: 0))
		}
		
		if inputQueues.a.count > 0 {
			gyVmuButtonStateSet(device, .init(4), inputQueues.a.remove(at: 0))
		}
		if inputQueues.b.count > 0 {
			gyVmuButtonStateSet(device, .init(5), inputQueues.b.remove(at: 0))
		}
		
		if inputQueues.mode.count > 0 {
			gyVmuButtonStateSet(device, .init(6), inputQueues.mode.remove(at: 0))
		}
		if inputQueues.sleep.count > 0 {
			gyVmuButtonStateSet(device, .init(7), inputQueues.sleep.remove(at: 0))
		}
	}
}
