//
//  ListsRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 13/01/1448 AH.
//

import Foundation

protocol ListsRepository {

    @discardableResult
    func fetchLists(
        accountId: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable?

    func createList(
        name: String,
        description: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    func fetchListDetails(
        listId: Int,
        completion: @escaping (Result<[ListDetailsMovie], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func deleteList(
        listId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func addMovieToList(
        listId: Int,
        movieId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func removeMovieFromList(
        listId: Int,
        movieId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}
