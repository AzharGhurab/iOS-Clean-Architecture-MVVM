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
        
        viewModel.authenticationState.observe(on: self) { [weak self] state in
            guard let state else { return }
            
            switch state {
            case .failed(let error):
                self?.showAlert(message: error.localizedDescription)
                
            case .guest, .loggedIn:
                break
            }
        }
    }
    private func showAlert(message: String) {
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: .default
                    )
                )
                
                self.present(alert, animated: true)
            }
    @IBAction private func continueAsGuestTapped(_ sender: UIButton) {
        viewModel.continueAsGuest()
    }

    @IBAction private func signInTapped(_ sender: UIButton) {
        viewModel.signIn()
    }
}
