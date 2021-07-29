//
//  Localizable.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 12/03/21.
//

import UIKit

class LocalizationManager: NSObject {
    
    static let shared = LocalizationManager()
    
    var currentLocalizationBundle = Bundle()
    
    override init() {
        super.init()
        getCurrentBundle()
    }
    
    func getCurrentBundle() {
        if let bundleStr = Bundle.main.path(forResource: UserDefaults.standard.getLocalization(), ofType: "lproj"),
            let bundle = Bundle(path: bundleStr) {
            self.currentLocalizationBundle = bundle
        }
    }
    
    func setLocale(_ language: String){
        UserDefaults.standard.saveLocalization(lang: language)
        getCurrentBundle()
    }
    
    func getLocale() -> String {
        return UserDefaults.standard.getLocalization()
    }
    
}

protocol Localizable {
    var localized: String { get }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension String : Localizable {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: LocalizationManager.shared.currentLocalizationBundle, value: "", comment: "")
    }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
   }
}
extension UITextField: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
   }
}
