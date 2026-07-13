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

    func makeProfileViewController(
        actions: ProfileViewModelActions
    ) -> ProfileViewController

    func makeListsFlowCoordinator(
        navigationController: UINavigationController,
        accountId: Int
    ) -> ListsFlowCoordinator
    func makeFetchAccountUseCase() -> FetchAccountUseCase
}

final class AuthFlowCoordinator {

    private weak var navigationController: UINavigationController?
    private let dependencies: AuthFlowCoordinatorDependencies
    private var loginViewModel: LoginViewModel?
    private var listsFlowCoordinator: ListsFlowCoordinator?

    init(
        navigationController: UINavigationController,
        dependencies: AuthFlowCoordinatorDependencies
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

    private func showLists() {
        guard let navigationController = navigationController else { return }

        if let accountId = dependencies.authenticationStorage.accountId() {
            let flow = dependencies.makeListsFlowCoordinator(
                navigationController: navigationController,
                accountId: accountId
            )

            listsFlowCoordinator = flow
            flow.start()
            return
        }

        dependencies.makeFetchAccountUseCase().execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    let flow = self?.dependencies.makeListsFlowCoordinator(
                        navigationController: navigationController,
                        accountId: account.id
                    )

                    self?.listsFlowCoordinator = flow
                    flow?.start()

                case .failure(let error):
                    print(" fetch account error:", error.localizedDescription)
                }
            }
        }
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
        let actions = ProfileViewModelActions(
            showLogin: { [weak self] in
                self?.showLogin()
            },
            showLists: { [weak self] in
                self?.showLists()
            }
        )

        let profileViewController = dependencies.makeProfileViewController(
            actions: actions
        )

        navigationController?.setViewControllers(
            [profileViewController],
            animated: true
        )
    }
}
