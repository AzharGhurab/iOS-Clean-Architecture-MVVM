//
//  DeleteListConfirmationViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 17/01/1448 AH.
//

import UIKit

final class DeleteListConfirmationViewController: UIViewController {

    private let listName: String
    private let onDelete: () -> Void

    private let containerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let iconBackgroundView = UIView()

    init(listName: String, onDelete: @escaping () -> Void) {
        self.listName = listName
        self.onDelete = onDelete
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func create(
        listName: String,
        onDelete: @escaping () -> Void
    ) -> DeleteListConfirmationViewController {
        DeleteListConfirmationViewController(
            listName: listName,
            onDelete: onDelete
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        
        
    }

    @objc private func deleteTapped() {
        dismiss(animated: true) { [onDelete] in
            onDelete()
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func setupView() {
        [containerView, iconBackgroundView, iconView, titleLabel, messageLabel, deleteButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 24

        iconBackgroundView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
        iconBackgroundView.layer.cornerRadius = 41
        iconBackgroundView.clipsToBounds = true

        iconView.image = UIImage(systemName: "trash")
        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = "Delete \"\(listName)\"?"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.text = "This list and all its movies will be permanently deleted. This action cannot be undone."
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.tintColor = .white
        deleteButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        deleteButton.layer.cornerRadius = 12
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = .label
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    private func setupLayout() {
        [containerView, iconView, titleLabel, messageLabel, deleteButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(deleteButton)
        containerView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            iconBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            iconBackgroundView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 82),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 82),

            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 38),
            iconView.heightAnchor.constraint(equalToConstant: 38),


            titleLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: 20), titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            deleteButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            deleteButton.heightAnchor.constraint(equalToConstant: 52),

            cancelButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
}
