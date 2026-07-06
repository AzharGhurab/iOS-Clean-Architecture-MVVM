//
//  ListsFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import UIKit

protocol ListsFlowCoordinatorDependencies {
    func makeListsViewController(
        accountId: Int,
        actions: ListsViewModelActions,
        onCreateList: @escaping () -> Void
    ) -> ListsViewController

    func makeCreateListViewController(
        actions: CreateListViewModelActions
    ) -> CreateListViewController
    

    func makeListDetailsViewController(
        listId: Int,
        title: String
    ) -> ListDetailsViewController
}

final class ListsFlowCoordinator {

    private weak var navigationController: UINavigationController?
    private let dependencies: ListsFlowCoordinatorDependencies
    private let accountId: Int

    init(
        navigationController: UINavigationController,
        dependencies: ListsFlowCoordinatorDependencies,
        accountId: Int
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.accountId = accountId
    }

    func start() {
        showLists()
    }

    private func showLists() {
        let actions = ListsViewModelActions(
            showListDetails: { [weak self] list in
                self?.showListDetails(list: list)
            }
        )

        let viewController = dependencies.makeListsViewController(
            accountId: accountId,
            actions: actions,
            onCreateList: { [weak self] in
                self?.showCreateList()
            }
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    private func showCreateList() {
        let viewController = dependencies.makeCreateListViewController(
            actions: CreateListViewModelActions(
                didCreateList: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    private func showListDetails(list: MovieList) {
        let viewController = dependencies.makeListDetailsViewController(
            listId: list.id,
            title: list.name
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}
