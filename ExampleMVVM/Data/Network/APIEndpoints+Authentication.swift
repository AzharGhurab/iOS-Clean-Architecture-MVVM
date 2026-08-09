//
//  APIEndpoints+Authentication.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 28/01/1448 AH.
//

import Foundation

extension APIEndpoints {

    static func createGuestSession() -> Endpoint<GuestSessionResponseDTO> {
        return Endpoint(
            path: "3/authentication/guest_session/new",
            method: .get
        )
    }

    static func createRequestToken() -> Endpoint<RequestTokenResponseDTO> {
        return Endpoint(
            path: "3/authentication/token/new",
            method: .get
        )
    }

    static func createSession(
        requestToken: String
    ) -> Endpoint<SessionResponseDTO> {
        return Endpoint(
            path: "3/authentication/session/new",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            bodyParameters: [
                Parameter.requestToken: requestToken
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }

    static func getAccountDetails(
        sessionId: String
    ) -> Endpoint<AccountResponseDTO> {
        return Endpoint(
            path: "3/account",
            method: .get,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }
}
