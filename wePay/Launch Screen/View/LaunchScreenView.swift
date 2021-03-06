//
//  LaunchScreenView.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import SnapKit
import UIKit

final class LaunchScreenView: CustomView {
    // MARK: - Outlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    weak var errorView: ErrorView! {
        didSet {
            errorView.closeButton.isHidden = true
        }
    }

    // MARK: - UI Setup
    internal func createErrorView(errorType: APIError) {
        let errorView = ErrorView.fromNib()
        errorView.type = errorType
        addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.errorView = errorView
    }
}
