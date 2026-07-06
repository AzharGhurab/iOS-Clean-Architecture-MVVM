//
//  ProfileViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 14/01/1448 AH.
//

import Foundation

struct ProfileViewModelActions {
    let showLogin: () -> Void
    let showLists: () -> Void
    }
protocol ProfileViewModelInput {
    func signIn()
    func didSelectLists()
}

protocol ProfileViewModelOutput { }

protocol ProfileViewModel: ProfileViewModelInput, ProfileViewModelOutput { }

final class DefaultProfileViewModel: ProfileViewModel {

    private let actions: ProfileViewModelActions?

    init(actions: ProfileViewModelActions?) {
        self.actions = actions
    }

    func signIn() {
        actions?.showLogin()
    }
    func didSelectLists() {
        actions?.showLists()
    }
}
