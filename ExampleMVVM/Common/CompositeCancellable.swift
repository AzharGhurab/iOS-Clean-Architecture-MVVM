//
//  CompositeCancellable.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 17/12/1447 AH.
//

import Foundation
 final class CompositeCancellable: Cancellable {
    
    private let tasks: [Cancellable?]
    
    init(tasks: [Cancellable?]) {
        self.tasks = tasks
    }
    
    func cancel() {
        tasks.forEach { $0?.cancel() }
    }
}
