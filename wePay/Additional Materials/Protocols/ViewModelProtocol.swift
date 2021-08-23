//
//  ViewModelProtocol.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import SnapKit
import UIKit

protocol ViewModelProtocol: AnyObject {
    // MARK: - Attributes
    var customSpinnerView: CustomSpinnerView { get }
    var isLoading: Bool { get set }

    func showActivityIndicator()
    func hideActivityIndicator()
    func showAlertClosure(error: (APIError, String?))
}

extension ViewModelProtocol where Self: UIViewController {
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.view.isUserInteractionEnabled = false
            self.customSpinnerView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.customSpinnerView)
            self.customSpinnerView.tintColor = UIColor.appColor(.blue)
            self.customSpinnerView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(100)
            }
            self.customSpinnerView.startAnimating()
        }
    }

    func hideActivityIndicator() {
        self.isLoading = false
        self.customSpinnerView.stopAnimating()
        self.customSpinnerView.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }

    func showAlertClosure(error: (APIError, String?)) {
        guard let self = self as? AlertViewController else { return }
        self.addErrorAlertView(error: error, completion: nil)
    }
}
