//
//  UsersViewModel.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import Contacts
import FirebaseAuth
import FirebaseDatabase
import UIKit

protocol UsersViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(contacts: [User])
    func didFinishFetch(users: [User])
    func didFinishFetch(groupUsers: [User])
    func didFinishFetchRemoveUsers()
}

final class UsersViewModel {
    // MARK: - Attributes
    weak var delegate: UsersViewModelProtocol?

    let ref = Database.database().reference()

    // MARK: - Network call
    internal func fetchUsers(groupUsers: [User], contacts: [User]) {
        delegate?.showActivityIndicator()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersRef = self.ref.child("users")
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var users = [User]()
                for child in dataSnapshot {
                    let value = child.value as? NSDictionary
                    if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String, let phone = value?["phone"] as? String {
                        if contacts.contains(where: { $0.telephone?.digits == phone.digits }) {
                            var user = User(userID: child.key, firstName: firstName, lastName: lastName, telephone: phone, isMember: false)
                            for groupUser in groupUsers where child.key == groupUser.userID {
                                user.isMember = true
                            }
                            if currentUserID != child.key {
                                users.append(user)
                            }
                        }
                    }
                }
                self.delegate?.hideActivityIndicator()
                self.delegate?.didFinishFetch(users: users)
            }
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }

    internal func fetchGroupUsers(groupID: String) {
        delegate?.showActivityIndicator()
        // guard let userID = Auth.auth().currentUser?.uid else { return }
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
                            if let phone = value?["phone"] as? String {
                                users.append(User(userID: userID, firstName: value?["firstName"] as? String, lastName: value?["lastName"] as? String, telephone: phone))
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

    internal func updateUsers(group: Group, oldUsers: [User], newUsers: [User]) {
        addUsers(group: group, users: Array(Set(newUsers).subtracting(oldUsers)))
        removeUsers(group: group, users: Array(Set(oldUsers).subtracting(newUsers)))
    }

    internal func addUsers(group: Group, users: [User]) {
        guard let groupID = group.id else { return }
        guard let groupName = group.name else { return }
        let usersGroupsRef = self.ref.child("users_groups")
        for user in users {
            if let userID = user.userID {
                usersGroupsRef.childByAutoId().setValue(["userID": userID, "groupID": groupID])
                sendPushNotifications(groupID: groupID, groupName: groupName, userID: userID)
            }
        }
    }

    internal func removeUsers(group: Group, users: [User]) {
        guard let groupID = group.id else { return }
        let usersGroupsRef = self.ref.child("users_groups")
        usersGroupsRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    if let userID = child.childSnapshot(forPath: "userID").value as? String {
                        if users.contains(where: { $0.userID == userID }) {
                            usersGroupsRef.child(child.key).removeValue()
                        }
                    }
                }
            }
        })
    }

    internal func sendPushNotifications(groupID: String, groupName: String, userID: String) {
        self.ref.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            if let fcmToken = value?["fcmToken"] as? String {
                PushNotificationSender.sendPushNotification(to: fcmToken, groupID: groupID, title: groupName, body: "You invited to the group!")
            }
        })
    }

    internal func removeAllUsers(group: Group) {
        guard let groupID = group.id else { return }
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersGroupsRef = self.ref.child("users_groups")
        usersGroupsRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
            let myGroup = DispatchGroup()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    myGroup.enter()
                    if let userID = child.childSnapshot(forPath: "userID").value as? String {
                        if userID != currentUserID {
                            usersGroupsRef.child(child.key).removeValue { _, _ in
                                myGroup.leave()
                            }
                        } else {
                            myGroup.leave()
                        }
                    }
                }
            }

            myGroup.notify(queue: .main) {
                self.delegate?.didFinishFetchRemoveUsers()
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
                        contacts.append(User(firstName: contact.givenName,
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
