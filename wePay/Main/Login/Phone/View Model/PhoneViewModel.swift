//
//  PhoneViewModel.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit
import FirebaseAuth

protocol PhoneViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(verificationID: String)
}

final class PhoneViewModel {
    
    // MARK: - Attributes
    weak var delegate: PhoneViewModelProtocol?
    
    lazy var applicationVersion: String = {
        guard let releaseVersionNumber = Bundle.main.releaseVersionNumber else { return "0" }
        return releaseVersionNumber.replacingOccurrences(of: ".", with: "")
    }()
    
    // MARK: - Network call
    internal func auth(phone: String) {
        delegate?.showActivityIndicator()
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
                
                self.delegate?.hideActivityIndicator()
                
                if let error = error {
                    self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
                    return
                }
                guard let verificationID = verificationID else { return }
                self.delegate?.didFinishFetch(verificationID: verificationID)
            }
    }
}

