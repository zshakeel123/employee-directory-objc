//
//  KingfisherWrapper.swift
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 26/05/2025.
//

import Foundation
import Kingfisher
import UIKit

@objc class KingfisherWrapper: NSObject {
    @MainActor @objc static func setImageOn(_ imageView: UIImageView,
                                 urlString: String?,
                                 activityIndicator: UIActivityIndicatorView?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
                imageView.image = UIImage(systemName: "person.crop.circle.fill")
                imageView.tintColor = UIColor.systemGray
            }
            return
        }

        DispatchQueue.main.async {
            activityIndicator?.startAnimating()
            activityIndicator?.isHidden = false
        }

        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: nil,
            completionHandler: { result in
                DispatchQueue.main.async {
                    activityIndicator?.stopAnimating()
                    activityIndicator?.isHidden = true

                    switch result {
                    case .success(let value):
                        imageView.image = value.image
                        imageView.tintColor = nil
                    case .failure(let error):
                        print("Kingfisher load failed: \(error.localizedDescription)")
                        imageView.image = UIImage(systemName: "exclamationmark.circle.fill")
                        imageView.tintColor = UIColor.systemRed
                    }
                }
            }
        )
    }
}


