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
}
