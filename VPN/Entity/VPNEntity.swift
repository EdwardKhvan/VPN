//
//  VPNEntity.swift
//  VPN
//
//  Created by Хван Эдуард on 15.07.2025.
//

import NetworkExtension

struct VPNConfigiration {
    
    let server: String
    let username: String
    let password: String
    let protocolType: VPNProtocolType
}

enum VPNProtocolType: String, CaseIterable {
    
    case ikev2 = "IKEv2"
    case ipsec = "IPSec"
    
    var index: Int {
        switch self {
        case .ikev2: return 0
        case .ipsec: return 1
        }
    }
    
    static func type(from index: Int) -> VPNProtocolType {
        return index == 0 ? .ikev2 : .ipsec
    }
}

enum VPNStatus {
    
    case connected
    case connecting
    case disconnected
    case disconnecting
    case invalid
    
    init(neStatus: NEVPNStatus) {
        switch neStatus {
        case .connected: self = .connected
        case .connecting, .reasserting: self = .connecting
        case .disconnected, .invalid: self = .disconnected
        case .disconnecting: self = .disconnecting
        @unknown default: self = .invalid
        }
    }
    
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnecting: return "Disconnecting"
        case .disconnected: return "Disconnected"
        case .invalid : return "Invalid"
        }
    }
}
