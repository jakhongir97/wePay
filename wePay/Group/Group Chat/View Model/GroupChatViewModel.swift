//
//  GroupChatViewModel.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol GroupChatViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class GroupChatViewModel {
    
    // MARK: - Attributes
    weak var delegate: GroupChatViewModelProtocol?
    
    let ref = Database.database().reference()
    
    // MARK: - Network call
}
