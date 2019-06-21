//
//  InterfaceController.swift
//  evmu-watch WatchKit Extension
//
//  Created by Andrew Apperley on 2019-06-15.
//  Copyright © 2019 es. All rights reserved.
//

import WatchKit
import Foundation
import UIKit


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
//		let device = gyVmuDeviceCreate()
		testAssetLoading()
		guard let vmsBundleURL = Bundle.main.url(forResource: "minigame", withExtension: "VMS") else {return}
//		guard let vmiBundleURL = Bundle.main.url(forResource: "minigame", withExtension: "VMI") else {return}
		
//		let vmsExists = FileManager.default.fileExists(atPath: vmsBundleURL.absoluteString)
//		let vmiExists = FileManager.default.fileExists(atPath: vmiBundleURL.absoluteString)
//		var fileSize: Int = 0
//		var fileSizePointer = UnsafeMutablePointer<Int>?(&fileSize)
//		var pathPointer = UnsafePointer<Int8>(vmsBundleURL.absoluteString)
//		var status: VMU_LOAD_IMAGE_STATUS! = VMU_LOAD_IMAGE_STATUS(rawValue: 0)
//		let dir = gyVmuFlashLoadVMS(pathPointer, fileSizePointer)
//
//		while(true) {
//			gyVmuDeviceUpdate(device, 1)
//			for (i, h) in (0..<VMU_DISP_PIXEL_HEIGHT).enumerated() {
//				for (ii, w) in (0..<VMU_DISP_PIXEL_WIDTH).enumerated() {
//					if(gyVmuDisplayPixelGet(device, w, h) > 0) {
//						print("black pixel")
//					} else {
//						print("white pixel")
//					}
//				}
//			}
//		}
//		gyVmuDeviceDestroy(device)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	func testAssetLoading() {
		guard let vmsBundleURL = Bundle.main.url(forResource: "minigame", withExtension: "VMS") else {return}
	}
	
}
//
//UIGraphicsBeginImageContextWithOptions(CGSize(width: WIDTH, height: HEIGHT), true, 1.5)
//guard let context = UIGraphicsGetCurrentContext() else {return}
//for (i, data) in vram.enumerated() {
//	let colour: UIColor = data <= 0 ? .black : .white
//	let x = i % Int(WIDTH)
//	let y = (i - x) / Int(WIDTH)
//	let rect = CGRect(x: x, y: y , width: 1, height: 1)
//	context.setFillColor(colour.cgColor)
//	context.fill(rect)
//}
//(self.screen.subviews[0] as! UIImageView).image = UIGraphicsGetImageFromCurrentImageContext()
//UIGraphicsEndImageContext()
