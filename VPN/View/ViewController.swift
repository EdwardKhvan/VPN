//
//  ViewController.swift
//  VPN
//
//  Created by Хван Эдуард on 15.07.2025.
//

import UIKit

protocol VPNViewControllerProtocol: AnyObject {
    func updateConnectionStatus(_ status: VPNStatus)
    func showError(message: String)
}

class VPNViewController: UIViewController, VPNViewControllerProtocol {

    var presenter: VPNPresenterProtocol?
    
    private let statusLabel = UILabel()
    private let connectionButton = UIButton(type: .system)
    private let serverField = UITextField()
    private let passwordField = UITextField()
    private let usernameField = UITextField()
    private let protocolSelector = UISegmentedControl(items: VPNProtocolType.allCases.map {
        $0.rawValue
    })
    
    private var currentStatus: VPNStatus = .disconnected {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        statusLabel.text = "Status: \(currentStatus.description)"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        connectionButton.setTitle("Connect", for: .normal)
        connectionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        connectionButton.backgroundColor = .systemBlue
        connectionButton.setTitleColor(.white, for: .normal)
        connectionButton.layer.cornerRadius = 10
        connectionButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        
        serverField.placeholder = "vpn.server.com"
        serverField.borderStyle = .roundedRect
        serverField.keyboardType = .URL
        serverField.autocapitalizationType = .none
        
        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        
        protocolSelector.selectedSegmentIndex = 0
        
        let stackView = UIStackView(arrangedSubviews: [
            serverField, usernameField, passwordField,
            protocolSelector, statusLabel, connectionButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 26
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    @objc private func connectButtonTapped() {
        presenter?.didTapConnectionButton(currentStatus: currentStatus)
    }
    
    private func updateUI() {
        statusLabel.text = "Status: \(currentStatus.description)"
        
        switch currentStatus {
        case .connected:
            connectionButton.setTitle("Disconnected", for: .normal)
            connectionButton.backgroundColor = .red
        case .connecting, .disconnecting:
            connectionButton.setTitle("Cancel", for: .normal)
            connectionButton.backgroundColor = .systemOrange
        case .disconnected:
            connectionButton.setTitle("Connect", for: .normal)
            connectionButton.backgroundColor = .systemGreen
        case .invalid:
            connectionButton.setTitle("Connect", for: .normal)
            connectionButton.backgroundColor = .systemGray
        }
    }
    
    func updateConnectionStatus(_ status: VPNStatus) {
        currentStatus = status
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

