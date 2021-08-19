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
    let isCompleted: Bool?
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
    internal func createMessage(message: String, groupID: String, groupName: String, tags: [User]) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let timeStamp = Date().timeIntervalSince1970
        let currency = Curreny.uz.rawValue
        let messageRef = ref.child("messages").childByAutoId()
        messageRef.setValue(["message": message, "owner": userID, "groupID": groupID, "timeStamp": timeStamp, "currency": currency, "tagCount": tags.count, "isCompleted": false]) { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            let myGroup = DispatchGroup()
            for tag in tags {
                myGroup.enter()
                let childRef = self.ref.child("users_messages").child(groupID).childByAutoId()
                childRef.setValue(["userID": tag.userID, "messageID": messageRef.key]) { error, _ in
                    if let childKey = childRef.key {
                        self.ref.child("users_messages").child(groupID).child("\(childKey)/isPaid").setValue(false)
                    }
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                self.sendPushNotifications(groupID: groupID, groupName: groupName, message: message.withCurreny(currency: currency), users: tags)
                self.delegate?.didFinishFetch()
            }
        }
    }
    
    internal func sendPushNotifications(groupID: String, groupName: String, message: String, users: [User]) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(currentUserID).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String {
                if let  fullName = User(firstName: firstName, lastName: lastName).fullName {
                    for user in users {
                        if let userID = user.userID {
                            self.ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
                                let value = snapshot.value as? NSDictionary
                                if let fcmToken = value?["fcmToken"] as? String {
                                    //if userID != currentUserID {
                                        PushNotificationSender.sendPushNotification(to: fcmToken, groupID: groupID, title: groupName, body: "\(fullName) \n\(message)")
                                    //}
                                }
                            })
                        }
                        
                    }
                }
            }
        }
    }
    
    internal func getMessages(groupID: String) {
        //self.delegate?.showActivityIndicator()
        let messagesRef = ref.child("messages")
        messagesRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
            var messages = [Message]()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    let value = child.value as? NSDictionary
                    if let message = value?["message"] as? String, let owner = value?["owner"] as? String, let timeStamp = value?["timeStamp"] as? Double, let currency = value?["currency"] as? String, let isCompleted = value?["isCompleted"] as? Bool {
                        let message = Message(id: child.key, message: message, owner: owner, timeStamp: timeStamp, currency: currency, isCompleted: isCompleted)
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
    
    internal func changeValueMessage(messageID: String, newMessage: String) {
        ref.child("messages").child("\(messageID)/message").setValue(newMessage) { error, ref in
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func fetchGroupUsers(groupID: String) {
        //delegate?.showActivityIndicator()
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
        //delegate?.showActivityIndicator()
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
                                    if let isPaid = child.childSnapshot(forPath: "isPaid").value as? Bool {
                                        users[index].isPaid = isPaid
                                    }
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
    
    internal func payMessage(messageID: String, groupID: String, isPaid: Bool) {
        delegate?.showActivityIndicator()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersMessagesRef = ref.child("users_messages")
        usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value, with : { snapshot in
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    if let userID = child.childSnapshot(forPath: "userID").value as? String {
                        if userID == currentUserID {
                            usersMessagesRef.child(groupID).child("\(child.key)/isPaid").setValue(isPaid)
                            self.checkMessageComplete(messageID: messageID, groupID: groupID)
                        }
                    }
                }
            }
            self.delegate?.didFinishFetch()
            self.delegate?.hideActivityIndicator()
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
    
    internal func checkMessageComplete(messageID: String, groupID: String) {
        let messagesRef = ref.child("messages")
        let usersMessagesRef = ref.child("users_messages")
        messagesRef.child(messageID).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            if let tagCount = value?["tagCount"] as? Int {
                usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: messageID).observeSingleEvent(of: .value) { snapshot in
                    if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        var count = 0
                        for child in dataSnapshot {
                            if let isPaid = child.childSnapshot(forPath: "isPaid").value as? Bool, isPaid {
                                count += 1
                            }
                        }
                        messagesRef.child("\(messageID)/isCompleted").setValue(tagCount == count)
                    }
                }
            }
        }
        
    }
    
    func returnUserID() -> String? {
        Auth.auth().currentUser?.uid
    }
}
