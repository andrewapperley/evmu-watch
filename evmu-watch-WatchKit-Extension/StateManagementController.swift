//
//  StateManagementController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2020-02-13.
//  Copyright © 2020 es. All rights reserved.
//

import WatchKit

protocol StateManagementControllerDelegate: class {
	func didSelectSlot(slot: Int, for: StateSlotType, path: String?)
}

enum StateSlotType {
	case Save
	case Load
}

class StateManagementTableRowController: NSObject {
	weak var delegate: StateManagementControllerDelegate? = nil
	@IBOutlet weak var slotButton: WKInterfaceButton!
	var slot: Int!
	var type: StateSlotType!
	var path: String?
	@IBAction func didSelectSlot() {
		delegate?.didSelectSlot(slot: slot, for: type, path: path)
	}
}

struct StateManagementConstants {
	static let SaveSelected = "SaveSelected"
	static let LoadSelected = "LoadSelected"
	static let SlotsAvailable = 3
	static let stateDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("states", isDirectory: true)
}

class StateManagementController: WKInterfaceController {
	@IBOutlet weak var saveSlotList: WKInterfaceTable!
	@IBOutlet weak var loadSlotList: WKInterfaceTable!
	weak var delegate: EmulatorDelegate? = nil
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		self.delegate = context as? EmulatorDelegate
		try! FileManager.default.createDirectory(at: StateManagementConstants.stateDirectory, withIntermediateDirectories: true, attributes: nil)
	}
	
	override func willActivate() {
		super.willActivate()
		guard let appName = delegate?.currentAppName else { return }
		let statesAvailable = try! FileManager.default.contentsOfDirectory(at: StateManagementConstants.stateDirectory, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants).filter({ (url) -> Bool in
			let slotStrippedOut = url.lastPathComponent.split(separator: "|").first!
			return slotStrippedOut == appName
		})
		
		saveSlotList.setNumberOfRows(StateManagementConstants.SlotsAvailable, withRowType: "StateManagementTableRowController")
		loadSlotList.setNumberOfRows(StateManagementConstants.SlotsAvailable, withRowType: "StateManagementTableRowController")
		
		for index in 0..<StateManagementConstants.SlotsAvailable {
			let row = saveSlotList.rowController(at: index) as! StateManagementTableRowController
			row.slotButton.setTitle("Slot \(index)")
			row.slot = index
			row.type = .Save
			row.delegate = self
		}
		
		for (index, state) in statesAvailable.enumerated() {
			let row = loadSlotList.rowController(at: index) as! StateManagementTableRowController
			row.slotButton.setTitle("Slot \(index)")
			row.slot = index
			row.type = .Load
			row.path = state.path
			row.delegate = self
		}
	}
}

extension StateManagementController: StateManagementControllerDelegate {
	func didSelectSlot(slot: Int, for: StateSlotType, path: String?) {
		switch `for` {
			case .Load:
				guard let path = path else {
					return
				}
				delegate?.didSelectLoadStateSlot(path: path)
				break
			case .Save:
				let path: String
				guard let appName = delegate?.currentAppName else { return }
				path = "\(appName)|\(slot).sav"
				let data = Data()
				
				do {
					if !FileManager.default.fileExists(atPath: StateManagementConstants.stateDirectory.appendingPathComponent(path).path) {
						try data.write(to: StateManagementConstants.stateDirectory.appendingPathComponent(path))
					}
					delegate?.didSelectSaveStateSlot(path: StateManagementConstants.stateDirectory.appendingPathComponent(path).path)
				} catch {}
				break
		}
		dismiss()
	}
}
