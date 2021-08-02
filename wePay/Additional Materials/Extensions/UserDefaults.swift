//
//  UserDefaults.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 22/12/20.
//

import Foundation

enum AppLanguage : String {
    case ru
    case uz
    case en
}

enum UserDefaultsKeys: String {
    case localization
    case verificationPhone
    case verificationID
}

extension UserDefaults {
    
    func getLocalization() -> String {
        return string(forKey: UserDefaultsKeys.localization.rawValue) ?? AppLanguage.en.rawValue
    }
    
    func saveLocalization(lang: String) {
        set(lang, forKey: UserDefaultsKeys.localization.rawValue)
    }
    
    func getPhone() -> String? {
        return string(forKey: UserDefaultsKeys.verificationPhone.rawValue)
    }
    
    func savePhone(verificationPhone: String) {
       set(verificationPhone, forKey: UserDefaultsKeys.verificationPhone.rawValue)
    }
    
    func removePhone() {
        set(nil, forKey: UserDefaultsKeys.verificationPhone.rawValue)
    }
    
    func isRegistered() -> Bool {
        return getPhone() != nil
    }
    
    func getID() -> String? {
        return string(forKey: UserDefaultsKeys.verificationID.rawValue)
    }
    
    func saveID(verificationID: String) {
       set(verificationID, forKey: UserDefaultsKeys.verificationID.rawValue)
    }
}

extension UserDefaults {
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
