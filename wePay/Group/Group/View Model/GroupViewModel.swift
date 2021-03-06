//
//  GroupViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseDynamicLinks
import UIKit

struct Group: Decodable {
    let id: String?
    let name: String?
    let owner: String?
    var summary: String?
    var index: Int?
}

protocol GroupViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(groups: [Group])
    func didFinishFetch()
    func didFinishFetch(groupsWithSummary: [Group])
    func didFinishFetch(url: URL)
}

final class GroupViewModel {
    // MARK: - Attributes
    weak var delegate: GroupViewModelProtocol?

    let ref = Database.database().reference()

    // MARK: - Network call
    internal func createGroup(name: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let groupIDRef = ref.child("groups").childByAutoId()
        groupIDRef.setValue(["name": name, "owner": userID ])
        let groupID = groupIDRef.key
        ref.child("users_groups").childByAutoId().setValue(["userID": userID, "groupID": groupID]) { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }

    internal func deleteGroup(groupID: String) {
        let groupsIDRef = ref.child("groups")
        let usersGroupsRef = ref.child("users_groups")
        groupsIDRef.child(groupID).removeValue { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            usersGroupsRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value) { snapshot in
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in dataSnapshot {
                        usersGroupsRef.child(child.key).removeValue()
                    }
                }
                self.deleteMessagesInGroup(groupID: groupID)
                self.delegate?.didFinishFetch()
            }
        }
    }

    internal func deleteMessagesInGroup(groupID: String) {
        let messagesRef = ref.child("messages")
        let usersMessagesRef = ref.child("users_messages")
        messagesRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value) { snapshot in
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    messagesRef.child(child.key).removeValue()
                }
            }
        }
        usersMessagesRef.child(groupID).removeValue()
    }

    internal func editGroup(groupID: String, newName: String) {
        let groupsIDRef = ref.child("groups")
        groupsIDRef.child("\(groupID)/name").setValue(newName) { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }

    internal func fetchGroups() {
        // delegate?.showActivityIndicator()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users_groups").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { snapshot in
            var groups = [Group]()
            let myGroup = DispatchGroup()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var counter = 0
                for child in dataSnapshot {
                    myGroup.enter()
                    if let groupID = child.childSnapshot(forPath: "groupID").value as? String {
                        let index = child.childSnapshot(forPath: "index").value as? Int
                        self.ref.child("groups").child(groupID).observeSingleEvent(of: .value, with: { snapshot in
                            let value = snapshot.value as? NSDictionary
                            if let name = value?["name"] as? String, let owner = value?["owner"] as? String {
                                groups.append(Group(id: groupID, name: name, owner: owner, index: index ?? counter))
                                counter += 1
                                myGroup.leave()
                            }
                        })
                    }
                }
            }
            myGroup.notify(queue: .main) {
                self.delegate?.hideActivityIndicator()
                let sortedGroups = groups.sorted { $0.index ?? 0 < $1.index ?? 0}
                self.delegate?.didFinishFetch(groups: sortedGroups)
            }
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }

    func indexGroups(groups: [Group]) {
        var groups = groups
        for index in groups.indices {
            groups[index].index = index
        }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users_groups").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { snapshot in
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    if let groupID = child.childSnapshot(forPath: "groupID").value as? String {
                        let index = groups.first(where: { $0.id == groupID })?.index
                        self.ref.child("users_groups/\(child.key)/index").setValue(index)
                    }
                }
            }
        })
    }

    internal func fetchWithSummary(groups: [Group]) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let messagesRef = ref.child("messages")
        let usersMessagesRef = ref.child("users_messages")
        var groupsWithSummary = groups
        let myGroup = DispatchGroup()
        for (index, group) in groups.enumerated() {
            if let groupID = group.id {
                myGroup.enter()
                messagesRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value, with: { snapshot in
                    if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        var summary: Double = 0
                        let myLittleGroup = DispatchGroup()
                        for child in dataSnapshot {
                            let value = child.value as? NSDictionary
                            if let message = value?["message"] as? String, let owner = value?["owner"] as? String, let isCompleted = value?["isCompleted"] as? Bool, let tagCount = value?["tagCount"] as? Int, let paidCount = value?["paidCount"] as? Int {
                                if let messageInt = Int(message.digits), !isCompleted {
                                    myLittleGroup.enter()
                                    usersMessagesRef.child(groupID).queryOrdered(byChild: "messageID").queryEqual(toValue: child.key).observeSingleEvent(of: .value) { snapshot in
                                        if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                                            var taggedUsers = [User]()
                                            for child in dataSnapshot {
                                                let value = child.value as? NSDictionary
                                                if let userID = value?["userID"] as? String, let isPaid = value?["isPaid"] as? Bool {
                                                    taggedUsers.append(User(userID: userID, isPaid: isPaid))
                                                }
                                            }
                                            let average = tagCount == 0 ? 0.0 : Double(messageInt) / Double(tagCount)
                                            if currentUserID == owner {
                                                let messageSummary = Double(messageInt) - average*Double(paidCount)
                                                summary += messageSummary
                                            } else if taggedUsers.contains(where: { $0.userID == currentUserID }) {
                                                let isPaid = taggedUsers.first(where: {$0.userID == currentUserID})?.isPaid
                                                let messageSummary = isPaid ?? false ? 0.0 : -average
                                                summary += messageSummary
                                            }
                                            myLittleGroup.leave()
                                        }

                                    }

                                }
                            }
                        }
                        myLittleGroup.notify(queue: .main) {
                            groupsWithSummary[index].summary = String(Int(round(summary)))
                            myGroup.leave()
                        }
                    }
                })
            }
        }
        myGroup.notify(queue: .main) {
            self.delegate?.didFinishFetch(groupsWithSummary: groupsWithSummary)
        }
    }

    internal func addUser(groupID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersGroupsRef = self.ref.child("users_groups")
        usersGroupsRef.childByAutoId().setValue(["userID": currentUserID, "groupID": groupID]) { error, _ in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }

    func generateContentLink(groupID: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.example.com"
        components.path = "/join"
        let queryItem = URLQueryItem(name: "groupID", value: groupID)
        components.queryItems = [queryItem]

        guard let componentURL = components.url else { return }
        let domain = "https://jakhongir.page.link"

        let shareLink = DynamicLinkComponents(link: componentURL, domainURIPrefix: domain)
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            shareLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleIdentifier)
        }
        shareLink?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink?.socialMetaTagParameters?.title = "Join"

        shareLink?.shorten(completion: { url, _, error in
            if let error = error {
                print(error.localizedDescription )
                return
            }
            guard let url = url else { return }
            self.delegate?.didFinishFetch(url: url)
        })
    }

    func returnUserID() -> String? {
        Auth.auth().currentUser?.uid
    }
}
