//
//  AuthFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 02/01/1448 AH.
//

import UIKit

final class AuthFlowCoordinator {

    private weak var navigationController: UINavigationController?
    private let dependencies: MoviesSceneDIContainer

    private var loginViewModel: LoginViewModel?

    init(
        navigationController: UINavigationController,
        dependencies: MoviesSceneDIContainer
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        if dependencies.authenticationStorage.sessionId() != nil {
            showProfile()
        } else {
            showLogin()
        }
    }
    private func showLogin() {
        let actions = LoginViewModelActions(
            showProfile: { [weak self] in
                self?.showProfile()
            },
            showAuthorize: { [weak self] requestToken in
                self?.showAuthorize(requestToken: requestToken)
            }
        )

        let viewModel = dependencies.makeLoginViewModel(actions: actions)
        self.loginViewModel = viewModel

        let viewController = LoginViewController.create(with: viewModel)
        navigationController?.setViewControllers([viewController], animated: false)
    }

    private func showAuthorize(requestToken: String) {
        let viewController = AuthorizeViewController.create(
            requestToken: requestToken,
            onAuthorizationCompleted: { [weak self] requestToken in
                self?.loginViewModel?.createSession(requestToken: requestToken)
            }
        )

        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showProfile() {
        let profileViewController = ProfileViewController()
        navigationController?.setViewControllers([profileViewController], animated: true)
    }
}
