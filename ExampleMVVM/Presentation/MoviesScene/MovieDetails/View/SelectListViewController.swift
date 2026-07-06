//
//  SelectListViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 19/01/1448 AH.
//

import UIKit

final class SelectListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    var onListSelected: ((SelectListItem) -> Void)?
    var onExistingListFound: ((SelectListItem) -> Void)?

    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTasks: [IndexPath: Cancellable?] = [:]
    private var viewModel: SelectListViewModel!
    private var lists: [SelectListItem] = []
    private var selectedIndex: Int?

    static func create(
        with viewModel: SelectListViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> SelectListViewController {
        let view = SelectListViewController(
            nibName: "SelectListViewController",
            bundle: nil
        )
        view.viewModel = viewModel
        view.posterImagesRepository = posterImagesRepository
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 16)

        tableView.register(
            UINib(nibName: "SelectListTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SelectListTableViewCell"
        )
    }

    private func bind(to viewModel: SelectListViewModel) {
        viewModel.items.observe(on: self) { [weak self] lists in
            self?.lists = lists
            self?.selectedIndex = lists.firstIndex { $0.containsMovie }

            if let existingList = lists.first(where: { $0.containsMovie }) {
                self?.onExistingListFound?(existingList)
            }

            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension SelectListViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        lists.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SelectListTableViewCell",
            for: indexPath
        ) as? SelectListTableViewCell else {
            return UITableViewCell()
        }

        let item = lists[indexPath.row]

        cell.configure(
            title: item.name,
            moviesCount: item.itemCount,
            posterPath: item.posterPath,
            isSelected: selectedIndex == indexPath.row
        )

        if let posterPath = item.posterPath {
            imageLoadTasks[indexPath] = posterImagesRepository?.fetchImage(
                with: posterPath,
                width: 120
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

extension SelectListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let currentSelectedIndex = lists.firstIndex(where: { $0.containsMovie }),
           currentSelectedIndex != indexPath.row {
            return
        }

        selectedIndex = indexPath.row
        tableView.reloadData()

        let selectedList = lists[indexPath.row]
        onListSelected?(selectedList)
    }
}
