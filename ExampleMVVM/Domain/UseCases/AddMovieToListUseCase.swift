//
//  AddMovieToListUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 20/01/1448 AH.
//

import Foundation

protocol AddMovieToListUseCase {

    @discardableResult
    func execute(
        requestValue: AddMovieToListUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultAddMovieToListUseCase: AddMovieToListUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    @discardableResult
    func execute(
        requestValue: AddMovieToListUseCaseRequestValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {

        listsRepository.addMovieToList(
            listId: requestValue.listId,
            movieId: requestValue.movieId,
            completion: completion
        )
    }
}

struct AddMovieToListUseCaseRequestValue {
    let listId: Int
    let movieId: String
}
