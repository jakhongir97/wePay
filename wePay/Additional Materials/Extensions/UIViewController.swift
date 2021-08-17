//
//  UIViewController.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

extension UIViewController {
    func share(imageURL: URL? = nil, text: String , url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                var items = [Any]()
                if let imageURL = imageURL, imageURL != URL(fileURLWithPath: ""), UIApplication.shared.canOpenURL(imageURL) {
                    let imageData: NSData = NSData(contentsOf: imageURL)!
                    let image = UIImage(data: imageData as Data)
                    items.append(image!)
                }
                items.append(text)
                items.append(url)
                let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
                //UIApplication.shared.endIgnoringInteractionEvents()
                if UIDevice.current.userInterfaceIdiom == .pad {
                    vc.popoverPresentationController?.sourceView = self.view
                    vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    vc.popoverPresentationController?.permittedArrowDirections = []
                }
                self.present(vc, animated: true)
            }
        }
    }
}

extension UIViewController {
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    ///Creates a tap gesture recognizer that closes the keyboard when an outside view is tapped.
    internal func closeKeyboardOnOutsideTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    var hasSafeArea: Bool {
        guard
            #available(iOS 11.0, tvOS 11.0, *)
            else {
                return false
            }
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}
