//
//  RemoveMovieFromListUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 21/01/1448 AH.
//

import Foundation

protocol RemoveMovieFromListUseCase {

    @discardableResult
    func execute(
        requestValue: RemoveMovieFromListUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultRemoveMovieFromListUseCase: RemoveMovieFromListUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    @discardableResult
    func execute(
        requestValue: RemoveMovieFromListUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        listsRepository.removeMovieFromList(
            listId: requestValue.listId,
            movieId: requestValue.movieId,
            completion: completion
        )
    }
}

struct RemoveMovieFromListUseCaseRequestValue {
    let listId: Int
    let movieId: String
}
