//
//  EmulatorRenderer.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2020-02-21.
//  Copyright © 2020 es. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit

class EmulatorRenderer: NSObject, SKSceneDelegate {
	let screenScalar: Int = 3
	var contextSize: CGSize = .zero
	let screen: WKInterfaceSKScene
	let emulator: Emulator
	
	init(screen: WKInterfaceSKScene, emulator: Emulator) {
		self.screen = screen
		self.emulator = emulator
		super.init()
		guard screen.scene == nil else { return }
		updateScreenSize()
		let scene = SKScene(size: self.contextSize)
		scene.blendMode = .replace
		generatePixels(for: scene)
		scene.delegate = self
		screen.presentScene(scene)
	}
	
	private func generatePixels(for scene: SKScene) {
		for y in (0..<VMU_DISP_PIXEL_HEIGHT) {
			for x in (0..<VMU_DISP_PIXEL_WIDTH) {
				let point = CGPoint(x: Int(x)*screenScalar, y: Int(contextSize.height) - (Int(y)*screenScalar))
				let rect = CGRect(origin: point, size: CGSize(width: screenScalar, height: screenScalar))
				let pixel = SKShapeNode(rect: rect)
				pixel.blendMode = .screen
				pixel.strokeColor = .clear
				scene.addChild(pixel)
			}
		}
	}
	
	func generateScreenshot() -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(CGSize(width: Int(VMU_DISP_PIXEL_WIDTH), height: Int(VMU_DISP_PIXEL_HEIGHT)), true, 0)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		for y in (0..<VMU_DISP_PIXEL_HEIGHT) {
			for x in (0..<VMU_DISP_PIXEL_WIDTH) {
				let pixel = gyVmuDisplayPixelGhostValue(emulator.device, x, y)
				let color = UIColor.init(red: CGFloat(pixel)/255.0, green: CGFloat(pixel)/255.0, blue: CGFloat(pixel)/255.0, alpha: 1).cgColor
				let rect = CGRect(x: Int(x), y: Int(y), width: 1, height: 1)
				context.setFillColor(color)
				context.fill(rect)
			}
		}
		let screenShot = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return screenShot
	}
	
	private func updateScreenSize() {
		self.contextSize = CGSize(width: Int(VMU_DISP_PIXEL_WIDTH)*screenScalar, height: Int(VMU_DISP_PIXEL_HEIGHT-1)*screenScalar)
		self.screen.setWidth(contextSize.width)
		self.screen.setHeight(contextSize.height)
	}
	
	func update(_ currentTime: TimeInterval, for scene: SKScene) {
		// Process input queue
		emulator.processInputQueue()
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
			let x = Int(pixel.frame.origin.x) / screenScalar
			let y = (Int(contextSize.height - pixel.frame.origin.y)) / screenScalar
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
}
