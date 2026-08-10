//
//  ProfileViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 14/01/1448 AH.
//

import Foundation

enum ProfileUserType: Equatable {
    case guest
    case signedIn
    case unauthenticated
}

struct ProfileViewModelActions {
    let showLogin: () -> Void
    let showLists: () -> Void
    let showFavorites: () -> Void
    let showWatchlist: () -> Void
    let showLoggedOut: () -> Void
}

protocol ProfileViewModelInput {
    func viewDidLoad()
    func signIn()

    func didSelectLists()
    func didSelectFavorites()
    func didSelectWatchlist()

    func logout()
}

protocol ProfileViewModelOutput {
    var userType: Observable<ProfileUserType> { get }
    var username: Observable<String> { get }
}

protocol ProfileViewModel:
    ProfileViewModelInput,
    ProfileViewModelOutput { }

final class DefaultProfileViewModel: ProfileViewModel {

    let userType: Observable<ProfileUserType> =
        Observable(.unauthenticated)

    let username: Observable<String> =
        Observable("")

    private let authenticationStorage: AuthenticationStorage
    private let fetchAccountUseCase: FetchAccountUseCase
    private let actions: ProfileViewModelActions?
    private let movieDetailsRepository: MovieDetailsRepository

    private var accountTask: Cancellable? {
        willSet {
            accountTask?.cancel()
        }
    }

    init(
        authenticationStorage: AuthenticationStorage,
        fetchAccountUseCase: FetchAccountUseCase,
        movieDetailsRepository: MovieDetailsRepository,
        actions: ProfileViewModelActions?
    ) {
        self.authenticationStorage = authenticationStorage
        self.fetchAccountUseCase = fetchAccountUseCase
        self.movieDetailsRepository = movieDetailsRepository
        self.actions = actions
    }

    func viewDidLoad() {
        if authenticationStorage.sessionId() != nil {
            userType.value = .signedIn
            fetchAccount()

        } else if authenticationStorage.guestSessionId() != nil {
            userType.value = .guest
            username.value = "Guest User"

        } else {
            userType.value = .unauthenticated
            username.value = "Guest User"
        }
    }

    func signIn() {
        actions?.showLogin()
    }

    func didSelectLists() {
        guard userType.value == .signedIn else {
            actions?.showLogin()
            return
        }

        actions?.showLists()
    }

    func didSelectFavorites() {
        guard userType.value == .signedIn else {
            actions?.showLogin()
            return
        }

        actions?.showFavorites()
    }

    func didSelectWatchlist() {
        guard userType.value == .signedIn else {
            actions?.showLogin()
            return
        }

        actions?.showWatchlist()
    }

    func logout() {
        
        accountTask?.cancel()
        authenticationStorage.clearSession()
        authenticationStorage.clearGuestSession()
        authenticationStorage.clearAccountId()
        
        movieDetailsRepository.clearCache()

        username.value = ""
        userType.value = .unauthenticated
        actions?.showLoggedOut()
    }
}

// MARK: - Private

private extension DefaultProfileViewModel {

    func fetchAccount() {
        accountTask = fetchAccountUseCase.execute { [weak self] result in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    self.username.value = account.username

                case .failure:
                    self.username.value = "TMDB User"
                }
            }
        }
    }
}
