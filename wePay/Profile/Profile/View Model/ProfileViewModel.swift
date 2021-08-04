//
//  ProfileViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol ProfileViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
    func didFinishFetch(user: User)
}

final class ProfileViewModel {
    
    // MARK: - Attributes
    weak var delegate: ProfileViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
    internal func signOut() {
        
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
        
        delegate?.didFinishFetch()
    }
    
    internal func getUserInfo() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String, let phone = value?["phone"] as? String {
                self.delegate?.didFinishFetch(user: User(userID: snapshot.key, firstName: firstName, lastName: lastName, telephone: phone))
            }
        }) { error in
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
}
