//
//  KeychainAuthenticationStorage.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 05/02/1448 AH.
//

import Foundation

final class KeychainAuthenticationStorage: AuthenticationStorage {

    private enum Key {
        static let sessionId = "session_id"
        static let guestSessionId = "guest_session_id"
        static let accountId = "account_id"
    }

    private let keychainStorage: KeychainStorage

    init(keychainStorage: KeychainStorage = .shared) {
        self.keychainStorage = keychainStorage
    }

    func sessionId() -> String? {
        keychainStorage.read(forKey: Key.sessionId)
    }

    func guestSessionId() -> String? {
        keychainStorage.read(forKey: Key.guestSessionId)
    }

    func accountId() -> Int? {
        guard
            let value = keychainStorage.read(forKey: Key.accountId),
            let accountId = Int(value)
        else {
            return nil
        }

        return accountId
    }

    func save(sessionId: String) {
        keychainStorage.save(
            sessionId,
            forKey: Key.sessionId
        )
    }

    func save(guestSessionId: String) {
        keychainStorage.save(
            guestSessionId,
            forKey: Key.guestSessionId
        )
    }

    func save(accountId: Int) {
        keychainStorage.save(
            String(accountId),
            forKey: Key.accountId
        )
    }

    func clearSession() {
        keychainStorage.delete(forKey: Key.sessionId)
    }

    func clearGuestSession() {
        keychainStorage.delete(forKey: Key.guestSessionId)
    }

    func clearAccountId() {
        keychainStorage.delete(forKey: Key.accountId)
    }
}
