//
//  GroupChatViewModel.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct Message: Decodable {
    let id: String?
    let message: String?
    let owner: String?
    let timeStamp: Double?
    let currency: String?
}

protocol GroupChatViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
    func didFinishFetch(messages: [Message])
}

final class GroupChatViewModel {
    
    // MARK: - Attributes
    weak var delegate: GroupChatViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
    internal func createMessage(message: String, groupID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let timeStamp = Date().timeIntervalSince1970
        let currency = Curreny.uz.rawValue
        let messagesRef = ref.child("messages")
        messagesRef.childByAutoId().setValue(["message": message, "owner": userID, "groupID": groupID, "timeStamp": timeStamp, "currency": currency]) { error, ref in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func getMessages(groupID: String) {
        self.delegate?.showActivityIndicator()
        let messagesRef = ref.child("messages")
        messagesRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
            var messages = [Message]()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    let value = child.value as? NSDictionary
                    if let message = value?["message"] as? String, let owner = value?["owner"] as? String, let timeStamp = value?["timeStamp"] as? Double, let currency = value?["currency"] as? String {
                        let message = Message(id: child.key, message: message, owner: owner, timeStamp: timeStamp, currency: currency)
                        messages.append(message)
                    }
                }
            }
            self.delegate?.hideActivityIndicator()
            self.delegate?.didFinishFetch(messages: messages)
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
    
    internal func deleteMessage(messageID: String) {
        let messagesRef = ref.child("messages")
        messagesRef.child(messageID).removeValue() { error, ref in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func changeCurrencyMessage(messageID: String) {
        let currencyRef = ref.child("messages").child("\(messageID)/currency")
        currencyRef.observeSingleEvent(of: .value) { snapshot in
            if let currency = snapshot.value as? String {
                switch currency {
                case Curreny.usa.rawValue:
                    currencyRef.setValue(Curreny.uz.rawValue)
                case Curreny.uz.rawValue:
                    currencyRef.setValue(Curreny.usa.rawValue)
                default:
                    break
                }
            }
            self.delegate?.didFinishFetch()
        }
    }
}
