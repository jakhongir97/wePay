//
//  HomeViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

protocol HomeViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class HomeViewModel {
    
    // MARK: - Attributes
    weak var delegate: HomeViewModelProtocol?
    
    // MARK: - Network call
}
