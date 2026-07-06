//
//  ListDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import Foundation

protocol ListDetailsViewModelInput {
    func viewDidLoad()
}

protocol ListDetailsViewModelOutput {
    var items: Observable<[ListDetailsMovie]> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String?> { get }
}

protocol ListDetailsViewModel: ListDetailsViewModelInput, ListDetailsViewModelOutput { }

final class DefaultListDetailsViewModel: ListDetailsViewModel {

    let items: Observable<[ListDetailsMovie]> = Observable([])
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<String?> = Observable(nil)

    private let listId: Int
    private let fetchListDetailsUseCase: FetchListDetailsUseCase
    private let mainQueue: DispatchQueueType

    private var fetchTask: Cancellable? {
        willSet { fetchTask?.cancel() }
    }

    init(
        listId: Int,
        fetchListDetailsUseCase: FetchListDetailsUseCase,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.listId = listId
        self.fetchListDetailsUseCase = fetchListDetailsUseCase
        self.mainQueue = mainQueue
    }

    func viewDidLoad() {
        loading.value = true

        fetchTask = fetchListDetailsUseCase.execute(listId: listId) { [weak self] result in
            self?.mainQueue.async {
                self?.loading.value = false

                switch result {
                case .success(let movies):
                    self?.items.value = movies

                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }
}
