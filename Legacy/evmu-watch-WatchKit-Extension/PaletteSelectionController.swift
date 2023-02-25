//
//  PaletteSelectionController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-09-23.
//  Copyright © 2019 es. All rights reserved.
//

import WatchKit

protocol PaletteSelectionControllerDelegate: class {
	func didSelectPalette(palette: Palette)
}

class PaletteTableRowController: NSObject {
	weak var delegate: PaletteSelectionControllerDelegate? = nil
	@IBOutlet weak var colorButton: WKInterfaceButton!
	var palette: Palette!
	@IBAction func didSelectPalette() {
		delegate?.didSelectPalette(palette: palette)
	}
}

typealias Palette = (title: String, color: CGColor)

let Palletes: [Palette] = [
	(title: "None", color: UIColor.black.cgColor),
	(title: "Red", color: UIColor.red.cgColor),
	(title: "Green", color: UIColor.green.cgColor),
	(title: "Magenta", color: UIColor.magenta.cgColor),
	(title: "Brown", color: UIColor.brown.cgColor),
	(title: "Blue", color: UIColor.blue.cgColor),
	(title: "Cyan", color: UIColor.cyan.cgColor),
	(title: "Orange", color: UIColor.orange.cgColor)
]

struct PaletteSelectionConstants {
	static let PaletteSelected = "PaletteSelected"
}

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
			row.palette = palette
			row.delegate = self
		}
	}
}

extension PaletteSelectionController: PaletteSelectionControllerDelegate {
	func didSelectPalette(palette: Palette) {
		UserDefaults.standard.set(palette.title, forKey: PaletteSelectionConstants.PaletteSelected)
		UserDefaults.standard.synchronize()
		delegate?.didSelectPalette(color: palette.color)
		dismiss()
	}
}

extension UserDefaults {
	static func getPalette() -> CGColor {
		let name = UserDefaults.standard.string(forKey: PaletteSelectionConstants.PaletteSelected)
		let color = Palletes.first { return $0.title == name! }
		return color?.color ?? UIColor.black.cgColor
	}
}
