//
//  ProfileViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import FirebaseAuth

protocol ProfileViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class ProfileViewModel {
    
    // MARK: - Attributes
    weak var delegate: ProfileViewModelProtocol?
    
    // MARK: - Network call
    internal func signOut() {
        
        delegate?.showActivityIndicator()
        
        do {
            try Auth.auth().signOut()
            self.delegate?.hideActivityIndicator()
            self.delegate?.didFinishFetch()
        } catch let error as NSError {
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
}
