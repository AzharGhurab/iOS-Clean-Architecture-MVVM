//
//  FetchHomeMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 19/11/1447 AH.
//
import Foundation

protocol FetchHomeMoviesUseCase {
    func execute(
        completion: @escaping (Result<HomeMovies, Error>) -> Void
    ) -> Cancellable?
}

struct HomeMovies {
    let nowPlaying: [Movie]
    let popular: [Movie]
    let topRated: [Movie]
    let upcoming: [Movie]
}

final class DefaultFetchHomeMoviesUseCase: FetchHomeMoviesUseCase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(
        completion: @escaping (Result<HomeMovies, Error>) -> Void
    ) -> Cancellable? {
        
        let dispatchGroup = DispatchGroup()
        
        var nowPlayingResult: Result<MoviesPage, Error>?
        var popularResult: Result<MoviesPage, Error>?
        var topRatedResult: Result<MoviesPage, Error>?
        var upcomingResult: Result<MoviesPage, Error>?
        
        dispatchGroup.enter()
        let nowPlayingTask = moviesRepository.fetchNowPlayingMovies(page: 1) { result in
            nowPlayingResult = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let popularTask = moviesRepository.fetchPopularMovies(page: 1) { result in
            popularResult = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let topRatedTask = moviesRepository.fetchTopRatedMovies(page: 1) { result in
            topRatedResult = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let upcomingTask = moviesRepository.fetchUpcomingMovies(page: 1) { result in
            upcomingResult = result
            dispatchGroup.leave()
        }
        
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            if case .failure(let error) = nowPlayingResult {
                completion(.failure(error))
                return
            }
            
            if case .failure(let error) = popularResult {
                completion(.failure(error))
                return
            }
            
            if case .failure(let error) = topRatedResult {
                completion(.failure(error))
                return
            }
            
            if case .failure(let error) = upcomingResult {
                completion(.failure(error))
                return
            }
            
            let homeMovies = HomeMovies(
                nowPlaying: nowPlayingResult?.value?.movies ?? [],
                popular: popularResult?.value?.movies ?? [],
                topRated: topRatedResult?.value?.movies ?? [],
                upcoming: upcomingResult?.value?.movies ?? []
            )
            
            completion(.success(homeMovies))
        }
        
        return CompositeCancellable(tasks: [
            nowPlayingTask,
            popularTask,
            topRatedTask,
            upcomingTask
        ])
    }
}

private extension Result where Success == MoviesPage, Failure == Error {
    
    var value: MoviesPage? {
        guard case .success(let value) = self else { return nil }
        return value
    }
}
