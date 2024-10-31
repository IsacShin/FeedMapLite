//
//  Defines.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import Foundation
import UIKit
import SwiftUI

let GMAP_KEY = "AIzaSyAFYYYgXJeT6SCOji_uSpTSP2ckkxOLLns"

// MARK: - SCREEN 관련
let WINDOW                  = UIApplication.getKeyWindow()
let SCREEN_WIDTH            = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT           = UIScreen.main.bounds.size.height

// MARK: - UI 관련
let LIGHT_COLOR = Color.white
let DARK_COLOR = Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1))

// MARK: - Device 관련
let DEVICE                  = UIDevice.current
let APP_VER                 = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
let DEVICE_TYPE             = "IOS"
let DEVICE_MODEL            = "\(DEVICE.model)\(DEVICE.name)"
let DEVICE_ID               = UIDevice.current.identifierForVendor?.uuidString
let APP_ID                  = Bundle.main.bundleIdentifier ?? "com.isac.myreview"
let DEVICE_VERSION          = "\(DEVICE.systemVersion)"
let APP_NAME                = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""

// MARK: - Shortcut
/// UserDefaults.standard
let UDF = UserDefaults.standard
