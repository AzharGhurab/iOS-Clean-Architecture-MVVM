//
//  AccountResponseDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 17/01/1448 AH.
//

import Foundation

extension AccountResponseDTO {

    func toDomain() -> Account {
        Account(
            id: id,
            username: username
        )
    }
}
