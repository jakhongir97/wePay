//
//  CodeViewModel.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import Contacts
import FirebaseAuth
import FirebaseDatabase
import UIKit

protocol CodeViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
    func didFinishFetch(contacts: [User])
}

final class CodeViewModel {
    // MARK: - Attributes
    weak var delegate: CodeViewModelProtocol?

    let ref = Database.database().reference()

    lazy var applicationVersion: String = {
        guard let releaseVersionNumber = Bundle.main.releaseVersionNumber else { return "0" }
        return releaseVersionNumber.replacingOccurrences(of: ".", with: "")
    }()

    // MARK: - Network call
    internal func confirm(verificationID: String, verificationCode: String) {
        delegate?.showActivityIndicator()

        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: verificationCode
        )

        Auth.auth().signIn(with: credential) { _, error in
            self.delegate?.hideActivityIndicator()

            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
                return
            }

            self.delegate?.didFinishFetch()
        }
    }

    internal func createUser(phone: String) {
        guard let user = Auth.auth().currentUser else { return }
        self.ref.child("users/\(user.uid)/phone").setValue(phone)
    }

    internal func updateUser(firstName: String) {
        guard let user = Auth.auth().currentUser else { return }
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if  value?["isModified"] as? Bool == nil {
                self.ref.child("users/\(user.uid)/firstName").setValue(firstName)
            }
        })
    }

    internal func updateUser(lastName: String) {
        guard let user = Auth.auth().currentUser else { return }
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if  value?["isModified"] as? Bool == nil {
                self.ref.child("users/\(user.uid)/lastName").setValue(lastName)
            }
        })
    }

    internal func fetchContacts() {
        var contacts = [User]()
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { contact, _ in
                        contacts.append(User(userID: nil, firstName: contact.givenName,
                                                lastName: contact.familyName,
                                                telephone: contact.phoneNumbers.first?.value.stringValue))
                    })
                    self.delegate?.didFinishFetch(contacts: contacts)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
                }
            } else {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, "access denied"))
            }
        }
    }
}
