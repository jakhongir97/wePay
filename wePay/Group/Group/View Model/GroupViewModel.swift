//
//  GroupViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct Group : Decodable {
    let id: String?
    let name: String?
}

protocol GroupViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(groups: [Group])
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
        ref.child("users_groups").childByAutoId().setValue(["userID": userID, "groupID": groupID])
    }
    
    internal func fetchGroups() {
        delegate?.showActivityIndicator()
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
                            if let name = value?["name"] as? String {
                                groups.append(Group(id: groupID, name: name))
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
}
