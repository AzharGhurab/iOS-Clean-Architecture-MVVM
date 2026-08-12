import UIKit

final class MoviesListTableViewController: UITableViewController {

    var viewModel: MoviesListViewModel!

    var posterImagesRepository: PosterImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?
    var emptyDataLabel: UILabel?
    private var canLoadNextPageFromUserScroll = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func reload() {
        tableView.reloadData()
        emptyDataLabel?.isHidden = !viewModel.items.value.isEmpty
    }

    func updateLoading(_ loading: MoviesListViewModelLoading?) {
        switch loading {
        case .nextPage:
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        case .fullScreen, .none:
            tableView.tableFooterView = nil
        }
    }

    // MARK: - Private

    private func setupViews() {
        tableView.register(
            UINib(
                nibName: MoviesListItemCell.reuseIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: MoviesListItemCell.reuseIdentifier
        )

        tableView.estimatedRowHeight = MoviesListItemCell.height
        tableView.separatorColor = UIColor.darkGray.withAlphaComponent(0.20)

           tableView.separatorInset = UIEdgeInsets(
               top: 0,
               left: 100,
               bottom: 0,
               right: 20
               )
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesListTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MoviesListItemCell.reuseIdentifier,
            for: indexPath
        ) as? MoviesListItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(MoviesListItemCell.self) with reuseIdentifier: \(MoviesListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }

        cell.fill(with: viewModel.items.value[indexPath.row],
                  posterImagesRepository: posterImagesRepository)

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.isEmpty
            ? tableView.frame.height
            : MoviesListItemCell.height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView
    ) {
        canLoadNextPageFromUserScroll = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canLoadNextPageFromUserScroll else {
            return
        }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        guard contentHeight > 0 else {
            return
        }

        let threshold: CGFloat = 100

        if offsetY + frameHeight >= contentHeight - threshold {
            canLoadNextPageFromUserScroll = false
            viewModel.didLoadNextPage()
        }
    }
}
