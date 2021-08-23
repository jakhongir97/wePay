//
//  Bundle.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
