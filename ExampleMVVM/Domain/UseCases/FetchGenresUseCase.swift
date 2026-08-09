//
//  FetchGenresUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 22/12/1447 AH.
//

import Foundation

struct GenresResult {
    let movieGenres: [Genre]
    let tvGenres: [Genre]
}

protocol FetchGenresUseCase {
    
    @discardableResult
    func execute(
        completion: @escaping (Result<GenresResult, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchGenresUseCase: FetchGenresUseCase {
    
    private let genresRepository: GenresRepository
    
    init(genresRepository: GenresRepository) {
        self.genresRepository = genresRepository
    }
    
    @discardableResult
    func execute(
        completion: @escaping (Result<GenresResult, Error>) -> Void
    ) -> Cancellable? {

        let dispatchGroup = DispatchGroup()

        var movieGenresResult: Result<[Genre], Error>?
        var tvGenresResult: Result<[Genre], Error>?

        dispatchGroup.enter()
        let movieGenresTask = genresRepository.fetchMovieGenres { result in
            movieGenresResult = result
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        let tvGenresTask = genresRepository.fetchTVGenres { result in
            tvGenresResult = result
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {

            if case .failure(let error) = movieGenresResult {
                completion(.failure(error))
                return
            }

            if case .failure(let error) = tvGenresResult {
                completion(.failure(error))
                return
            }

            let genresResult = GenresResult(
                movieGenres: movieGenresResult?.value ?? [],
                tvGenres: tvGenresResult?.value ?? []
            )

            completion(.success(genresResult))
        }

        return CompositeCancellable(tasks: [
            movieGenresTask,
            tvGenresTask
        ])
    }
}

private extension Result where Success == [Genre], Failure == Error {

    var value: [Genre]? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
}
