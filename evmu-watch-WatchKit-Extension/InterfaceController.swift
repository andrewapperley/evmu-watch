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

struct InputMap {
	enum Inputs {
		case up
		case down
		case left
		case right
		
		case a
		case b
		
		case sleep
		case mode
	}
	
	var up: [Int32] = []
	var down: [Int32] = []
	var left: [Int32] = []
	var right: [Int32] = []
	
	var a: [Int32] = []
	var b: [Int32] = []
	
	var sleep: [Int32] = []
	var mode: [Int32] = []
}

protocol EmulatorDelegate: class {
	func didSelectRom(path: String)
}

class InterfaceController: WKInterfaceController {

	var inputMap = InputMap()
	var currentRomPath: String? = nil
	
	@IBOutlet weak var screen: WKInterfaceSCNScene!
	
	let device = gyVmuDeviceCreate()
	var updateTime: TimeInterval = 0
	
	override func didAppear() {
		super.didAppear()
		if self.currentRomPath == nil {
			showRomSelectionView()
		}
	}
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		showRomSelectionView()
		guard screen.scene == nil else { return }
		
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
	
	@IBAction func showSettings() {
		presentController(withName: "EmulatorSettingsController", context: nil)
	}
	
	@IBAction func showRomSelectionView() {
		presentController(withName: "RomSelectionController", context: self)
	}
}

extension InterfaceController {
	@IBAction func onUpTapped() {
		inputMap.up.append(1)
		inputMap.up.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onDownTapped() {
		inputMap.down.append(1)
		inputMap.down.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onLeftTapped() {
		inputMap.left.append(1)
		inputMap.left.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onRightTapped() {
		inputMap.right.append(1)
		inputMap.right.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onATapped() {
		inputMap.a.append(1)
		inputMap.a.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onBTapped() {
		inputMap.b.append(1)
		inputMap.b.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onSleepAndModeTapped(_ sender: WKPanGestureRecognizer) {
		let x = sender.velocityInObject().x
		switch sender.state {
//			Left is Mode
//			Right is Sleep
		case .began:
			if x > 0 {
				inputMap.sleep.append(1)
			} else {
				inputMap.mode.append(1)
			}
		case .ended, .cancelled, .failed:
			if x > 0 {
				inputMap.sleep.append(0)
			} else {
				inputMap.mode.append(0)
			}
		default:
			break
		}
	}
}

extension InterfaceController {
	private func loadRom(at path: String) {
		gyVmuDeviceReset(device)
		var status: VMU_LOAD_IMAGE_STATUS! = VMU_LOAD_IMAGE_STATUS(rawValue: 0)
		gyVmuFlashLoadImage(device, path, &status)
	}
}

extension InterfaceController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		
		guard let scene = self.screen.scene else {
			return
		}
		
		// Process input queue
		processInputQueue()
		
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
	}
	
	private func processInputQueue() {
		
		if !inputMap.up.isEmpty {
			gyVmuButtonStateSet(device, .init(0), inputMap.up.remove(at: 0))
		}
		
		if !inputMap.down.isEmpty {
			gyVmuButtonStateSet(device, .init(1), inputMap.down.remove(at: 0))
		}
		
		if !inputMap.left.isEmpty {
			gyVmuButtonStateSet(device, .init(2), inputMap.left.remove(at: 0))
		}
		
		if !inputMap.right.isEmpty {
			gyVmuButtonStateSet(device, .init(3), inputMap.right.remove(at: 0))
		}

		if !inputMap.a.isEmpty {
			gyVmuButtonStateSet(device, .init(4), inputMap.a.remove(at: 0))
		}
		
		if !inputMap.b.isEmpty {
			gyVmuButtonStateSet(device, .init(5), inputMap.b.remove(at: 0))
		}
		
		if !inputMap.mode.isEmpty {
			gyVmuButtonStateSet(device, .init(6), inputMap.mode.remove(at: 0))
		}

		if !inputMap.sleep.isEmpty {
			gyVmuButtonStateSet(device, .init(7), inputMap.sleep.remove(at: 0))
		}
	}
}

extension InterfaceController: EmulatorDelegate {
	func didSelectRom(path: String) {
		self.currentRomPath = path
		loadRom(at: path)
	}
}
