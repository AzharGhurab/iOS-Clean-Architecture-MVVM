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
    }
}

// MARK: - Private

private extension ProfileViewController {

    func setupView() {
        title = "Profile"
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .systemGray3
        nameLabel.text = "Guest User"
        subtitleLabel.text = "Not signed in to TMDB"
        signInButton.setTitle("Sign In", for: .normal)
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

    @IBAction func signInTapped(_ sender: UIButton) {
        viewModel.signIn()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return 4
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
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            viewModel.didSelectLists()

        default:
            break
        }
    }
}
