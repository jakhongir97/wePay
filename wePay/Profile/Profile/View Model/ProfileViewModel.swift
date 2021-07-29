//
//  ProfileViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

protocol ProfileViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class ProfileViewModel {
    
    // MARK: - Attributes
    weak var delegate: ProfileViewModelProtocol?
    
    // MARK: - Network call
}
