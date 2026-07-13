//
//  CreateListViewController.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 14/01/1448 AH.
//

import UIKit

final class CreateListViewController: UIViewController {

    private var viewModel: CreateListViewModel!

    private let nameCounterLabel = UILabel()
    private let descriptionCounterLabel = UILabel()

    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var createButton: UIButton!

    static func create(with viewModel: CreateListViewModel) -> CreateListViewController {
        let vc = CreateListViewController(
            nibName: "CreateListViewController",
            bundle: nil
        )
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create List"
        setupView()
        bind(to: viewModel)
    }

    @IBAction private func createButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text ?? ""

        let description: String

        if descriptionTextView.text == "Enter list description" {
            description = ""
        } else {
            description = descriptionTextView.text
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        viewModel.createList(
            name: name,
            description: description
        )
    }

    @objc private func nameTextDidChange() {
        let count = nameTextField.text?.count ?? 0
        nameCounterLabel.text = "\(count)/50"
    }
}

// MARK: - Private

private extension CreateListViewController {

    func setupView() {
        view.backgroundColor = .systemBackground

        nameTextField.placeholder = "Enter list name"
        nameTextField.textAlignment = .left
        nameTextField.addTarget(
            self,
            action: #selector(nameTextDidChange),
            for: .editingChanged
        )

        descriptionTextView.text = "Enter list description"
        descriptionTextView.textColor = .placeholderText
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.delegate = self

        createButton.setTitle("Create List", for: .normal)
        createButton.layer.cornerRadius = 12
        createButton.clipsToBounds = true

        setupCounterLabels()
    }

    func setupCounterLabels() {
        nameCounterLabel.text = "0/50"
        nameCounterLabel.font = .systemFont(ofSize: 13)
        nameCounterLabel.textColor = .systemGray3
        nameCounterLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionCounterLabel.text = "0/200"
        descriptionCounterLabel.font = .systemFont(ofSize: 13)
        descriptionCounterLabel.textColor = .systemGray3
        descriptionCounterLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameCounterLabel)
        view.addSubview(descriptionCounterLabel)

        NSLayoutConstraint.activate([
            nameCounterLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor, constant: -12),
            nameCounterLabel.centerYAnchor.constraint(equalTo: nameTextField.centerYAnchor),

            descriptionCounterLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -12),
            descriptionCounterLabel.bottomAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: -12)
        ])
    }

    func bind(to viewModel: CreateListViewModel) {
        viewModel.loading.observe(on: self) { [weak self] isLoading in
            self?.updateCreateButton(isLoading: isLoading)
        }

        viewModel.error.observe(on: self) { [weak self] message in
            guard let message else {
                return
            }

            self?.showError(message)
        }
    }

    func updateCreateButton(isLoading: Bool) {
        createButton.isEnabled = !isLoading

        createButton.setTitle(
            isLoading ? "Creating..." : "Create List",
            for: .normal
        )
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

// MARK: - UITextViewDelegate

extension CreateListViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter list description" {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        descriptionCounterLabel.text = "\(textView.text.count)/200"
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter list description"
            textView.textColor = .placeholderText
            descriptionCounterLabel.text = "0/200"
        }
    }
}
