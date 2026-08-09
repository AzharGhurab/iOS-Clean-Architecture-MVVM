//
//  SelectListViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 20/01/1448 AH.
//
import Foundation

struct SelectListItem {
    let id: Int
    let name: String
    let itemCount: Int
    let posterPath: String?
    let containsMovie: Bool
}

protocol SelectListViewModelInput {
    func viewDidLoad()
}

protocol SelectListViewModelOutput {
    var items: Observable<[SelectListItem]> { get }
    var error: Observable<String?> { get }
}

protocol SelectListViewModel: SelectListViewModelInput, SelectListViewModelOutput { }

final class DefaultSelectListViewModel: SelectListViewModel {

    let items: Observable<[SelectListItem]> = Observable([])

    private let movieId: String
    private let fetchAccountUseCase: FetchAccountUseCase
    private let fetchListsUseCase: FetchListsUseCase
    private let fetchListDetailsUseCase: FetchListDetailsUseCase

    private var fetchAccountTask: Cancellable?
    private var fetchListsTask: Cancellable?
    private var fetchDetailsTasks: [Cancellable?] = []
    let error: Observable<String?> = Observable(nil)

    init(
        movieId: String,
        fetchAccountUseCase: FetchAccountUseCase,
        fetchListsUseCase: FetchListsUseCase,
        fetchListDetailsUseCase: FetchListDetailsUseCase
    ) {
        self.movieId = movieId
        self.fetchAccountUseCase = fetchAccountUseCase
        self.fetchListsUseCase = fetchListsUseCase
        self.fetchListDetailsUseCase = fetchListDetailsUseCase
    }

    func viewDidLoad() {
        fetchAccountTask = fetchAccountUseCase.execute { [weak self] result in
            switch result {
            case .success(let account):
                self?.fetchLists(accountId: account.id)

            case .failure(let error):
                self?.error.value = error.localizedDescription
            }
        }
    }

    private func fetchLists(accountId: Int) {
        fetchListsTask = fetchListsUseCase.execute(
            requestValue: FetchListsUseCaseRequestValue(accountId: accountId)
        ) { [weak self] result in
            switch result {
            case .success(let lists):
                self?.fetchPosters(for: lists)

            case .failure(let error):
                self?.error.value = error.localizedDescription
            }
        }
    }

    private func fetchPosters(for lists: [MovieList]) {
        guard !lists.isEmpty else {
            DispatchQueue.main.async {
                self.items.value = []
            }
            return
        }

        var updatedItems = lists.map {
            SelectListItem(
                id: $0.id,
                name: $0.name,
                itemCount: $0.itemCount,
                posterPath: nil,
                containsMovie: false
            )
        }

        let group = DispatchGroup()
        fetchDetailsTasks.removeAll()

        for index in lists.indices {
            group.enter()

            let task = fetchListDetailsUseCase.execute(
                listId: lists[index].id
            ) { [weak self] result in
                switch result {
                case .success(let movies):
                    let containsMovie = movies.contains {
                        String($0.id) == self?.movieId
                    }

                    updatedItems[index] = SelectListItem(
                        id: lists[index].id,
                        name: lists[index].name,
                        itemCount: lists[index].itemCount,
                        posterPath: movies.first?.posterPath,
                        containsMovie: containsMovie
                    )

                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }

                group.leave()
            }

            fetchDetailsTasks.append(task)
        }

        group.notify(queue: .main) { [weak self] in
            self?.items.value = updatedItems
        }
    }
}
