//
//  DeleteListUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 17/01/1448 AH.
//

import Foundation

protocol DeleteListUseCase {
    func execute(
        listId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultDeleteListUseCase: DeleteListUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    func execute(
        listId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        listsRepository.deleteList(
            listId: listId,
            completion: completion
        )
    }
}
