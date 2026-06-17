//
//  LoginViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import UIKit

final class LoginViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private weak var continueAsGuestButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!

    private var viewModel: LoginViewModel!

    static func create(with viewModel: LoginViewModel) -> LoginViewController {
        let view = LoginViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        signInButton.layer.cornerRadius = 20
        signInButton.clipsToBounds = true
    }

    private func bind(to viewModel: LoginViewModel) {

        viewModel.error.observe(on: self) { [weak self] error in
            guard let error else { return }

            let alert = UIAlertController(
                title: "Error",
                message: error,
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )

            self?.present(alert, animated: true)
        }
    }

    @IBAction private func continueAsGuestTapped(_ sender: UIButton) {
        viewModel.continueAsGuest()
    }

    @IBAction private func signInTapped(_ sender: UIButton) {
        viewModel.signIn()
    }
}
