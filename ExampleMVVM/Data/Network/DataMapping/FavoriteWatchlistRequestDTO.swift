//
//  FavoriteWatchlistRequestDTO.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 06/02/1448 AH.
//

import Foundation

struct FavoriteRequestDTO {
    let mediaType: String
    let mediaId: Int
    let favorite: Bool
}

extension FavoriteRequestDTO: Encodable {

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case favorite
    }
}

struct WatchlistRequestDTO {
    let mediaType: String
    let mediaId: Int
    let watchlist: Bool
}

extension WatchlistRequestDTO: Encodable {

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case watchlist
    }
}
