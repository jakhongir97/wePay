//
//  LaunchScreenViewModel.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

protocol LaunchScreenViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class LaunchScreenViewModel {
    // MARK: - Attributes
    weak var delegate: LaunchScreenViewModelProtocol?

    // MARK: - Network call

}
