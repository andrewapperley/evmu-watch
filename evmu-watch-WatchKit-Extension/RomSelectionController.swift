//
//  RomSelectionController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-07-18.
//  Copyright © 2019 es. All rights reserved.
//

import WatchKit

protocol RomSelectionControllerDelegate: class {
	func didSelectRom(at path: String)
}

class RomTableRowController: NSObject {
	weak var delegate: RomSelectionControllerDelegate? = nil
	@IBOutlet weak var nameButton: WKInterfaceButton!
	var path: String!
	@IBAction func didSelectRom() {
		delegate?.didSelectRom(at: path)
	}
}

class RomSelectionController: WKInterfaceController {
	
	@IBOutlet weak var romList: WKInterfaceTable!
	weak var delegate: EmulatorDelegate? = nil
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		self.delegate = context as? EmulatorDelegate
	}
	
	override func willActivate() {
		super.willActivate()
		let dci = Bundle.main.paths(forResourcesOfType: "dci", inDirectory: nil)
		let vms = Bundle.main.paths(forResourcesOfType: "vms", inDirectory: nil)
		let paths = dci + vms.removeVMSWithoutVMI()
		
		romList.setNumberOfRows(paths.count, withRowType: "RomTableRowController")
		
		for (index, path) in paths.enumerated() {
			let url = URL(fileURLWithPath: path, isDirectory: false, relativeTo: nil)
			let filename = url.pathComponents.last!.replacingOccurrences(of: "."+url.pathExtension, with: "")
			let row = romList.rowController(at: index) as! RomTableRowController
			row.nameButton.setTitle(filename)
			row.path = path
			row.delegate = self
		}
	}
}

extension RomSelectionController: RomSelectionControllerDelegate {
	func didSelectRom(at path: String) {
		delegate?.didSelectRom(path: path)
		dismiss()
	}
}

extension Array where Element == String {
	func removeVMSWithoutVMI() -> [String] {
		let vmi = Bundle.main.paths(forResourcesOfType: "vmi", inDirectory: nil)
		return self.filter({ (vmsPath) -> Bool in
			let url = URL(fileURLWithPath: vmsPath, isDirectory: false, relativeTo: nil)
			let vmsFileName = url.pathComponents.last!.replacingOccurrences(of: "vms", with: "vmi")
			var found = false
			for vmiPath in vmi {
				let url = URL(fileURLWithPath: vmiPath, isDirectory: false, relativeTo: nil)
				let vmiFileName = url.pathComponents.last!
				if vmiFileName == vmsFileName {
					found = false
					break
				}
			}
			
			return found
		})
	}
}
