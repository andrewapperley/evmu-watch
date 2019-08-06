//
//  EmulatorController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-07-29.
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

protocol InputHandling {
	mutating func updateInputMap(input: InputMap.Inputs, finished: Bool)
}

class Emulator {
	var inputMap = InputMap()
	var currentRomPath: String? = nil
	let device = gyVmuDeviceCreate()
	var updateTime: TimeInterval = 0
	
	func loadRom(at path: String) {
		gyVmuDeviceReset(device)
		var status: VMU_LOAD_IMAGE_STATUS! = VMU_LOAD_IMAGE_STATUS(rawValue: 0)
		gyVmuFlashLoadImage(device, path, &status)
		currentRomPath = path
	}
}

extension Emulator: InputHandling {
	func updateInputMap(input: InputMap.Inputs, finished: Bool = true) {
		switch input {
		case .up:
			inputMap.up.append(1)
			inputMap.up.append(0)
		case .down:
			inputMap.down.append(1)
			inputMap.down.append(0)
		case .left:
			inputMap.left.append(1)
			inputMap.left.append(0)
		case .right:
			inputMap.right.append(1)
			inputMap.right.append(0)
		case .a:
			inputMap.a.append(1)
			inputMap.a.append(0)
		case .b:
			inputMap.b.append(1)
			inputMap.b.append(0)
		case .sleep:
			inputMap.sleep.append(finished ? 0 : 1)
		case .mode:
			inputMap.mode.append(finished ? 0 : 1)
		@unknown default:
			print("Unknown input was activated")
		}
	}
}

class EmulatorController: WKInterfaceController {
	let emulator = Emulator()
	@IBOutlet weak var screen: WKInterfaceSCNScene!
	
	override func didAppear() {
		super.didAppear()
		if emulator.currentRomPath == nil {
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
	
	@IBAction func showSettings() {
		presentController(withName: "EmulatorSettingsController", context: nil)
	}
	
	@IBAction func showRomSelectionView() {
		presentController(withName: "RomSelectionController", context: self)
	}
	
	@IBAction func onUpTapped() {
		emulator.inputMap.up.append(1)
		emulator.inputMap.up.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onDownTapped() {
		emulator.inputMap.down.append(1)
		emulator.inputMap.down.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onLeftTapped() {
		emulator.inputMap.left.append(1)
		emulator.inputMap.left.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onRightTapped() {
		emulator.inputMap.right.append(1)
		emulator.inputMap.right.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onATapped() {
		emulator.inputMap.a.append(1)
		emulator.inputMap.a.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onBTapped() {
		emulator.inputMap.b.append(1)
		emulator.inputMap.b.append(0)
		WKInterfaceDevice.current().play(.click)
	}
	
	@IBAction func onSleepAndModeTapped(_ sender: WKPanGestureRecognizer) {
		let x = sender.velocityInObject().x
		switch sender.state {
			//			Left is Mode
		//			Right is Sleep
		case .began:
			if x > 0 {
				emulator.inputMap.sleep.append(1)
			} else {
				emulator.inputMap.mode.append(1)
			}
		case .ended, .cancelled, .failed:
			if x > 0 {
				emulator.inputMap.sleep.append(0)
			} else {
				emulator.inputMap.mode.append(0)
			}
		default:
			break
		}
	}
}

extension EmulatorController: EmulatorDelegate {
	func didSelectRom(path: String) {
		emulator.loadRom(at: path)
	}
}

extension EmulatorController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		
		guard let scene = self.screen.scene else {
			return
		}
		
		// Process input queue
		processInputQueue()
		
		if emulator.updateTime == 0.0 { emulator.updateTime = time }
		let deltaTime = time - emulator.updateTime
		emulator.updateTime = time
		
		gyVmuDeviceUpdate(emulator.device, Float(deltaTime))
		UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(VMU_DISP_PIXEL_WIDTH), height: CGFloat(VMU_DISP_PIXEL_HEIGHT)), true, 1)
		guard let context = UIGraphicsGetCurrentContext() else {return}
		for y in (0..<VMU_DISP_PIXEL_HEIGHT) {
			for x in (0..<VMU_DISP_PIXEL_WIDTH) {
				let rect = CGRect(x: Int(x), y: Int(y), width: 1, height: 1)
				context.setFillColor(gyVmuDisplayPixelGet(emulator.device, x, y) > 0 ? UIColor.black.cgColor : UIColor.white.cgColor)
				context.fill(rect)
			}
		}
		
		scene.background.contents = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	}
	
	private func processInputQueue() {
		
		if !emulator.inputMap.up.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(0), emulator.inputMap.up.remove(at: 0))
		}
		
		if !emulator.inputMap.down.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(1), emulator.inputMap.down.remove(at: 0))
		}
		
		if !emulator.inputMap.left.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(2), emulator.inputMap.left.remove(at: 0))
		}
		
		if !emulator.inputMap.right.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(3), emulator.inputMap.right.remove(at: 0))
		}
		
		if !emulator.inputMap.a.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(4), emulator.inputMap.a.remove(at: 0))
		}
		
		if !emulator.inputMap.b.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(5), emulator.inputMap.b.remove(at: 0))
		}
		
		if !emulator.inputMap.mode.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(6), emulator.inputMap.mode.remove(at: 0))
		}
		
		if !emulator.inputMap.sleep.isEmpty {
			gyVmuButtonStateSet(emulator.device, .init(7), emulator.inputMap.sleep.remove(at: 0))
		}
	}
}
