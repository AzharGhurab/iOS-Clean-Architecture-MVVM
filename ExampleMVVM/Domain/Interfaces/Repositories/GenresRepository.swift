//
//  GenresRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 21/12/1447 AH.
//

import Foundation

protocol GenresRepository {
    @discardableResult
    func fetchMovieGenres(
        completion: @escaping (Result<[Genre], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func fetchTVGenres(
        completion: @escaping (Result<[Genre], Error>) -> Void
    ) -> Cancellable?
}
