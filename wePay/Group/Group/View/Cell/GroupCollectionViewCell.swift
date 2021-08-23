//
//  GroupCollectionViewCell.swift
//  wePay
//
//  Created by Admin NBU on 03/08/21.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    // MARK: - Attributes
    @IBOutlet var label: UILabel!
    @IBOutlet var summaryLabel: UILabel!

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.appColor(.darkGray)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
    }
}
