//
//  UsersViewModel.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol UsersViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(users: [User])
    func didFinishFetch(groupUsers: [User])
}

final class UsersViewModel {
    
    // MARK: - Attributes
    weak var delegate: UsersViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
    internal func fetchUsers(groupUsers: [User]) {
        delegate?.showActivityIndicator()
        guard let ownerUserID = Auth.auth().currentUser?.uid else { return }
        let usersRef = self.ref.child("users")
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            if let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var users = [User]()
                for child in dataSnapshot {
                    let value = child.value as? NSDictionary
                    if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String, let phone = value?["phone"] as? String {
                        var user = User(userID: child.key, firstName: firstName, lastName: lastName, telephone: phone, isMember: false)
                        for groupUser in groupUsers {
                            if child.key == groupUser.userID {
                                user.isMember = true
                            }
                        }
                        if ownerUserID != child.key {
                            users.append(user)
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
    
    internal func addUsers(group: Group, users: [User]) {
        guard let groupID = group.id else { return }
        
        for user in users {
            if let userID = user.userID {
                ref.child("users_groups").childByAutoId().setValue(["userID": userID, "groupID": groupID])
            }
        }
    }
}
