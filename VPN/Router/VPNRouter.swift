//
//  VPNRouter.swift
//  VPN
//
//  Created by Хван Эдуард on 15.07.2025.
//

import UIKit

protocol VPNRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}

class VPNRouter: VPNRouterProtocol {
    
    static func createModule() -> UIViewController {
        
        let view = VPNViewController()
        let presenter = VPNPresenter()
        let interactor = VPNInteractor()
        let router = VPNRouter()
        
        view.presenter = presenter
        
        presenter.interactor = interactor
        presenter.router = router
        presenter.view = view
        
        interactor.presenter = presenter
        
        return view
    }
    
}
