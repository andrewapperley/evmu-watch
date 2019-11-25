//
//  EmulatorSettingsController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-07-18.
//  Copyright © 2019 es. All rights reserved.
//

import WatchKit

protocol SettingsControllerDelegate: class {
	func didUpdateSettings()
}

class SettingsTableRowController: NSObject {
	var setting: String!
	var current: Bool!
	@IBOutlet weak var settingButton: WKInterfaceButton!
	weak var delegate: SettingsControllerDelegate? = nil
	func updateButtonState() {
		settingButton.setBackgroundColor(current ? UIColor.lightGray : UIColor.darkGray)
	}
	@IBAction func didSelectSetting() {
		let new = !current
		UserDefaults.standard.set(new, forKey: setting)
		UserDefaults.standard.synchronize()
		current = new
		updateButtonState()
		delegate?.didUpdateSettings()
	}
}

struct SettingsConstants {
	static let LowPowerMode = "Low Power Mode"
	static let BilinearFiltering = "Bilinear Filtering"
	static let Audio = "Audio"
	static let PixelGhosting = "Pixel Ghosting"
}

private let Settings = [
	SettingsConstants.LowPowerMode,
	SettingsConstants.BilinearFiltering,
	SettingsConstants.Audio,
	SettingsConstants.PixelGhosting
]

class EmulatorSettingsController: WKInterfaceController {
	@IBOutlet weak var settingsList: WKInterfaceTable!
	
	weak var delegate: EmulatorDelegate? = nil
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		self.delegate = context as? EmulatorDelegate
	}
	
	override func willActivate() {
		super.willActivate()
		let defaults = UserDefaults.standard
		settingsList.setNumberOfRows(Settings.count, withRowType: "SettingsTableRowController")
		for (index, setting) in Settings.enumerated() {
			let row = settingsList.rowController(at: index) as! SettingsTableRowController
			row.current = defaults.bool(forKey: setting)
			row.setting = setting
			row.settingButton.setTitle(setting)
			row.updateButtonState()
			row.delegate = self
		}
	}
}

extension EmulatorSettingsController: SettingsControllerDelegate {
	func didUpdateSettings() {
		delegate?.didUpdateSettings()
	}
}
