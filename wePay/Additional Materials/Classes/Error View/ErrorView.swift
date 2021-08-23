//
//  ErrorView.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

final class ErrorView: CustomView {
	// MARK: - Outlets
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var emptyImageView: Image!
    @IBOutlet var emptyInfoTitleLabel: Label!
    @IBOutlet var emptyInfoDescriptionLabel: Label!
    @IBOutlet var retryButton: UIButton!

    // MARK: - Attributes
	internal var type: APIError? {
		didSet {
			guard let type = type else { return }
			switch type {
			case .notAuthorized:
				retryButton.isHidden = true
				emptyInfoTitleLabel.text = "Авторизация".toLocalized()
				emptyInfoDescriptionLabel.text = "Для того что бы пользоваться данным разделом\nВам необходимо войти".toLocalized()
			case .requestFailed:
				emptyInfoTitleLabel.text = "Нет интернет соединения".toLocalized()
				emptyInfoDescriptionLabel.text = "Проверьте подключение к Интернету и повторите попытку".toLocalized()
			default:
				emptyInfoTitleLabel.text = "Ошибка сервера".toLocalized()
				emptyInfoDescriptionLabel.text = "Видимо что-то пошло не так\nпопробуйте снова".toLocalized()
			}
		}
	}
}
