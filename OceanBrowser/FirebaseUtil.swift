//
//  FirebaseUtil.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/19.
//

import Foundation
import Firebase

class FirebaseUtil: NSObject {
    static func log(event: AnaEvent, params: [String: Any]? = nil) {
        
        if event.first {
            if UserDefaults.standard.bool(forKey: event.rawValue) == true {
                return
            } else {
                UserDefaults.standard.set(true, forKey: event.rawValue)
            }
        }
        
        #if DEBUG
        #else
        Analytics.logEvent(event.rawValue, parameters: params)
        #endif
        
        NSLog("[Event] \(event.rawValue) \(params ?? [:])")
    }
    
    static func log(property: AnaProperty, value: String? = nil) {
        
        var value = value
        
        if property.first {
            if UserDefaults.standard.string(forKey: property.rawValue) != nil {
                value = UserDefaults.standard.string(forKey: property.rawValue)!
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: property.rawValue)
            }
        }
#if DEBUG
#else
        Analytics.setUserProperty(value, forName: property.rawValue)
#endif
        NSLog("[Property] \(property.rawValue) \(value ?? "")")
    }
}

enum AnaProperty: String {
    /// 設備
    case local = "ay_ocn"
    
    var first: Bool {
        switch self {
        case .local:
            return true
        }
    }
}

enum AnaEvent: String {
    
    var first: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }
    
    case open = "lun_ocn"
    case openCold = "er_ocn"
    case openHot = "ew_ocn"
    case homeShow = "eq_ocn"
    case clickSearch = "ws_ocn"
    case search = "wa_ocn"
    case cleanClick = "bu_ocn"
    case cleanSuccess = "xian_ocn"
    case cleanAlert = "dd_ocn"
    case tabShow = "dl_ocn"
    case browserNew = "acv_ocn"
    case shareClick = "xmo_ocn"
    case copyClick = "qws_ocn"
    case webStart = "zxc_ocn"
    case webSuccess = "bnm_ocn"
}
