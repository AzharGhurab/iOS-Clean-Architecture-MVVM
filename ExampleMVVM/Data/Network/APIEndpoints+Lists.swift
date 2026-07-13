//
//  APIEndpoints+Lists.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 28/01/1448 AH.
//

import Foundation

extension APIEndpoints {

    static func getLists(
        accountId: Int,
        sessionId: String
    ) -> Endpoint<MovieListsResponseDTO> {
        return Endpoint(
            path: "3/account/\(accountId)/lists",
            method: .get,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }

    static func createList(
        requestDTO: CreateListRequestDTO,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParameters: [
                "name": requestDTO.name,
                "description": requestDTO.description,
                "language": requestDTO.language
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }

    static func getListDetails(
        listId: Int
    ) -> Endpoint<ListDetailsResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)",
            method: .get
        )
    }

    static func deleteList(
        listId: Int,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)",
            method: .delete,
            queryParameters: [
                "session_id": sessionId
            ]
        )
    }

    static func addMovieToList(
        listId: Int,
        movieId: String,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)/add_item",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParameters: [
                "media_id": movieId
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }

    static func removeMovieFromList(
        listId: Int,
        movieId: String,
        sessionId: String
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)/remove_item",
            method: .post,
            headerParameters: [
                Header.contentType: Header.applicationJSON
            ],
            queryParameters: [
                "session_id": sessionId
            ],
            bodyParameters: [
                "media_id": movieId
            ],
            bodyEncoder: JSONBodyEncoder()
        )
    }
}
