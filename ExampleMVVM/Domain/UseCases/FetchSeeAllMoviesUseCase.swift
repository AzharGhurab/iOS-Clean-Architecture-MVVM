//
//  FetchSeeAllMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 21/02/1448 AH.
//

import Foundation

protocol FetchSeeAllMoviesUseCase {
    func execute(
        requestValue: FetchSeeAllMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchSeeAllMoviesUseCase: FetchSeeAllMoviesUseCase {

    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }

    func execute(
        requestValue: FetchSeeAllMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {

        switch requestValue.section {
        case .nowPlaying:
            return moviesRepository.fetchNowPlayingMovies(
                page: requestValue.page,
                completion: completion
            )

        case .popular:
            return moviesRepository.fetchPopularMedia(
                category: .movies,
                page: requestValue.page,
                completion: completion
            )

        case .topRated:
            return moviesRepository.fetchTopRatedMovies(
                page: requestValue.page,
                completion: completion
            )

        case .upcoming:
            return moviesRepository.fetchUpcomingMovies(
                page: requestValue.page,
                completion: completion
            )
        }
    }
}

struct FetchSeeAllMoviesUseCaseRequestValue {
    let section: HomeSectionType
    let page: Int
}
