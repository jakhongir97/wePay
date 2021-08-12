//
//  ProfilView.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

final class ProfileView: CustomView {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.isUserInteractionEnabled = true
            profileImageView.layer.cornerRadius = 50
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
}
