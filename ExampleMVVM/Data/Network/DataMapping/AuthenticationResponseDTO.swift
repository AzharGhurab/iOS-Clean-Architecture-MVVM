//
//  AuthenticationResponseDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 29/12/1447 AH.
//

import Foundation

struct GuestSessionResponseDTO: Decodable {
    let success: Bool
    let guestSessionId: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case success
        case guestSessionId = "guest_session_id"
        case expiresAt = "expires_at"
    }
}

struct RequestTokenResponseDTO: Decodable {
    let success: Bool
    let requestToken: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case success
        case requestToken = "request_token"
        case expiresAt = "expires_at"
    }
}

struct SessionResponseDTO: Decodable {
    let success: Bool
    let sessionId: String

    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
}
