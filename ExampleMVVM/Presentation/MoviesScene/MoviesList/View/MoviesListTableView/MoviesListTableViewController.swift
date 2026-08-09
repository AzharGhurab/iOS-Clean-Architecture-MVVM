import UIKit

final class MoviesListTableViewController: UITableViewController {

    var viewModel: MoviesListViewModel!

    var posterImagesRepository: PosterImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?
    var emptyDataLabel: UILabel?

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

        if indexPath.row == viewModel.items.value.count - 1 {
            viewModel.didLoadNextPage()
        }

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
}
