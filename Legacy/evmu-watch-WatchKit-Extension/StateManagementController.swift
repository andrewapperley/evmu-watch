//
//  StateManagementController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2020-02-13.
//  Copyright © 2020 es. All rights reserved.
//

import WatchKit

protocol StateManagementControllerDelegate: class {
	func didLoadSlot(slot: Int, path: String?)
	func didSaveState()
}

enum StateSlotType {
	case Save
	case Load
}

class StateManagementTableRowController: NSObject {
	weak var delegate: StateManagementControllerDelegate? = nil
	@IBOutlet weak var screenshotImage: WKInterfaceImage!
	@IBOutlet weak var loadButton: WKInterfaceButton!
	@IBOutlet weak var dateLabel: WKInterfaceLabel!
	var slot: Int!
	var path: String?
	@IBAction func didSelectSlot() {
		delegate?.didLoadSlot(slot: slot, path: path)
	}
}

struct StateManagementConstants {
	static let SaveSelected = "SaveSelected"
	static let LoadSelected = "LoadSelected"
	static let SlotsAvailable = 3
	static let StateDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("states", isDirectory: true)
	static let StateScreenshotQuality = 50.0
}

class StateManagementController: WKInterfaceController {
	@IBOutlet weak var saveStateButton: WKInterfaceButton!
	@IBOutlet weak var loadSlotList: WKInterfaceTable!
	weak var delegate: EmulatorDelegate? = nil
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		self.delegate = context as? EmulatorDelegate
		try! FileManager.default.createDirectory(at: StateManagementConstants.StateDirectory, withIntermediateDirectories: true, attributes: nil)
	}
	
	override func willActivate() {
		super.willActivate()
		guard let appName = delegate?.currentAppName else { return }
		guard let statesInDirectory = try? FileManager.default.contentsOfDirectory(at: StateManagementConstants.StateDirectory, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else { return }
		
		var statesAvailable: Dictionary<String, (state: String?, screenshot: URL?)> = [:]
		
		statesInDirectory.filter({ (url) -> Bool in
			let slotStrippedOut = url.lastPathComponent.split(separator: "|").first!
			return slotStrippedOut == appName
		}).forEach { url in
			let keyName = url.lastPathComponent.replacingOccurrences(of: ".jpg", with: "")
			if statesAvailable[keyName] == nil {
				statesAvailable[keyName] = (state: nil, screenshot: nil)
			}
			if url.lastPathComponent.contains(".jpg") {
				statesAvailable[keyName]?.screenshot = url
			} else {
				statesAvailable[keyName]?.state = url.path
			}
		}
		
		loadSlotList.setNumberOfRows(statesAvailable.count, withRowType: "StateManagementTableRowController")
		
		for (index, state) in statesAvailable.enumerated() {
			let row = loadSlotList.rowController(at: index) as! StateManagementTableRowController
			row.slot = index
			row.path = state.value.state
			if let extractedDate = state.value.state?.split(separator: "|").last, let formattedDate = generateStateSaveDate(dateText: String(extractedDate)) {
				row.dateLabel.setText(formattedDate)
			}
			
			row.screenshotImage.setImage(UIImage(contentsOfFile: state.value.screenshot!.path)!)
			row.delegate = self
		}
	}
	
	private func generateStateSaveDate(dateText: String?) -> String? {
		guard let dateText = dateText, let timeInterval = TimeInterval(dateText) else { return nil }
		let date = Date(timeIntervalSince1970: timeInterval)
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}
}

extension StateManagementController: StateManagementControllerDelegate {
	@IBAction func didSaveState() {
		let path: String
		guard
			let appName = delegate?.currentAppName,
			let screenshot = delegate?.currentScreenshot else { return }
		path = "\(appName)|\(Date().timeIntervalSince1970)"
		let data = Data()
		
		do {
			try data.write(to: StateManagementConstants.StateDirectory.appendingPathComponent(path))
			try screenshot.jpegData(compressionQuality: 50.0)?.write(to: StateManagementConstants.StateDirectory.appendingPathComponent(path+".jpg"))
			delegate?.didSelectSaveStateSlot(path: StateManagementConstants.StateDirectory.appendingPathComponent(path).path)
		} catch {}
		dismiss()
	}
	func didLoadSlot(slot: Int, path: String?) {
		guard let path = path else { return }
		delegate?.didSelectLoadStateSlot(path: path)
		dismiss()
	}
}
