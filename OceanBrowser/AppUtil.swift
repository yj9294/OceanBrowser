//
//  AppUtil.swift
//  OceanBrowser
//
//  Created by yangjian on 2023/4/18.
//

import Foundation
import UIKit

var enterbackground = false
var window: UIWindow = UIWindow()
var width = window.bounds.width
var height = window.bounds.height
var rootVC: RootVC? = nil

extension String {
    
    var isUrl: Bool {
        let url = "[a-zA-z]+://.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
    
}

class AssetorKey {
    static var cornerRadiusKey: String?
    static var borderColorKey: String?
    static var borderWidthKey: String?
    static var placeholderColorKey: String?
}

extension UIViewController {
    
    func alert(_ message: String? = nil) {
        guard let message = message else {return}
        let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        self.present(vc, animated: true)
        Task{
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                vc.dismiss(animated: true)
            }
        }
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: Double {
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
            objc_setAssociatedObject(self, &AssetorKey.cornerRadiusKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &AssetorKey.cornerRadiusKey) as? Double) ?? 0.0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
            objc_setAssociatedObject(self, &AssetorKey.borderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &AssetorKey.borderColorKey) as? UIColor) ?? .clear
        }
    }
    
    @IBInspectable var borderWidth: Double {
        set {
            self.layer.borderWidth = newValue
            objc_setAssociatedObject(self, &AssetorKey.borderWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &AssetorKey.borderWidthKey) as? Double) ?? 0.0
        }
    }
    
}


extension UITextField {
    
    @IBInspectable var placeholderColor: UIColor {
        set {
            if let placeholder = placeholder {
                let attribute = NSMutableAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: newValue])
                self.attributedPlaceholder = attribute
            }
            objc_setAssociatedObject(self, &AssetorKey.placeholderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &AssetorKey.placeholderColorKey) as? UIColor) ?? UIColor.clear
        }
    }
    
}
