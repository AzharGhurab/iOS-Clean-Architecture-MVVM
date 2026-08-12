//
//  SeeAllViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 20/02/1448 AH.
//

import UIKit

final class SeeAllViewController: UIViewController {

    private var viewModel: SeeAllViewModel!
    private var posterImagesRepository: PosterImagesRepository?

    private var selectedGenreIndex = 0
    private var nextPageLoadingSpinner: UIActivityIndicatorView?
    private var canLoadNextPageFromUserScroll = false

    private let genresCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        return collectionView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.darkGray.withAlphaComponent(0.20)
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 100,
            bottom: 0,
            right: 20
        )

        return tableView
    }()

    private let emptyDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Found"
        label.textAlignment = .center
        label.isHidden = true

        return label
    }()
    
    private let genresTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Genres"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        return label
    }()

    static func create(
        with viewModel: SeeAllViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> SeeAllViewController {

        let viewController = SeeAllViewController()
        viewController.viewModel = viewModel
        viewController.posterImagesRepository = posterImagesRepository

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupGenresCollectionView()
        setupTableView()
        bind(to: viewModel)

        viewModel.viewDidLoad()
    }
}

// MARK: - Private

private extension SeeAllViewController {

    func setupView() {
        title = viewModel.title
        view.backgroundColor = .systemBackground

        view.addSubview(genresTitleLabel)
        view.addSubview(genresCollectionView)
        view.addSubview(tableView)
        view.addSubview(emptyDataLabel)

        NSLayoutConstraint.activate([
            genresTitleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            genresTitleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            genresCollectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            genresCollectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            genresCollectionView.heightAnchor.constraint(
                equalToConstant: 50
            ),

            tableView.topAnchor.constraint(
                equalTo: genresCollectionView.bottomAnchor,
                constant: 8
            ),
            genresCollectionView.topAnchor.constraint(
                equalTo: genresTitleLabel.bottomAnchor,
                constant: 12
            ),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupGenresCollectionView() {
        genresCollectionView.dataSource = self
        genresCollectionView.delegate = self

        genresCollectionView.register(
            UINib(
                nibName: "GenreCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: GenreCell.reuseIdentifier
        )
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.estimatedRowHeight = MoviesListItemCell.height

        tableView.separatorColor =
            UIColor.darkGray.withAlphaComponent(0.20)

        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 100,
            bottom: 0,
            right: 20
        )

        tableView.register(
            UINib(
                nibName: MoviesListItemCell.reuseIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier:
                MoviesListItemCell.reuseIdentifier
        )
    }

    func bind(to viewModel: SeeAllViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in
            self?.updateItems()
        }

        viewModel.genres.observe(on: self) { [weak self] _ in
            self?.genresCollectionView.reloadData()
        }

        viewModel.loading.observe(on: self) { [weak self] loading in
            self?.updateLoading(loading)
        }

        viewModel.error.observe(on: self) { [weak self] error in
            guard !error.isEmpty else {
                return
            }

            self?.showError(error)
        }
    }

    func updateItems() {
        tableView.reloadData()

        let isEmpty = viewModel.isEmpty
        tableView.isHidden = isEmpty
        emptyDataLabel.isHidden = !isEmpty
    }

    func updateLoading(_ loading: SeeAllViewModelLoading?) {
        switch loading {
        case .fullScreen:
            LoadingView.show()

        case .nextPage:
            LoadingView.hide()

            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(
                size: CGSize(
                    width: tableView.frame.width,
                    height: 44
                )
            )

            tableView.tableFooterView = nextPageLoadingSpinner

        case .none:
            LoadingView.hide()
            tableView.tableFooterView = nil
        }
    }

    func showError(_ message: String) {
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

// MARK: - UITableViewDataSource

extension SeeAllViewController: UITableViewDataSource {

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

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MoviesListItemCell.reuseIdentifier,
            for: indexPath
        ) as? MoviesListItemCell else {
            return UITableViewCell()
        }

        cell.fill(
            with: viewModel.items.value[indexPath.row],
            posterImagesRepository: posterImagesRepository
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SeeAllViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return viewModel.isEmpty
            ? tableView.frame.height
            : MoviesListItemCell.height
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        viewModel.didSelectItem(at: indexPath.row)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        canLoadNextPageFromUserScroll = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canLoadNextPageFromUserScroll else {
            return
        }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        guard contentHeight > frameHeight else {
            return
        }

        let threshold: CGFloat = 100

        guard offsetY + frameHeight >= contentHeight - threshold else {
            return
        }

        canLoadNextPageFromUserScroll = false
        viewModel.didLoadNextPage()
    }
}

// MARK: - UICollectionViewDataSource

extension SeeAllViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.genres.value.count + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GenreCell.reuseIdentifier,
            for: indexPath
        ) as? GenreCell else {
            return UICollectionViewCell()
        }

        if indexPath.item == 0 {
            cell.configure(with: "All")
        } else {
            let genre = viewModel.genres.value[indexPath.item - 1]
            cell.configure(with: genre.name)
        }

        let isSelected = indexPath.item == selectedGenreIndex

        cell.contentView.backgroundColor = isSelected
            ? UIColor(
                red: 0 / 255,
                green: 102 / 255,
                blue: 230 / 255,
                alpha: 1
            )
            : UIColor(
                red: 42 / 255,
                green: 42 / 255,
                blue: 46 / 255,
                alpha: 1
            )

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SeeAllViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selectedGenreIndex = indexPath.item
        collectionView.reloadData()

        viewModel.didSelectGenre(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SeeAllViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let title: String
        
        if indexPath.item == 0 {
            title = "All"
        } else {
            title = viewModel.genres.value[indexPath.item - 1].name
        }
        
        let font = UIFont.systemFont(
            ofSize: 13,
            weight: .medium
        )
        
        let textWidth = (title as NSString).size(
            withAttributes: [.font: font]
        ).width
        
        let horizontalPadding: CGFloat = 30
        
        return CGSize(
            width: textWidth + horizontalPadding,
            height: 30
        )
    }
}
