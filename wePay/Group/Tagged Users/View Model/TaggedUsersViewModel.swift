//
//  TaggedUsersViewModel.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import FirebaseAuth
import FirebaseDatabase
import UIKit

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
        usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value, with: { snapshot in
            var users = groupUsers
            users.indices.forEach { users[$0].isMember = false }
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    if let userID = child.childSnapshot(forPath: "userID").value as? String, let isPaid = child.childSnapshot(forPath: "isPaid").value as? Bool {
                        for (index, user) in users.enumerated() where userID == user.userID {
                            users[index].isMember = true
                            users[index].isPaid = isPaid
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
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        var users = users
        var paidUserIDs = [String]()
        let usersMessagesRef = ref.child("users_messages").child(groupID)
        usersMessagesRef.queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value) { snapshot in
            let myGroup = DispatchGroup()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    myGroup.enter()
                    if let isPaid = child.childSnapshot(forPath: "isPaid").value as? Bool, let userID = child.childSnapshot(forPath: "userID").value as? String {
                        if isPaid {
                            paidUserIDs.append(userID)
                        }
                    }
                    usersMessagesRef.child(child.key).removeValue { _, _ in
                        myGroup.leave()
                    }
                }
            }

            myGroup.notify(queue: .main) {
                for (index, user) in users.enumerated() {
                    if let userID = user.userID, user.isMember == true {
                        let isPaid = paidUserIDs.contains(userID) || currentUserID == userID
                        users[index].isPaid = isPaid
                        usersMessagesRef.childByAutoId().setValue(["messageID": messageID, "userID": userID, "isPaid": isPaid])
                    }
                }
                let messageRef = self.ref.child("messages")
                messageRef.child("\(messageID)/tagCount").setValue(users.filter { $0.isMember == true }.count)
                messageRef.child("\(messageID)/isOwnerTagged").setValue(users.contains(where: {$0.userID == currentUserID}))
                messageRef.child("\(messageID)/paidCount").setValue(users.filter { $0.isPaid == true }.count)
            }
        }
    }
}
