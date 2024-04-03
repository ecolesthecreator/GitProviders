//
//  RepositoryAccessMethods.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

enum RepositoryAccessMethods: String, Identifiable {
    var id: String { name }
    
    case AccessToken
    case SSH
    case Password // treated as an access token, but has a seperate case to create a distinction in the UI

    var icon: Image {
        switch self {
        case .AccessToken:
            return Image(systemName: "circle.dashed")
        case .SSH:
            return Image(systemName: "key.fill")
        case .Password:
            return Image(systemName: "textformat.abc")
        }
    }
    
    var setupMessage: String? {
        switch self {
        case .AccessToken:
            return "Add an access token"
        case .SSH:
            return "Setup SSH for this device"
        case .Password:
            return nil
        }
    }
    
    var listDescription: String {
        switch self {
        case .AccessToken:
            return "Access Token"
        case .SSH:
            return "SSH Keys"
        case .Password:
            return name
        }
    }
    
    func getOnDeviceCred(gitProviderStore: GitProviderStore, accessMethodData: RepositoryAccessMethodData) -> Cred? {
        switch self {
        case .AccessToken, .Password:
            if let accessTokenAccessMethodData = accessMethodData as? AccessTokenAccessMethodData {
                return accessTokenAccessMethodData.getData()
            }
            return nil
        case .SSH:
            if let userSSHKey = gitProviderStore.sshKey,
               let cellPublicKeyData = (accessMethodData as? SSHAccessMethodData)?.publicKeyData {
                if userSSHKey.publicKeyData == cellPublicKeyData {
                    return userSSHKey
                }
            }
            return nil
        }
    }
    
    func removeMessage(accessMethodData: RepositoryAccessMethodData, profileName: String) -> String {
        switch self {
        case .AccessToken, .Password:
            return "Are you sure what want to delete the \((accessMethodData as? AccessTokenAccessMethodData)?.isPassword ?? false ? "password": "access token") for profile \(profileName)?"
        case .SSH:
            return "Are you sure what want to disassociate the public key \((try? (accessMethodData as? SSHAccessMethodData)?.publicKeyData.publicPEMKeyToSSHFormat()) ?? "") with profile \(profileName)?"
        }
    }
    
    func isValidMessage(isValid: Bool) -> String? {
        switch self {
        case .AccessToken:
            return nil
        case .SSH:
            return "private key is \(isValid ? "" : "not ")on this device"
        case .Password:
            fatalError()
        }
    }
    
    func addView(
        for gitProviderStore: GitProviderStore,
        preset: GitProviderPresets,
        customDetails: CustomProviderDetails?
    ) -> AnyView {
        switch self {
        case .AccessToken:
            return AnyView(AddAccessTokenView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails))
        case .SSH:
            return AnyView(AddSSHView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails))
        case .Password:
            return AnyView(AddAccessTokenView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails, isPassword: true))
        }
    }
    
    var name: String {
        switch self {
        case .AccessToken: return "Access Token"
        case .SSH: return rawValue
        case .Password: return rawValue
        }
    }
}
