//
//  AuthenticationStorage.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

protocol AuthenticationStorage {
    func sessionId() -> String?
    func guestSessionId() -> String?

    func save(sessionId: String)
    func save(guestSessionId: String)

    func clearSession()
    func clearGuestSession()
}
