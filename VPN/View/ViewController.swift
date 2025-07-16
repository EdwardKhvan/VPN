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

class ViewController: UIViewController, VPNViewControllerProtocol {

    var presenter = VPNPresenterProtocol?
    
    private let statusLabel = UILabel()
    private let connectionButton = UIButton(type: .system)
    private let serverField = UITextField()
    private let passwordField = UITextField()
    private let usernameField = UITextField()
    private let protocolSelector = UISegmentedControl(items: VPNProtocolType.allCases.map {
        $0.rawValue
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

