//
//  TaggedUsersViewModel.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol TaggedUsersViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(taggedUsers: [User])
}

final class TaggedUsersViewModel {
    
    // MARK: - Attributes
    weak var delegate: TaggedUsersViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
    internal func fetchTagedUsers(messageID: String, groupID: String, groupUsers: [User]) {
        delegate?.showActivityIndicator()
        let usersMessagesRef = ref.child("users_messages")
        usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value, with : { snapshot in
            var users = groupUsers
            users.indices.forEach { users[$0].isMember = false }
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    if let userID = child.childSnapshot(forPath: "userID").value as? String {
                        for (index,user) in users.enumerated() {
                            if userID == user.userID {
                                users[index].isMember = true
                            }
                        }
                    }
                }
            }
            self.delegate?.hideActivityIndicator()
            self.delegate?.didFinishFetch(taggedUsers: users)
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
        
    }
    
    internal func tagUsers(messageID: String, groupID: String, users: [User]) {
        let usersMessagesRef = ref.child("users_messages").child(groupID)
        usersMessagesRef.queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value) { snapshot in
            let myGroup = DispatchGroup()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    myGroup.enter()
                    usersMessagesRef.child(child.key).removeValue() { error, ref in
                        myGroup.leave()
                    }
                }
            }
            
            myGroup.notify(queue: .main) {
                for user in users {
                    if let userID = user.userID , user.isMember == true {
                        usersMessagesRef.childByAutoId().setValue(["messageID": messageID, "userID": userID])
                    }
                }
            }
        }
    }
    
}
