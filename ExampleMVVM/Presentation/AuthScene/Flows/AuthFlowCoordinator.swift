//
//  AuthFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 02/01/1448 AH.
//

import UIKit
protocol AuthFlowCoordinatorDependencies {
    var authenticationStorage: AuthenticationStorage { get }

    func makeLoginViewModel(
        actions: LoginViewModelActions
    ) -> LoginViewModel

    func makeProfileFlowCoordinator(
        navigationController: UINavigationController,
        onShowLogin: @escaping () -> Void
    ) -> ProfileFlowCoordinator
}

final class AuthFlowCoordinator {

    private weak var navigationController: UINavigationController?
    private let dependencies: AuthFlowCoordinatorDependencies
    private var loginViewModel: LoginViewModel?
    private var profileFlowCoordinator: ProfileFlowCoordinator?
    init(
        navigationController: UINavigationController,
        dependencies: AuthFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let sessionId = dependencies.authenticationStorage.sessionId()
        let guestSessionId = dependencies.authenticationStorage.guestSessionId()

        if sessionId != nil || guestSessionId != nil {
            showProfileFlow()
        } else {
            showLogin()
        }
    }

    private func showLogin() {
        profileFlowCoordinator = nil
        let actions = LoginViewModelActions(
            showProfile: { [weak self] in
                self?.showProfileFlow()
            },
            showAuthorize: { [weak self] requestToken in
                self?.showAuthorize(
                    requestToken: requestToken
                )
            }
        )

        let viewModel =
            dependencies.makeLoginViewModel(
                actions: actions
            )

        loginViewModel = viewModel

        let viewController =
            LoginViewController.create(
                with: viewModel
            )

        navigationController?.setViewControllers(
            [viewController],
            animated: false
        )
    }

    private func showAuthorize(requestToken: String) {
        let viewController = AuthorizeViewController.create(
            requestToken: requestToken,
            onAuthorizationCompleted: { [weak self] requestToken , completion  in
                self?.loginViewModel?.createSession(requestToken: requestToken , completion: completion)
            }
        )

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showProfileFlow() {
        guard let navigationController else {
            return
        }

        let flow =
            dependencies.makeProfileFlowCoordinator(
                navigationController: navigationController,
                onShowLogin: { [weak self] in
                    self?.showLogin()
                }
            )

        profileFlowCoordinator = flow
        flow.start()
    }
}
