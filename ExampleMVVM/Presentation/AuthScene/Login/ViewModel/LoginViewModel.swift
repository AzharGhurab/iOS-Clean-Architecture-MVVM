//
//  LoginViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

struct LoginViewModelActions {
    let showProfile: () -> Void
    let showAuthorize: (String) -> Void
}

protocol LoginViewModelInput {
    func continueAsGuest()
    func signIn()
    func createSession(requestToken: String)
}

protocol LoginViewModelOutput {
    var authenticationState: Observable<AuthenticationState?> { get }
}

protocol LoginViewModel: LoginViewModelInput, LoginViewModelOutput { }

final class DefaultLoginViewModel: LoginViewModel {

    let authenticationState: Observable<AuthenticationState?> = Observable(nil)

    private let createGuestSessionUseCase: CreateGuestSessionUseCase
    private let createRequestTokenUseCase: CreateRequestTokenUseCase
    private let createSessionUseCase: CreateSessionUseCase
    private let authenticationStorage: AuthenticationStorage
    private let actions: LoginViewModelActions?
    private let fetchAccountUseCase: FetchAccountUseCase

    private var authenticationTask: Cancellable? {
        willSet { authenticationTask?.cancel() }
    }

    init(
        createGuestSessionUseCase: CreateGuestSessionUseCase,
        createRequestTokenUseCase: CreateRequestTokenUseCase,
        createSessionUseCase: CreateSessionUseCase,
        fetchAccountUseCase: FetchAccountUseCase,
        authenticationStorage: AuthenticationStorage,
        actions: LoginViewModelActions?
    ) {
        self.createGuestSessionUseCase = createGuestSessionUseCase
        self.createRequestTokenUseCase = createRequestTokenUseCase
        self.createSessionUseCase = createSessionUseCase
        self.fetchAccountUseCase = fetchAccountUseCase
        self.authenticationStorage = authenticationStorage
        self.actions = actions
    }

    func continueAsGuest() {
        authenticationTask = createGuestSessionUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let guestSessionId):
                    self?.authenticationStorage.save(guestSessionId: guestSessionId)
                    self?.authenticationState.value = .guest(guestSessionId: guestSessionId)
                    self?.actions?.showProfile()

                case .failure(let error):
                    self?.authenticationState.value = .failed(error: error)
                }
            }
        }
    }

    func signIn() {
        authenticationTask = createRequestTokenUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requestToken):
                    self?.authenticationState.value =
                           .authorizationRequired(requestToken: requestToken)
                    self?.actions?.showAuthorize(requestToken)

                case .failure(let error):
                    self?.authenticationState.value = .failed(error: error)
                }
            }
        }
    }
    func createSession(requestToken: String) {
        authenticationTask = createSessionUseCase.execute(
            requestValue: CreateSessionUseCaseRequestValue(requestToken: requestToken)
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sessionId):
                    self?.authenticationStorage.save(sessionId: sessionId)

                    self?.fetchAccountUseCase.execute { accountResult in
                        DispatchQueue.main.async {
                            switch accountResult {
                            case .success:
                                self?.authenticationState.value = .loggedIn(sessionId: sessionId)
                                self?.actions?.showProfile()

                            case .failure(let error):
                                self?.authenticationState.value = .failed(error: error)
                            }
                        }
                    }

                case .failure(let error):
                    self?.authenticationState.value = .failed(error: error)
                }
            }
        }
    }
}

