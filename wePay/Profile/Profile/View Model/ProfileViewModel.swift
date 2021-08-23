//
//  ProfileViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit

protocol ProfileViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
    func didFinishFetch(user: User)
    func didFinishFetchUpload(url: String)
}

final class ProfileViewModel {
    // MARK: - Attributes
    weak var delegate: ProfileViewModelProtocol?

    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()

    // MARK: - Network call
    internal func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }

        delegate?.didFinishFetch()
    }

    internal func uploadUserPicture(with data: Data, fileName: String) {
        storageRef.child("images/\(fileName)").putData(data, metadata: StorageMetadata()) { _, error in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }

            self.storageRef.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    self.delegate?.showAlertClosure(error: (APIError.fromMessage, "Failed to get download url"))
                    return
                }
                self.updateUser(imageURL: url.absoluteString)
                self.delegate?.didFinishFetchUpload(url: url.absoluteString)
            }
        }
    }

    internal func updateUser(firstName: String) {
        guard let user = Auth.auth().currentUser else { return }
        self.ref.child("users/\(user.uid)/firstName").setValue(firstName)
        self.ref.child("users/\(user.uid)/isModified").setValue(true)
    }

    internal func updateUser(lastName: String) {
        guard let user = Auth.auth().currentUser else { return }
        self.ref.child("users/\(user.uid)/lastName").setValue(lastName)
        self.ref.child("users/\(user.uid)/isModified").setValue(true)
    }

    internal func updateUser(imageURL: String?) {
        guard let user = Auth.auth().currentUser else { return }
        self.ref.child("users/\(user.uid)/imageURL").setValue(imageURL)
    }

    internal func getUserInfo() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String, let phone = value?["phone"] as? String {
                self.delegate?.didFinishFetch(user: User(userID: snapshot.key, firstName: firstName, lastName: lastName, telephone: phone, imageURL: value?["imageURL"] as? String))
            }
        }) { error in
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
}
