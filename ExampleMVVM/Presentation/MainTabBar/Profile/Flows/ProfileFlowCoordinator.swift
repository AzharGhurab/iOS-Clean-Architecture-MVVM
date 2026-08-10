//
//  ProfileFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 18/02/1448 AH.
//

import UIKit
protocol ProfileFlowCoordinatorDependencies {
    var authenticationStorage: AuthenticationStorage { get }

    func makeProfileViewController(
        actions: ProfileViewModelActions
    ) -> ProfileViewController

    func makeListsFlowCoordinator(
        navigationController: UINavigationController,
        accountId: Int
    ) -> ListsFlowCoordinator

    func makeMovieSelectionViewController(
        type: MovieSelectionType
    ) -> MovieSelectionViewController

    func makeFetchAccountUseCase() -> FetchAccountUseCase
}

final class ProfileFlowCoordinator {

    private weak var navigationController: UINavigationController?
    private let dependencies: ProfileFlowCoordinatorDependencies

    private let onShowLogin: () -> Void
    private var listsFlowCoordinator: ListsFlowCoordinator?

    init(
        navigationController: UINavigationController,
        dependencies: ProfileFlowCoordinatorDependencies,
        onShowLogin: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.onShowLogin = onShowLogin
    }

    func start() {
        showProfile()
    }

    private func showProfile() {
        let actions = ProfileViewModelActions(
            showLogin: { [weak self] in
                self?.onShowLogin()
            },
            showLists: { [weak self] in
                self?.showLists()
            },
            showFavorites: { [weak self] in
                self?.showFavorites()
            },
            showWatchlist: { [weak self] in
                self?.showWatchlist()
            },
            showLoggedOut: { [weak self] in
                self?.onShowLogin()
            }
        )

        let viewController = dependencies.makeProfileViewController(
            actions: actions
        )

        navigationController?.setViewControllers(
            [viewController],
            animated: true
        )
    }

    private func showLists() {
        guard let navigationController else {
            return
        }

        if dependencies.authenticationStorage.guestSessionId() != nil {
            onShowLogin()
            return
        }

        if let accountId = dependencies.authenticationStorage.accountId() {
            startListsFlow(
                navigationController: navigationController,
                accountId: accountId
            )
            return
        }

        dependencies.makeFetchAccountUseCase().execute { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                switch result {
                case .success(let account):
                    self.dependencies.authenticationStorage.save(
                        accountId: account.id
                    )

                    self.startListsFlow(
                        navigationController: navigationController,
                        accountId: account.id
                    )

                case .failure(let error):
                    print(
                        "Fetch account error:",
                        error.localizedDescription
                    )
                }
            }
        }
    }

    private func startListsFlow(
        navigationController: UINavigationController,
        accountId: Int
    ) {
        let flow = dependencies.makeListsFlowCoordinator(
            navigationController: navigationController,
            accountId: accountId
        )

        listsFlowCoordinator = flow
        flow.start()
    }

    private func showFavorites() {
        let viewController =
            dependencies.makeMovieSelectionViewController(
                type: .favorites
            )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    private func showWatchlist() {
        let viewController =
            dependencies.makeMovieSelectionViewController(
                type: .watchlist
            )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}
