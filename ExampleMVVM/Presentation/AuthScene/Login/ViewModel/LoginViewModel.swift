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
    var error: Observable<String?> { get }
    var authenticationState: Observable<AuthenticationState?> { get }
}

protocol LoginViewModel: LoginViewModelInput, LoginViewModelOutput { }

final class DefaultLoginViewModel: LoginViewModel {

    let error: Observable<String?> = Observable(nil)
    let authenticationState: Observable<AuthenticationState?> = Observable(nil)

    private let createGuestSessionUseCase: CreateGuestSessionUseCase
    private let createRequestTokenUseCase: CreateRequestTokenUseCase
    private let createSessionUseCase: CreateSessionUseCase
    private let authenticationStorage: AuthenticationStorage
    private let actions: LoginViewModelActions?

    private var authenticationTask: Cancellable? {
        willSet { authenticationTask?.cancel() }
    }

    init(
        createGuestSessionUseCase: CreateGuestSessionUseCase,
        createRequestTokenUseCase: CreateRequestTokenUseCase,
        createSessionUseCase: CreateSessionUseCase,
        authenticationStorage: AuthenticationStorage,
        actions: LoginViewModelActions?
    ) {
        self.createGuestSessionUseCase = createGuestSessionUseCase
        self.createRequestTokenUseCase = createRequestTokenUseCase
        self.createSessionUseCase = createSessionUseCase
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
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }

    func signIn() {
        authenticationTask = createRequestTokenUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requestToken):
                    self?.actions?.showAuthorize(requestToken)

                case .failure(let error):
                    self?.authenticationState.value = .failed(error: error)
                    self?.error.value = error.localizedDescription
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
                    self?.authenticationState.value = .loggedIn(sessionId: sessionId)
                    self?.actions?.showProfile()

                case .failure(let error):
                    self?.authenticationState.value = .failed(error: error)
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }
}

