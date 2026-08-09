//
//  MovieSelectionViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/01/1448 AH.
//


import UIKit

final class MovieSelectionViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!

    private var viewModel: MovieSelectionViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTasks: [IndexPath: Cancellable] = [:]

    private lazy var editButton = UIBarButtonItem(
        title: "Edit",
        style: .plain,
        target: self,
        action: #selector(didTapEdit)
    )

    private lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Delete",
            style: .plain,
            target: self,
            action: #selector(didTapDelete)
        )
        button.tintColor = .systemRed
        return button
    }()

    static func create(
        with viewModel: MovieSelectionViewModel,
        posterImagesRepository: PosterImagesRepository?,
        title: String
    ) -> MovieSelectionViewController {

        let viewController = MovieSelectionViewController(
            nibName: "MovieSelectionViewController",
            bundle: nil
        )

        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository
        viewController.title = title

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupCollectionView()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    deinit {
        cancelImageLoadTasks()
    }
}

// MARK: - Setup

private extension MovieSelectionViewController {

    func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = editButton
    }

    func setupCollectionView() {
        collectionView.register(
            UINib(
                nibName: "MovieSelectionCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "MovieSelectionCollectionViewCell"
        )

        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
    }
}

// MARK: - Binding

private extension MovieSelectionViewController {

    func bind(to viewModel: MovieSelectionViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in
            guard let self else { return }

            self.cancelImageLoadTasks()
            self.collectionView.reloadData()
            self.editButton.isEnabled = !viewModel.items.value.isEmpty
        }

        viewModel.isEditing.observe(on: self) { [weak self] isEditing in
            guard let self else { return }
            self.updateEditingMode(isEditing)
        }

        viewModel.selectedMovieIds.observe(on: self) { [weak self] _ in
            guard let self else { return }

            self.updateNavigationButton()
            self.collectionView.reloadData()
        }

        viewModel.loading.observe(on: self) { loading in
            print("Movie selection loading:", loading)
        }

        viewModel.error.observe(on: self) { [weak self] errorMessage in
            guard
                let self,
                let errorMessage
            else {
                return
            }

            self.showError(message: errorMessage)
        }
    }

    func updateEditingMode(_ isEditing: Bool) {
        collectionView.allowsMultipleSelection = isEditing

        if !isEditing {
            collectionView.indexPathsForSelectedItems?.forEach {
                collectionView.deselectItem(
                    at: $0,
                    animated: false
                )
            }
        }

        updateNavigationButton()
        collectionView.reloadData()
    }

    func updateNavigationButton() {
        let isEditing = viewModel.isEditing.value
        let hasSelection = !viewModel.selectedMovieIds.value.isEmpty

        if isEditing && hasSelection {
            navigationItem.rightBarButtonItem = deleteButton
        } else {
            editButton.title = isEditing ? "Cancel" : "Edit"
            navigationItem.rightBarButtonItem = editButton
        }
    }
}

// MARK: - Actions

private extension MovieSelectionViewController {

    @objc func didTapEdit() {
        if viewModel.isEditing.value {
            viewModel.didTapCancel()
        } else {
            viewModel.didTapEdit()
        }
    }

    @objc func didTapDelete() {
        let alert = UIAlertController(
            title: "Delete Movies",
            message: "Are you sure you want to delete the selected movie?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.didTapDelete()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(alert, animated: true)
    }

    func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }
}

// MARK: - Poster Loading

private extension MovieSelectionViewController {

    func loadPoster(
        for item: MovieSelectionMovie,
        at indexPath: IndexPath,
        into cell: MovieSelectionCollectionViewCell
    ) {
        imageLoadTasks[indexPath]?.cancel()
        imageLoadTasks[indexPath] = nil

        guard let posterPath = item.posterPath else {
            cell.updatePosterImage(nil)
            return
        }

        guard let task = posterImagesRepository?.fetchImage(
            with: posterPath,
            width: 200,
            completion: { [weak self, weak collectionView, weak cell] result in
                DispatchQueue.main.async {
                    guard
                        let self,
                        let collectionView,
                        let cell,
                        let currentIndexPath = collectionView.indexPath(for: cell),
                        currentIndexPath == indexPath
                    else {
                        return
                    }

                    self.imageLoadTasks[indexPath] = nil

                    switch result {
                    case .success(let data):
                        cell.updatePosterImage(UIImage(data: data))

                    case .failure:
                        cell.updatePosterImage(nil)
                    }
                }
            }
        ) else {
            return
        }

        imageLoadTasks[indexPath] = task
    }

    func cancelImageLoadTasks() {
        imageLoadTasks.values.forEach { $0.cancel() }
        imageLoadTasks.removeAll()
    }
}

// MARK: - UICollectionViewDataSource

extension MovieSelectionViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.items.value.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MovieSelectionCollectionViewCell",
            for: indexPath
        ) as? MovieSelectionCollectionViewCell else {
            return UICollectionViewCell()
        }

        guard viewModel.items.value.indices.contains(indexPath.item) else {
            return cell
        }

        let item = viewModel.items.value[indexPath.item]
        let isSelected = viewModel.selectedMovieIds.value.contains(item.id)

        cell.configure(
            title: item.title,
            image: nil,
            isEditing: viewModel.isEditing.value,
            isSelected: isSelected
        )

        loadPoster(
            for: item,
            at: indexPath,
            into: cell
        )

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MovieSelectionViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard viewModel.isEditing.value else {
            collectionView.deselectItem(
                at: indexPath,
                animated: false
            )
            return
        }

        viewModel.didSelectMovie(at: indexPath.item)

        collectionView.deselectItem(
            at: indexPath,
            animated: false
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        imageLoadTasks[indexPath]?.cancel()
        imageLoadTasks[indexPath] = nil
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MovieSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let columns: CGFloat = 3
        let horizontalInset: CGFloat = 24
        let interitemSpacing: CGFloat = 8

        let availableWidth =
            collectionView.bounds.width
            - horizontalInset * 2
            - interitemSpacing * (columns - 1)

        let width = availableWidth / columns

        return CGSize(
            width: width,
            height: width * 1.5 + 28
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 8,
            left: 24,
            bottom: 8,
            right: 24
        )
    }
}
