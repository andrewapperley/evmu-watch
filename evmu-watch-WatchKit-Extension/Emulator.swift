//
//  Emulator.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2020-02-13.
//  Copyright © 2020 es. All rights reserved.
//

import Foundation
import CoreGraphics

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
	func didSelectPalette(color: CGColor)
	func didUpdateSettings()
	func didSelectSaveStateSlot(path: String)
	func didSelectLoadStateSlot(path: String)
}

protocol InputHandling {
	func updateInputMap(input: InputMap.Inputs, finished: Bool)
}

protocol StateManagement {
	func saveState(at path: String)
	func loadState(at path: String)
}

class Emulator {
	let screenScalar: Int = 3
	var paletteColor: CGColor = UserDefaults.getPalette()
	var inputMap = InputMap()
	var currentRomPath: String? = nil
	let device = gyVmuDeviceCreate()
	var updateTime: TimeInterval = 0
	
	init() {
		updateSettings()
	}
	
	func updateSettings() {
		let ghosting: Int32 = UserDefaults.standard.bool(forKey: SettingsConstants.PixelGhosting) ? 1 : 0
		gyVmuDisplayGhostingEnabledSet(device, ghosting)
		
		let lowPower: Int32 = UserDefaults.standard.bool(forKey: SettingsConstants.LowPowerMode) ? 1 : 0
		gyVmuBatteryLowSet(device, lowPower)
		gyVmuBatteryMonitorEnabledSet(device, lowPower)
	}
	
	func loadRom(at path: String) {
		if let game = gyVmuFlashDirEntryGame(device) {
			gyVmuFlashFileDelete(device, game)
		}
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

extension Emulator: StateManagement {
	func saveState(at path: String) {
		gyVmuDeviceSaveState(device, path)
	}
	
	func loadState(at path: String) {
		gyVmuDeviceLoadState(device, path)
	}
}
