//
//  AuthenticationRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

protocol AuthenticationRepository {
    func createGuestSession(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?

    func createRequestToken(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?

    func createSession(
        requestToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
    
    func fetchAccount(
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable?
}
