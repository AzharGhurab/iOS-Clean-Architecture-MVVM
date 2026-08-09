//
//  CreateListDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//

import Foundation

struct CreateListRequestDTO: Encodable {
    let name: String
    let description: String
    let language: String
}

struct CreateListResponseDTO: Decodable {
    let success: Bool
    let statusCode: Int?
    let statusMessage: String?

    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}
