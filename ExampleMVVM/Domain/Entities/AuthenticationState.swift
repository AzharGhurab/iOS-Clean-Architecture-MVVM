//
//  AuthenticationState.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/01/1448 AH.
//

import Foundation

enum AuthenticationState {
    case guest(guestSessionId: String)
    case authorizationRequired(requestToken: String)
    case loggedIn(sessionId: String)
    case failed(error: Error)
}
