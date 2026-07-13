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
    private weak var listsViewController: ListsViewController?

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
        let viewController = makeRootViewController()

        listsViewController = viewController

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    private func makeRootViewController() -> ListsViewController {
        let actions = ListsViewModelActions(
            showListDetails: { [weak self] list in
                self?.showListDetails(list: list)
            }
        )

        return dependencies.makeListsViewController(
            accountId: accountId,
            actions: actions,
            onCreateList: { [weak self] in
                self?.showCreateList()
            }
        )
    }

    private func showCreateList() {
        let actions = CreateListViewModelActions(
            didCreateList: { [weak self] in
                self?.didCreateList()
            }
        )

        let viewController = dependencies.makeCreateListViewController(
            actions: actions
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    private func didCreateList() {
        navigationController?.popViewController(
            animated: true
        )

        listsViewController?.refreshLists()
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
