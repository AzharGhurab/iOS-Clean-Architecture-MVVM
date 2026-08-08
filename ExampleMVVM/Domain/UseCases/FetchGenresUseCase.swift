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
    ) -> Cancellable?{
        
        let task = genresRepository.fetchMovieGenres { [weak self] movieResult in
            
            switch movieResult {
                
            case .success(let movieGenres):
                
                _ = self?.genresRepository.fetchTVGenres { tvResult in
                    
                    switch tvResult {
                        
                    case .success(let tvGenres):
                        
                        completion(
                            .success(
                                GenresResult(
                                    movieGenres: movieGenres,
                                    tvGenres: tvGenres
                                )
                            )
                        )
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
