//
//  AuthorizeViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 01/01/1448 AH.
//

import UIKit
import SafariServices

final class AuthorizeViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private weak var openTMDBButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var requestToken: String!
    private var onAuthorizationCompleted: ((String, @escaping (Bool) -> Void) -> Void)?
    private let appConfiguration = AppConfiguration()
    static func create(
        requestToken: String,
        onAuthorizationCompleted: ((String, @escaping (Bool) -> Void) -> Void)?
    ) -> AuthorizeViewController {
        let view = AuthorizeViewController.instantiateViewController()
        view.requestToken = requestToken
        view.onAuthorizationCompleted = onAuthorizationCompleted
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        openTMDBButton.layer.cornerRadius = 20
        openTMDBButton.clipsToBounds = true
    }

    @IBAction private func openTMDBTapped(_ sender: UIButton) {
        guard let url = URL(
            string: "\(appConfiguration.tmdbAuthenticationBaseURL)\(requestToken ?? "")"
        ) else {
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        present(safariViewController, animated: true)
    }
}

// MARK: - Private

private extension AuthorizeViewController {

    func setupView() {
        title = "Authentication"
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
}

// MARK: - SFSafariViewControllerDelegate

extension AuthorizeViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        activityIndicator.startAnimating()
        openTMDBButton.isEnabled = false
        onAuthorizationCompleted?(requestToken) { [weak self] success in
            self?.activityIndicator.stopAnimating()
            self?.openTMDBButton.isEnabled = true
        }
    }
}
