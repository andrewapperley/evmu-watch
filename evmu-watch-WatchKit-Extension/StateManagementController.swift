//
//  StateManagementController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2020-02-13.
//  Copyright © 2020 es. All rights reserved.
//

import WatchKit

protocol StateManagementControllerDelegate: class {
	func didSelectSlot(slot: Int, for: StateSlotType)
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
	@IBAction func didSelectSlot() {
		delegate?.didSelectSlot(slot: slot, for: type)
	}
}

struct StateManagementConstants {
	static let SaveSelected = "SaveSelected"
	static let LoadSelected = "LoadSelected"
	static let SlotsAvailable = 3
}

class StateManagementController: WKInterfaceController {

	@IBOutlet weak var saveSlotList: WKInterfaceTable!
	@IBOutlet weak var loadSlotList: WKInterfaceTable!
	weak var delegate: EmulatorDelegate? = nil
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		self.delegate = context as? EmulatorDelegate
	}
	
	override func willActivate() {
		super.willActivate()
		
		saveSlotList.setNumberOfRows(StateManagementConstants.SlotsAvailable, withRowType: "StateManagementTableRowController")
		loadSlotList.setNumberOfRows(StateManagementConstants.SlotsAvailable, withRowType: "StateManagementTableRowController")
		
		for index in 0..<StateManagementConstants.SlotsAvailable {
			let row = saveSlotList.rowController(at: index) as! StateManagementTableRowController
			row.slotButton.setTitle("Slot \(index)")
			row.slot = index
			row.type = .Save
			row.delegate = self
		}
	}
}

extension StateManagementController: StateManagementControllerDelegate {
	func didSelectSlot(slot: Int, for: StateSlotType) {
		let path: String
		switch `for` {
		case .Load:
			path = ""
			delegate?.didSelectLoadStateSlot(path: path)
			break
		case .Save:
			path = ""
			delegate?.didSelectSaveStateSlot(path: path)
			break
		}
	}
}
