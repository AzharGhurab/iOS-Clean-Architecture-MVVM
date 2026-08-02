//
//  FetchListDetailsUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import Foundation

protocol FetchListDetailsUseCase {

    @discardableResult
    func execute(
        listId: Int,
        completion: @escaping (Result<[MovieSelectionMovie], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchListDetailsUseCase: FetchListDetailsUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    @discardableResult
    func execute(
        listId: Int,
        completion: @escaping (Result<[MovieSelectionMovie], Error>) -> Void
    ) -> Cancellable? {
        listsRepository.fetchListDetails(
            listId: listId,
            completion: completion
        )
    }
}
