//
//  GroupViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseDynamicLinks

struct Group : Decodable {
    let id: String?
    let name: String?
    let owner: String?
    var summary: String?
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
        ref.child("users_groups").childByAutoId().setValue(["userID": userID, "groupID": groupID]) { error, ref in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func deleteGroup(groupID: String) {
        let groupsIDRef = ref.child("groups")
        let usersGroupsRef = self.ref.child("users_groups")
        groupsIDRef.child(groupID).removeValue() { error, ref in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            usersGroupsRef.queryOrdered(byChild: "groupID").queryEqual(toValue: groupID).observeSingleEvent(of: .value) { snapshot in
                if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in dataSnapshot {
                        usersGroupsRef.child(child.key).removeValue()
                    }
                }
            }
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func editGroup(groupID: String,newName: String) {
        let groupsIDRef = ref.child("groups")
        groupsIDRef.child("\(groupID)/name").setValue(newName) { error, ref in
            if let error = error {
                self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
            }
            self.delegate?.didFinishFetch()
        }
    }
    
    internal func fetchGroups() {
        //delegate?.showActivityIndicator()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users_groups").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { snapshot in
            var groups = [Group]()
            let myGroup = DispatchGroup()
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for child in dataSnapshot {
                    myGroup.enter()
                    if let groupID = child.childSnapshot(forPath: "groupID").value as? String {
                        self.ref.child("groups").child(groupID).observeSingleEvent(of: .value, with: { snapshot in
                            let value = snapshot.value as? NSDictionary
                            if let name = value?["name"] as? String, let owner = value?["owner"] as? String {
                                groups.append(Group(id: groupID, name: name, owner: owner))
                                myGroup.leave()
                            }
                        })
                    }
                }
            }
            myGroup.notify(queue: .main) {
                self.delegate?.hideActivityIndicator()
                self.delegate?.didFinishFetch(groups: groups)
            }
        }) { error in
            self.delegate?.hideActivityIndicator()
            self.delegate?.showAlertClosure(error: (APIError.fromMessage, error.localizedDescription))
        }
    }
    
    internal func fetchWithSummary(groups: [Group]) {
        //self.delegate?.showActivityIndicator()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersMessagesRef = ref.child("users_messages")
        let messagesRef = ref.child("messages")
        var groupsWithSummary = groups
        let myGroup = DispatchGroup()
        for (index,group) in groups.enumerated() {
            if let groupID = group.id {
                myGroup.enter()
                usersMessagesRef.child(groupID).queryOrdered(byChild: "userID").queryEqual(toValue: currentUserID).observeSingleEvent(of: .value, with : { snapshot in
                    var summary: Double = 0
                    var ownerSummary: Double = 0
                    let myLitteGroup = DispatchGroup()
                    if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for child in dataSnapshot {
                            if let isPaid = child.childSnapshot(forPath: "isPaid").value as? Bool, !isPaid {
                                if let messageID = child.childSnapshot(forPath: "messageID").value as? String {
                                    myLitteGroup.enter()
                                    messagesRef.child(messageID).observeSingleEvent(of: .value) { snapshot in
                                        let value = snapshot.value as? NSDictionary
                                        if let message = value?["message"] as? String, let isCompleted = value?["isCompleted"] as? Bool, let count = value?["tagCount"] as? Int, let messageInt = Int(message.digits), !isCompleted {
                                            summary += Double(messageInt)/Double(count)
                                            myLitteGroup.leave()
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    myLitteGroup.notify(queue: .main) {
                        messagesRef.queryOrdered(byChild: "owner").queryEqual(toValue: currentUserID).observeSingleEvent(of: .value) { snapshot in
                            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                                for child in dataSnapshot {
                                    let value = child.value as? NSDictionary
                                    if let message = value?["message"] as? String, let isCompleted = value?["isCompleted"] as? Bool, let messageGroupID = value?["groupID"] as? String, let messageDouble = Double(message.digits) {
                                        if !isCompleted && messageGroupID == groupID {
                                            ownerSummary += messageDouble
                                        }
                                    }
                                }
                            }
                            groupsWithSummary[index].summary = String(Int(ownerSummary - summary))
                            myGroup.leave()
                        }
                    }
                })
            }
        }
        myGroup.notify(queue: .main) {
            self.delegate?.hideActivityIndicator()
            self.delegate?.didFinishFetch(groupsWithSummary: groupsWithSummary)
        }
    }
    
    internal func addUser(groupID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersGroupsRef = self.ref.child("users_groups")
        usersGroupsRef.childByAutoId().setValue(["userID": currentUserID, "groupID": groupID]) { error, ref in
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
        
        shareLink?.shorten(completion: { url, warnings, error in
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
