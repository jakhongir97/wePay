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
}

enum UserDefaultsKeys: String {
    case localization
    case city
    case district
}

extension UserDefaults {
    
    func getLocalization() -> String {
        return string(forKey: UserDefaultsKeys.localization.rawValue) ?? AppLanguage.ru.rawValue
    }
    
    func saveLocalization(lang: String) {
        set(lang, forKey: UserDefaultsKeys.localization.rawValue)
    }
    
    func getCityID() -> Int {
        return integer(forKey: UserDefaultsKeys.city.rawValue)
    }
    
    func saveCity(cityID: Int) {
       set(cityID, forKey: UserDefaultsKeys.city.rawValue)
    }
    
    func getDistrictID() -> Int {
        return integer(forKey: UserDefaultsKeys.district.rawValue)
    }
    
    func saveDistrictID(districtID: Int) {
       set(districtID, forKey: UserDefaultsKeys.district.rawValue)
    }
}
