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
	var renderer: EmulatorRenderer!
	@IBOutlet weak var screen: WKInterfaceSKScene!
	
	override func didAppear() {
		super.didAppear()
		if emulator.currentRomPath == nil {
			showRomSelectionView()
		}
	}
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		showRomSelectionView()
		self.renderer = EmulatorRenderer(screen: screen, emulator: emulator)
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
}

extension EmulatorController: EmulatorDelegate {
	var currentScreenshot: UIImage? {
		return renderer.generateScreenshot()
	}
	
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
