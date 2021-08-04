//
//  HomeViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import Contacts
import FirebaseDatabase
import FirebaseAuth

struct User: Decodable {
    let userID: String?
    var firstName: String?
    var lastName: String?
    var telephone: String?
    var isMember: Bool?
}

protocol HomeViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(contacts: [User])
}

final class HomeViewModel {
    
    // MARK: - Attributes
    weak var delegate: HomeViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
    internal func fetchContacts() {
        
        var contacts = [User]()
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
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
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        contacts.append(User(userID: nil, firstName: contact.givenName,
                                                lastName: contact.familyName,
                                                telephone: contact.phoneNumbers.first?.value.stringValue))
                    })
                    self.delegate?.didFinishFetch(contacts: contacts)
                } catch let error {
                    self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
                }
            } else {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, "access denied"))
            }
        }
    }
    
    internal func updateUser(firstName: String) {
        guard let user = Auth.auth().currentUser else { return }
        self.ref.child("users/\(user.uid)/firstName").setValue(firstName)
    }
    
    internal func updateUser(lastName: String) {
        guard let user = Auth.auth().currentUser else { return }
        self.ref.child("users/\(user.uid)/lastName").setValue(lastName)
    }
}
