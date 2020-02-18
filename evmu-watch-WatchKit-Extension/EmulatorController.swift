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

class EmulatorController: WKInterfaceController {
	let emulator = Emulator()
	@IBOutlet weak var screen: WKInterfaceSKScene!
	var contextSize: CGSize = .zero
	
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
		updateScreenSize()
		let scene = SKScene(size: self.contextSize)
		scene.blendMode = .replace
		generatePixels(for: scene)
		scene.delegate = self
		screen.presentScene(scene)
	}
	
	@IBAction func showSettings() {
		presentController(withName: "EmulatorSettingsController", context: self)
	}
	
	@IBAction func showRomSelectionView() {
		presentController(withName: "RomSelectionController", context: self)
	}
	
	@IBAction func showPaletteSelectionView() {
		presentController(withName: "PaletteSelectionController", context: self)
	}
	
	@IBAction func showStateManagementView() {
		presentController(withName: "StateManagementController", context: self)
	}
	
	@IBAction func onUpTapped() {
		emulator.updateInputMap(input: .up)
		finishedInput()
	}
	
	@IBAction func onDownTapped() {
		emulator.updateInputMap(input: .down)
		finishedInput()
	}
	
	@IBAction func onLeftTapped() {
		emulator.updateInputMap(input: .left)
		finishedInput()
	}
	
	@IBAction func onRightTapped() {
		emulator.updateInputMap(input: .right)
		finishedInput()
	}
	
	@IBAction func onATapped() {
		emulator.updateInputMap(input: .a)
		finishedInput()
	}
	
	@IBAction func onBTapped() {
		emulator.updateInputMap(input: .b)
		finishedInput()
	}
	
	@IBAction func onSleepAndModeTapped(_ sender: WKPanGestureRecognizer) {
		let x = sender.velocityInObject().x
		switch sender.state {
//		Left is Mode
//		Right is Sleep
		case .began:
			if x > 0 {
				emulator.updateInputMap(input: .sleep, finished: false)
			} else {
				emulator.updateInputMap(input: .mode, finished: false)
			}
		case .ended, .cancelled, .failed:
			if x > 0 {
				emulator.updateInputMap(input: .sleep)
			} else {
				emulator.updateInputMap(input: .mode)
			}
			finishedInput()
		default:
			break
		}
	}
	
	private func finishedInput() {
		WKInterfaceDevice.current().play(.click)
	}
	
	private func generatePixels(for scene: SKScene) {
		for y in (0..<VMU_DISP_PIXEL_HEIGHT) {
			for x in (0..<VMU_DISP_PIXEL_WIDTH) {
				let point = CGPoint(x: Int(x)*emulator.screenScalar, y: Int(contextSize.height) - (Int(y)*emulator.screenScalar))
				let rect = CGRect(origin: point, size: CGSize(width: emulator.screenScalar, height: emulator.screenScalar))
				let pixel = SKShapeNode(rect: rect)
				pixel.blendMode = .screen
				pixel.strokeColor = .clear
				scene.addChild(pixel)
			}
		}
	}
	
	private func updateScreenSize() {
		self.contextSize = CGSize(width: Int(VMU_DISP_PIXEL_WIDTH)*emulator.screenScalar, height: Int(VMU_DISP_PIXEL_HEIGHT-1)*emulator.screenScalar)
		self.screen.setWidth(contextSize.width)
		self.screen.setHeight(contextSize.height)
	}
}

extension EmulatorController: EmulatorDelegate {
	var currentAppName: String? {
		guard let appPath = emulator.currentRomPath else { return nil }
		let parts = appPath.split(separator: "/")
		guard let fileName = parts.last,
			let appName = fileName.split(separator: ".").first else { return nil }
		return String(appName.replacingOccurrences(of: " ", with: "-"))
	}
	
	func didUpdateSettings() {
		emulator.updateSettings()
	}
	
	func didSelectPalette(color: CGColor) {
		emulator.paletteColor = color
		screen.scene!.backgroundColor = UIColor(cgColor: emulator.paletteColor)
	}
	
	func didSelectRom(path: String) {
		emulator.loadRom(at: path)
	}
	
	func didSelectSaveStateSlot(path: String) {
		emulator.saveState(at: path)
	}
	
	func didSelectLoadStateSlot(path: String) {
		emulator.loadState(at: path)
	}
}

extension EmulatorController: SKSceneDelegate {
	func update(_ currentTime: TimeInterval, for scene: SKScene) {
		// Process input queue
		processInputQueue()
		var updatedFB = false
		if gyVmuDisplayEnabled(emulator.device) == 0 {
			updatedFB = drawScreensaver(scene)
		} else if (gyVmuDisplayUpdateEnabled(emulator.device) == 1) && emulator.currentRomPath != nil {
			// Draw new frame
			updatedFB = drawFrame(scene, currentTime)
		}
		if updatedFB {}
	}
	
	func didFinishUpdate(for scene: SKScene) {
		
	}
	
	private func drawFrame(_ scene: SKScene, _ time: TimeInterval) -> Bool {
		if emulator.updateTime == 0.0 { emulator.updateTime = time }
		let deltaTime: Float = Float(min(time - emulator.updateTime, 1.0))
		emulator.updateTime = time
		
		guard gyVmuDeviceUpdate(emulator.device, deltaTime) == 1 else { return false }
		for pixel in scene.children {
			let x = Int(pixel.frame.origin.x) / emulator.screenScalar
			let y = (Int(contextSize.height - pixel.frame.origin.y)) / emulator.screenScalar
			let pixelValue = gyVmuDisplayPixelGhostValue(emulator.device, Int32(x), Int32(y))
			let color = UIColor.init(red: CGFloat(pixelValue)/255.0, green: CGFloat(pixelValue)/255.0, blue: CGFloat(pixelValue)/255.0, alpha: 0.9)
			(pixel as? SKShapeNode)?.fillColor = color
		}
		
		return true
	}
	
	private func drawScreensaver(_ scene: SKScene) -> Bool {
		guard
			let dirEntry = gyVmuFlashDirEntryGame(emulator.device),
			let vmsHeader = gyVmuFlashDirEntryVmsHeader(emulator.device, dirEntry)?.pointee,
			let data = gyVmuVMSFileInfoCreateIconsARGB444(emulator.device, dirEntry)
		else { return false }

		for i in stride(from: 0, through: vmsHeader.iconCount, by: 1) {

		}
		
		return true
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
