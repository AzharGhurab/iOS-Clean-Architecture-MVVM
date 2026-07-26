//
//  MovieSelectionType.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 05/02/1448 AH.
//

import Foundation

enum MovieSelectionType {
    case list(listId: Int)
    case favorites
    case watchlist

    var title: String {
        switch self {
            
        case .list:
            return "List Details"
            
        case .favorites:
            return "Favorites"

        case .watchlist:
            return "Watchlist"
        }
    }
}
