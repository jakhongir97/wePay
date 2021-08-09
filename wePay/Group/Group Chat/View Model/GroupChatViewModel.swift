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
    var taggedUsers: [User]?
}

protocol GroupChatViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
    func didFinishFetch(messages: [Message])
    func didFinishFetch(groupUsers: [User])
    func didFinishFetchWithTaggedUsers(messages: [Message])
}

final class GroupChatViewModel {
    
    // MARK: - Attributes
    weak var delegate: GroupChatViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
    internal func createMessage(message: String, groupID: String, tags: [User]) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let timeStamp = Date().timeIntervalSince1970
        let currency = Curreny.uz.rawValue
        let messageRef = ref.child("messages").childByAutoId()
        messageRef.setValue(["message": message, "owner": userID, "groupID": groupID, "timeStamp": timeStamp, "currency": currency]) { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            let myGroup = DispatchGroup()
            for tag in tags {
                myGroup.enter()
                self.ref.child("users_messages").child(groupID).childByAutoId().setValue(["userID": tag.userID, "messageID": messageRef.key]) { error, _ in
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                self.delegate?.didFinishFetch()
            }
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
    
    internal func deleteMessage(messageID: String, groupID: String) {
        let messagesRef = ref.child("messages")
        let usersMessagesRef = ref.child("users_messages")
        messagesRef.child(messageID).removeValue() { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value) { snapshot in
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in dataSnapshot {
                        usersMessagesRef.child(groupID).child(child.key).removeValue()
                    }
                }
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
    
    internal func fetchGroupUsers(groupID: String) {
        delegate?.showActivityIndicator()
        //guard let userID = Auth.auth().currentUser?.uid else { return }
        let usersGroupsRef = self.ref.child("users_groups")
        usersGroupsRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
            var users = [User]()
            let myGroup = DispatchGroup()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    myGroup.enter()
                    if let userID = child.childSnapshot(forPath: "userID").value as? String {
                        self.ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
                            let value = snapshot.value as? NSDictionary
                            if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String, let phone = value?["phone"] as? String {
                                users.append(User(userID: userID, firstName: firstName, lastName: lastName, telephone: phone))
                                myGroup.leave()
                            }
                        })
                    }
                }
            }
            myGroup.notify(queue: .main) {
                self.delegate?.hideActivityIndicator()
                self.delegate?.didFinishFetch(groupUsers: users)
            }
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
    
    internal func fetchWithTaggedUsers(groupID: String, groupUsers: [User], messages: [Message]) {
        delegate?.showActivityIndicator()
        let usersMessagesRef = ref.child("users_messages")
        var messagesWithTags = messages
        let myGroup = DispatchGroup()
        for (index,message) in messages.enumerated() {
            myGroup.enter()
            usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: message.id).observeSingleEvent(of: .value, with : { snapshot in
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
                messagesWithTags[index].taggedUsers = users.filter({$0.isMember ?? true })
                myGroup.leave()
            })
        }
        myGroup.notify(queue: .main) {
            self.delegate?.hideActivityIndicator()
            self.delegate?.didFinishFetchWithTaggedUsers(messages: messagesWithTags)
        }
    }
}
