//
//  UserDefaultsAuthenticationRepository.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

final class UserDefaultsAuthenticationStorage: AuthenticationStorage {

    private let sessionIdKey = "session_id"
    private let guestSessionIdKey = "guest_session_id"

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func sessionId() -> String? {
        userDefaults.string(forKey: sessionIdKey)
    }

    func guestSessionId() -> String? {
        userDefaults.string(forKey: guestSessionIdKey)
    }

    func save(sessionId: String) {
        userDefaults.set(sessionId, forKey: sessionIdKey)
    }

    func save(guestSessionId: String) {
        userDefaults.set(guestSessionId, forKey: guestSessionIdKey)
    }

    func clearSession() {
        userDefaults.removeObject(forKey: sessionIdKey)
    }

    func clearGuestSession() {
        userDefaults.removeObject(forKey: guestSessionIdKey)
    }
}
