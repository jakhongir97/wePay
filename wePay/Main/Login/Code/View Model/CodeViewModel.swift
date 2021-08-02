//
//  CodeViewModel.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit
import FirebaseAuth

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
    internal func confirm(verificationID: String,verificationCode: String) {
        delegate?.showActivityIndicator()
        
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            
            self.delegate?.hideActivityIndicator()
            
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
                return
            }
            
            self.delegate?.didFinishFetch()
        }
    }
}
