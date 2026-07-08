import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var watchlistButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private var overviewTextView: UITextView!
    @IBOutlet private weak var addToListButton: UIButton!
    
    // MARK: - Lifecycle

    private var viewModel: MovieDetailsViewModel!
    var makeSelectListViewController: (() -> SelectListViewController)?
    
    static func create(
        with viewModel: MovieDetailsViewModel,
        makeSelectListViewController: (() -> SelectListViewController)?
    ) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        view.makeSelectListViewController = makeSelectListViewController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self]in
            self?.posterImageView.image = $0.flatMap(UIImage.init)
        }
        viewModel.isFavorite.observe(on: self) { [weak self] isFavorite in
            self?.updateFavoriteButton(isFavorite: isFavorite)
        }
        
        viewModel.isInWatchlist.observe(on: self) { [weak self] isInWatchlist in
            self?.updateWatchlistButton(isInWatchlist: isInWatchlist)
        }
        viewModel.isAddedToList.observe(on: self) { [weak self] isAdded in
            self?.updateAddToListButton(isAdded: isAdded)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }
    
    // MARK: - Private
    
    private func setupViews() {
        title = viewModel.title
        overviewTextView.text = viewModel.overview
        posterImageView.isHidden = viewModel.isPosterImageHidden
        ratingLabel.text = "⭐️ \(viewModel.rating)"
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
        configureActionButton(
            favoriteButton,
            image: UIImage(named: "heart"),
            title: "Add Favorite",
            color: .systemGray
        )
        
        configureActionButton(
            watchlistButton,
            image: UIImage(systemName: "bookmark"),
            title: "Add Watchlist",
            color: .systemGray
        )
        
        updateAddToListButton(isAdded: false)
    }
    private func configureActionButton(
        _ button: UIButton,
        image: UIImage?,
        title: String,
        color: UIColor
    ) {
        var config = UIButton.Configuration.plain()
        config.image = image
        config.title = title
        config.imagePlacement = .top
        config.imagePadding = 8

        button.configuration = config
        button.tintColor = color
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        var config = UIButton.Configuration.plain()

        config.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")

        config.attributedTitle = AttributedString(
            isFavorite ? "Added Favorite" : "Add Favorite",
            attributes: AttributeContainer([
                .foregroundColor: UIColor.black
            ])
        )

        config.imagePlacement = .top
        config.imagePadding = 8

        favoriteButton.configuration = config
        favoriteButton.tintColor = .systemRed
    }
    private func updateWatchlistButton(isInWatchlist: Bool) {
        let image = isInWatchlist
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        
        var config = UIButton.Configuration.plain()
        config.image = image
        config.title = isInWatchlist ? "Added Watchlist" : "Add Watchlist"
        config.imagePlacement = .top
        config.imagePadding = 8
        
        watchlistButton.configuration = config
        watchlistButton.tintColor = isInWatchlist ? .systemGreen : .black
    }
    private func updateAddToListButton(isAdded: Bool) {
        var config = UIButton.Configuration.plain()

        config.image = UIImage(
            systemName: isAdded ? "text.badge.checkmark" : "text.badge.plus"
        )

        config.title = isAdded ? "Added to List" : "Add to List"
        config.imagePlacement = .top
        config.imagePadding = 8

        addToListButton.configuration = config
        addToListButton.tintColor = isAdded ? .systemPink : .systemBlue
    }
    // MARK: - Actions
    
    @IBAction private func watchlistTapped(_ sender: UIButton) {
        viewModel.toggleWatchlist()
    }
    
    @IBAction private func favoriteTapped(_ sender: UIButton) {
        viewModel.toggleFavorite()
    }
    
    @IBAction private func addToListButtonTapped(_ sender: UIButton) {
        guard let viewController = makeSelectListViewController?() else { return }

        viewController.onExistingListFound = { [weak self] list in
            self?.viewModel.updateAddedList(listId: list.id)
        }

        viewController.onDone = { [weak self] list in
            self?.viewModel.updateAddedList(listId: list.containsMovie ? list.id : nil)
            self?.dismiss(animated: true)
            self?.viewModel.addToList(listId: list.id)
        }

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(viewController, animated: true)
    }
}
