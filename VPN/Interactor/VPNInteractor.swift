//
//  VPNInteractor.swift
//  VPN
//
//  Created by Хван Эдуард on 15.07.2025.
//

import NetworkExtension

protocol VPNInteractorInputProtocol: AnyObject {
    func configureVPN(configuration: VPNConfigiration)
    func toggleVPNConnection(status: VPNStatus)
    func loadVPNStatus()
}

protocol VPNInteractorOutputProtocol: AnyObject {
    func didChangeVPNStatus(_ status: VPNStatus)
    func configurationFailed(error: String)
    func connectionFailed(error: String)
}

class VPNInteractor: VPNInteractorInputProtocol {
    
    weak var presenter: VPNInteractorOutputProtocol?
    private var vpnManager: NEVPNManager?
    private var currentStatus: VPNStatus = .disconnected
    
    init() {
        setupVPNManager()
    }
    
    private func setupVPNManager() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            let manager: NETunnelProviderManager
            
            if let existingManager = managers?.first {
                manager = existingManager
            } else {
                manager = NETunnelProviderManager()
            }
            
            let providerProtocol = NETunnelProviderProtocol()
            providerProtocol.providerBundleIdentifier = "ваш.bundleid.vpnextension" // Bundle ID расширения
            providerProtocol.serverAddress = "vpn.example.com"
            
            manager.protocolConfiguration = providerProtocol
            manager.localizedDescription = "My VPN"
            manager.isEnabled = true
            
            manager.saveToPreferences { saveError in
                if let saveError = saveError {
                    self?.presenter?.configurationFailed(error: "Save failed: \(saveError.localizedDescription)")
                    return
                }
                
                self?.vpnManager = manager
                self?.updateStatus()
            }
        }
    }
    func configureVPN(configuration: VPNConfigiration) {
        
        guard let manager = vpnManager else {
            presenter?.configurationFailed(error: "VPNManager not initialized")
            return
        }
        
        saveCredentials(username: configuration.username, password: configuration.password)
        
        let protocolConfig: NEVPNProtocol
        
        switch configuration.protocolType {
        case .ikev2:
            let ikev2Config = NEVPNProtocolIKEv2()
            ikev2Config.serverAddress = configuration.server
            ikev2Config.remoteIdentifier = configuration.server
            ikev2Config.localIdentifier = configuration.username
            ikev2Config.authenticationMethod = .none
            ikev2Config.useExtendedAuthentication = true
            ikev2Config.username = configuration.username
            ikev2Config.passwordReference = passwordReference(for: configuration.username)
            protocolConfig = ikev2Config
            
        case .ipsec:
            let ipsecConfig = NEVPNProtocolIPSec()
            ipsecConfig.serverAddress = configuration.server
            ipsecConfig.remoteIdentifier = configuration.server
            ipsecConfig.localIdentifier = configuration.username
            ipsecConfig.passwordReference = passwordReference(for: configuration.username)
            ipsecConfig.username = configuration.username
            ipsecConfig.authenticationMethod = .sharedSecret
            ipsecConfig.useExtendedAuthentication = true
            protocolConfig = ipsecConfig
        }
        
        protocolConfig.disconnectOnSleep = false
        manager.protocolConfiguration = protocolConfig
        manager.localizedDescription = "My VPN"
        manager.isEnabled = true
        
        manager.saveToPreferences { [weak self] error in
            
            if let error = error {
                self?.presenter?.configurationFailed(error: "Save Failed: \(error.localizedDescription)")
                return
            }
            self?.updateStatus()
        }
    }
    
    func toggleVPNConnection(status: VPNStatus) {
        
        guard let manager = vpnManager else {
            presenter?.connectionFailed(error: "VPN manager not initialized")
            return
        }
        
        switch status {
        case .connected, .connecting:
            manager.connection.stopVPNTunnel()
        case .disconnected, .disconnecting, .invalid:
            do {
                try manager.connection.startVPNTunnel()
            } catch {
                presenter?.connectionFailed(error: "Start failed: \(error.localizedDescription)")
            }
        }
    }
    
    func loadVPNStatus() {
        updateStatus()
    }
    
    private func updateStatus() {
        
        guard let manager = vpnManager else {
            currentStatus = .invalid
            presenter?.didChangeVPNStatus(currentStatus)
            return
        }
        currentStatus = VPNStatus(neStatus: manager.connection.status)
        presenter?.didChangeVPNStatus(currentStatus)
    }

    private func saveCredentials(username: String, password: String) {
        
        guard let passwordData = password.data(using: .utf8) else { return }
        
        let query: [CFString : Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrAccount : username,
            kSecValueData : passwordData,
            kSecAttrAccessible : kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func passwordReference(for account: String) -> Data? {
        
        let query: [CFString : Any] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrAccount : account,
            kSecReturnPersistentRef : kCFBooleanTrue as Any,
            kSecMatchLimit : kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return data
        }
        return nil
    }
}
