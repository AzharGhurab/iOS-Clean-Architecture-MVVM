//
//  CreateListUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import Foundation

protocol CreateListUseCase {
    func execute(
        requestValue: CreateListUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateListUseCase: CreateListUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    func execute(
        requestValue: CreateListUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        listsRepository.createList(
            name: requestValue.name,
            description: requestValue.description,
            completion: completion
        )
    }
}

struct CreateListUseCaseRequestValue {
    let name: String
    let description: String
}
