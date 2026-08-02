//
//  ProfileViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/11/1447 AH.
//

import UIKit

final class ProfileViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!

    private var viewModel: ProfileViewModel!

    static func create(with viewModel: ProfileViewModel) -> ProfileViewController {
        let view = instantiateViewController()
        view.viewModel = viewModel
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
}

// MARK: - Private

private extension ProfileViewController {
    
    func setupView() {
        title = "Profile"
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .systemGray3

        signInButton.setTitle("Sign In", for: .normal)
        signInButton.backgroundColor = .systemBlue
        signInButton.tintColor = .white
        signInButton.layer.cornerRadius = 8
    }
    
    func setupTableView() {
        tableView.register(
            UINib(nibName: "ProfileItemCell", bundle: nil),
            forCellReuseIdentifier: "ProfileItemCell"
        )
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    func bind(to viewModel: ProfileViewModel) {
        viewModel.userType.observe(on: self) { [weak self] userType in
            self?.updateUI(for: userType)
        }

        viewModel.username.observe(on: self) { [weak self] username in
            guard !username.isEmpty else {
                return
            }

            self?.nameLabel.text = username
        }
    }
    @IBAction func signInTapped(_ sender: UIButton) {
        viewModel.signIn()
    }
    func updateUI(for userType: ProfileUserType) {
        
        switch userType {
        case .guest:
            nameLabel.text = "Guest User"
            subtitleLabel.text = "Not signed in to TMDB"
            signInButton.isHidden = false
            
        case .signedIn:
            subtitleLabel.text = "Signed in"
            signInButton.isHidden = true
            
        case .unauthenticated:
            nameLabel.text = "Guest User"
            subtitleLabel.text = "Not signed in to TMDB"
            signInButton.isHidden = false
        }
        
        tableView.reloadData()
    }
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Logout",
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.logout()
            }
        )

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        viewModel.userType.value == .signedIn ? 4 : 3
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProfileItemCell",
            for: indexPath
        ) as! ProfileItemCell
        
        switch indexPath.row {
        case 0:
            cell.configure(
                title: "Lists",
                icon: UIImage(systemName: "list.bullet")
            )
            
        case 1:
            cell.configure(
                title: "Favorites",
                icon: UIImage(systemName: "heart")
            )
            
        case 2:
            cell.configure(
                title: "Watchlist",
                icon: UIImage(systemName: "bookmark")
            )
        case 3:
            cell.configure(
                title: "Logout",
                icon: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                isLogout: true
            )
            
        default:
            break
        }
        
        return cell
    }
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        switch indexPath.row {
        case 0:
            viewModel.didSelectLists()

        case 1:
            viewModel.didSelectFavorites()

        case 2:
            viewModel.didSelectWatchlist()

        case 3:
            showLogoutConfirmation()

        default:
            break
        }
    }
}
