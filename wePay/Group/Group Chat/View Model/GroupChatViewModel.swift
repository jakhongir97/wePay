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
        let messageIDRef = ref.child("messages").childByAutoId()
        messageIDRef.setValue(["message": message, "owner": userID, "groupID": groupID, "timeStamp": timeStamp]) { error, ref in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func getMessages(groupID: String) {
        let messageIDRef = ref.child("messages")
        messageIDRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
            var messages = [Message]()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    let value = child.value as? NSDictionary
                    if let message = value?["message"] as? String, let owner = value?["owner"] as? String, let timeStamp = value?["timeStamp"] as? Double {
                        let message = Message(id: child.key, message: message, owner: owner, timeStamp: timeStamp)
                        messages.append(message)
                    }
                }
            }
            self.delegate?.didFinishFetch(messages: messages)
        }) { error in
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
}
