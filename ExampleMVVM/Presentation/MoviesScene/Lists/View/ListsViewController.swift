//
//  ListsViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 14/01/1448 AH.
//

import UIKit

final class ListsViewController: UIViewController, StoryboardInstantiable{
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var viewModel: ListsViewModel!
    private var onCreateList: (() -> Void)?
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTasks: [IndexPath: Cancellable?] = [:]
    
    static func create(
        with viewModel: ListsViewModel,
        onCreateList: @escaping () -> Void,
        posterImagesRepository: PosterImagesRepository?
    ) -> ListsViewController {
        let view = ListsViewController.instantiateViewController()
        view.viewModel = viewModel
        view.onCreateList = onCreateList
        view.posterImagesRepository = posterImagesRepository
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Lists"
        setupNavigationBar()
        setupTableView()
        bind(to: viewModel)
        
        viewModel.viewDidLoad()
    }
    
    @objc private func addButtonTapped() {
        onCreateList?()
    }
    func refreshLists() {
        viewModel.refresh()
    }
}

// MARK: - Private

private extension ListsViewController {
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    func setupTableView() {
        tableView.register(
            UINib(nibName: "ListsItemCell", bundle: nil),
            forCellReuseIdentifier: "ListsItemCell"
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 124
    }
    
    func bind(to viewModel: ListsViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    func showDeleteConfirmation(at indexPath: IndexPath) {

        let list = viewModel.items.value[indexPath.row]

        let viewController = DeleteListConfirmationViewController.create(
            listName: list.name
        ) { [weak self] in
            self?.viewModel.deleteList(at: indexPath.row)
        }

        present(viewController, animated: true)
    }
}
// MARK: - UITableViewDataSource

extension ListsViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.items.value.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListsItemCell",
            for: indexPath
        ) as! ListsItemCell
        
        let item = viewModel.items.value[indexPath.row]
        cell.configure(
            title: item.name,
            description: item.description,
            count: "\(item.itemCount) items",
            image: nil
        )
        
        if let posterPath = item.posterPath {
            imageLoadTasks[indexPath] = posterImagesRepository?.fetchImage(
                
                with: posterPath,
                width: 200
            ) { result in
                DispatchQueue.main.async {
                    guard
                        let currentIndexPath = tableView.indexPath(for: cell),
                        currentIndexPath == indexPath
                    else { return }
                    
                    if case let .success(data) = result {
                        cell.updatePosterImage(UIImage(data: data))
                    }
                }
            }
        }
        
        return cell
    }
}
    // MARK: - UITableViewDelegate

extension ListsViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectList(at: indexPath.row)
    }
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            self?.showDeleteConfirmation(at: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    }

