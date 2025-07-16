//
//  VPNPresenter.swift
//  VPN
//
//  Created by Хван Эдуард on 15.07.2025.
//

protocol VPNPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapConnectionButton(currentStatus: VPNStatus)
    func didEnterConfiguration(server: String?, username: String?, password: String?, protocolIndex: Int)
}

protocol VPNViewProtocol: AnyObject {
    func updateConnectionStatus(_ status: VPNStatus)
    func showError(_ message: String)
}

class VPNPresenter: VPNPresenterProtocol {
    
    weak var view: VPNViewControllerProtocol?
    var interactor: VPNInteractorInputProtocol?
    var router: VPNRouterProtocol?
    
    private var currentConfiguration: VPNConfigiration?
    
    func viewDidLoad() {
        interactor?.loadVPNStatus()
    }
    
    func didTapConnectionButton(currentStatus: VPNStatus) {
        interactor?.toggleVPNConnection(status: currentStatus)
    }
    
    func didEnterConfiguration(server: String?, username: String?, password: String?, protocolIndex: Int) {
        guard let server = server, !server.isEmpty,
              let username = username, !username.isEmpty,
              let password = password, !password.isEmpty else {
            view?.showError(message: "Fill all the fields")
            return
        }
        let protocolType = VPNProtocolType.type(from: protocolIndex)
        let configuration = VPNConfigiration(
            server: server,
            username: username,
            password: password,
            protocolType: protocolType
        )
        
        currentConfiguration = configuration
        interactor?.configureVPN(configuration: configuration)
    }
}

extension VPNPresenter: VPNInteractorOutputProtocol {
    func didChangeVPNStatus(_ status: VPNStatus) {
//        view?.updateConnectionStatus(status)
    }
    
    func configurationFailed(error: String) {
//        view?.showError(message: error)
    }
    
    func connectionFailed(error: String) {
//        view?.showError(message: error)
    }
    
    
}
