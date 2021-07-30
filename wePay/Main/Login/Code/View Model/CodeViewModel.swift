//
//  CodeViewModel.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit

protocol CodeViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class CodeViewModel {
    
    // MARK: - Attributes
    weak var delegate: CodeViewModelProtocol?
    
    lazy var applicationVersion: String = {
        guard let releaseVersionNumber = Bundle.main.releaseVersionNumber else { return "0" }
        return releaseVersionNumber.replacingOccurrences(of: ".", with: "")
    }()
    
    // MARK: - Network call
}
