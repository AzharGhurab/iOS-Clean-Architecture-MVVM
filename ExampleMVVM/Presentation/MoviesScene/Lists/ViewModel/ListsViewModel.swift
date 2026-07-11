//
//  ListsViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

struct ListsViewModelActions {
    let showListDetails: (MovieList) -> Void
}

protocol ListsViewModelInput {
    func viewDidLoad()
    func didSelectList(at index: Int)
    func deleteList(at index: Int)
}

protocol ListsViewModelOutput {
    var items: Observable<[MovieList]> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String?> { get }
}

protocol ListsViewModel: ListsViewModelInput, ListsViewModelOutput { }

final class DefaultListsViewModel: ListsViewModel {

    let items: Observable<[MovieList]> = Observable([])
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<String?> = Observable(nil)

    private let fetchListsUseCase: FetchListsUseCase
    private let fetchListDetailsUseCase: FetchListDetailsUseCase
    private let deleteListUseCase: DeleteListUseCase
    private let actions: ListsViewModelActions
    private let accountId: Int
    private let mainQueue: DispatchQueueType

    private var fetchListsTask: Cancellable? {
        willSet { fetchListsTask?.cancel() }
    }

    private var posterLoadTasks: [Cancellable] = []

    private var deleteListTask: Cancellable? {
        willSet { deleteListTask?.cancel() }
    }

    init(
        fetchListsUseCase: FetchListsUseCase,
        fetchListDetailsUseCase: FetchListDetailsUseCase,
        deleteListUseCase: DeleteListUseCase,
        actions: ListsViewModelActions,
        accountId: Int,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.fetchListsUseCase = fetchListsUseCase
        self.fetchListDetailsUseCase = fetchListDetailsUseCase
        self.deleteListUseCase = deleteListUseCase
        self.actions = actions
        self.accountId = accountId
        self.mainQueue = mainQueue
    }

    func viewDidLoad() {
        loading.value = true
        fetchListsTask = fetchListsUseCase.execute(
            requestValue: FetchListsUseCaseRequestValue(accountId: accountId)
        ) { [weak self] result in
            self?.mainQueue.async {
                self?.loading.value = false

                switch result {
                case .success(let lists):
                    self?.items.value = lists
                    self?.loadPosters(for: lists)

                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }

    func didSelectList(at index: Int) {
        let list = items.value[index]
        actions.showListDetails(list)
    }

    func deleteList(at index: Int) {
        let list = items.value[index]

        deleteListTask = deleteListUseCase.execute(listId: list.id) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success:
                    var updatedItems = self?.items.value ?? []
                    updatedItems.remove(at: index)
                    self?.items.value = updatedItems

                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }

    private func loadPosters(for lists: [MovieList]) {
        posterLoadTasks.forEach { $0.cancel() }
        posterLoadTasks.removeAll()

        var updatedLists = lists

        for (index, list) in lists.enumerated() {
            let task = fetchListDetailsUseCase.execute(listId: list.id) { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let movies):
                        updatedLists[index].posterPath = movies.first?.posterPath
                        self?.items.value = updatedLists

                    case .failure:
                        break
                    }
                }
            }

            if let task = task {
                posterLoadTasks.append(task)
            }
        }
    }
}
