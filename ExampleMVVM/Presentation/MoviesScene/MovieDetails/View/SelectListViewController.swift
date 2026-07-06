//
//  SelectListViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 19/01/1448 AH.
//

import UIKit

final class SelectListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var doneButton: UIButton!
    
    var onDone: ((SelectListItem) -> Void)?
    var onExistingListFound: ((SelectListItem) -> Void)?
    
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTasks: [IndexPath: Cancellable?] = [:]
    private var viewModel: SelectListViewModel!
    private var lists: [SelectListItem] = []
    private var selectedIndex: Int?
    private var selectedList: SelectListItem?
    
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
        updateDoneButton()
    }
    
    @IBAction private func doneButtonTapped(_ sender: UIButton) {
        guard let selectedList else { return }
        
        if let selectedIndex {
            lists[selectedIndex] = SelectListItem(
                id: selectedList.id,
                name: selectedList.name,
                itemCount: selectedList.itemCount,
                posterPath: selectedList.posterPath,
                containsMovie: false
            )
            
            self.selectedIndex = nil
            self.selectedList = nil
            tableView.reloadData()
        }
        
        onDone?(selectedList)
    }
    
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 16)
        tableView.contentInset.bottom = 80
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.isEnabled = false
        doneButton.backgroundColor = .systemGray4
        doneButton.setTitleColor(.white, for: .normal)
        
        tableView.register(
            UINib(nibName: "SelectListTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SelectListTableViewCell"
        )
    }

    private func bind(to viewModel: SelectListViewModel) {
        viewModel.items.observe(on: self) { [weak self] lists in
            guard let self = self else { return }
            
            self.lists = lists
            self.selectedIndex = lists.firstIndex { $0.containsMovie }
            
            if let selectedIndex = self.selectedIndex {
                self.selectedList = lists[selectedIndex]
            } else {
                self.selectedList = nil
            }
            
            if let existingList = lists.first(where: { $0.containsMovie }) {
                self.onExistingListFound?(existingList)
            }
            
            self.updateDoneButton()
            self.tableView.reloadData()
        }
    }
    private func updateDoneButton() {
        let hasSelection = selectedList != nil
        
        doneButton.isEnabled = hasSelection
        doneButton.backgroundColor = hasSelection ? .systemBlue : .systemGray4
        doneButton.setTitleColor(.white, for: .normal)
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
        if selectedIndex == indexPath.row {
            selectedIndex = nil
            selectedList = nil
        } else {
            selectedIndex = indexPath.row
            selectedList = lists[indexPath.row]
        }

        updateDoneButton()
        tableView.reloadData()
    }
}
