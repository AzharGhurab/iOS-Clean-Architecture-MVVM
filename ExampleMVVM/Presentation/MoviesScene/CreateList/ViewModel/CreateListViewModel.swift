//
//  CreateListViewModel.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 14/01/1448 AH.
//

import Foundation

struct CreateListViewModelActions {
    let didCreateList: () -> Void
}

protocol CreateListViewModelInput {
    func createList(name: String, description: String)
}

protocol CreateListViewModelOutput {
    var loading: Observable<Bool> { get }
    var error: Observable<String?> { get }
}
protocol CreateListViewModel: CreateListViewModelInput, CreateListViewModelOutput { }

final class DefaultCreateListViewModel: CreateListViewModel {
    
    private let createListUseCase: CreateListUseCase
    private let actions: CreateListViewModelActions?
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<String?> = Observable(nil)
    
    private var createListTask: Cancellable? {
        willSet { createListTask?.cancel() }
    }
    
    init(
        createListUseCase: CreateListUseCase,
        actions: CreateListViewModelActions?
    ) {
        self.createListUseCase = createListUseCase
        self.actions = actions
    }
    
    func createList(name: String, description: String) {
        loading.value = true
        
        let requestValue = CreateListUseCaseRequestValue(
            name: name,
            description: description
        )
        
        createListTask = createListUseCase.execute(
            requestValue: requestValue
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loading.value = false
                
                switch result {
                case .success:
                    self?.actions?.didCreateList()
                    
                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    }
}
