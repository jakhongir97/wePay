//
//  GroupViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

protocol GroupViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class GroupViewModel {
    
    // MARK: - Attributes
    weak var delegate: GroupViewModelProtocol?
    
    // MARK: - Network call
}
