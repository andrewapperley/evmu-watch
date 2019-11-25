//
//  PaletteSelectionController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-09-23.
//  Copyright © 2019 es. All rights reserved.
//

import WatchKit

protocol PaletteSelectionControllerDelegate: class {
	func didSelectPalette(color: CGColor)
}

class PaletteTableRowController: NSObject {
	weak var delegate: PaletteSelectionControllerDelegate? = nil
	@IBOutlet weak var colorButton: WKInterfaceButton!
	var color: CGColor!
	@IBAction func didSelectPalette() {
		delegate?.didSelectPalette(color: color)
	}
}

let Palletes = [
	(title: "None", color: UIColor.black.cgColor),
	(title: "Red", color: UIColor.red.cgColor),
	(title: "Yellow", color: UIColor.yellow.cgColor),
	(title: "Green", color: UIColor.green.cgColor),
	(title: "Magenta", color: UIColor.magenta.cgColor),
	(title: "Brown", color: UIColor.brown.cgColor),
	(title: "Blue", color: UIColor.blue.cgColor),
	(title: "Cyan", color: UIColor.cyan.cgColor),
	(title: "Orange", color: UIColor.orange.cgColor)
]

class PaletteSelectionController: WKInterfaceController {
	
	@IBOutlet weak var colorList: WKInterfaceTable!
	weak var delegate: EmulatorDelegate? = nil
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		self.delegate = context as? EmulatorDelegate
	}
	
	override func willActivate() {
		super.willActivate()
		
		colorList.setNumberOfRows(Palletes.count, withRowType: "PaletteTableRowController")
		
		for (index, palette) in Palletes.enumerated() {
			let row = colorList.rowController(at: index) as! PaletteTableRowController
			row.colorButton.setTitle(palette.title)
			row.color = palette.color
			row.delegate = self
		}
	}
}

extension PaletteSelectionController: PaletteSelectionControllerDelegate {
	func didSelectPalette(color: CGColor) {
		delegate?.didSelectPalette(color: color)
		dismiss()
	}
}
