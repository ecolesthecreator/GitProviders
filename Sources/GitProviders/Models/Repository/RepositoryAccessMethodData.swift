//
//  RepositoryAccessMethodData.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
//import SwiftGit2
import MiniGit

public protocol RepositoryAccessMethodData {
    var hash: Int { get }
    var userDescription: String { get }
//    func toSwiftGit2Credentials() -> SwiftGit2.Credentials?
    func toMiniGitCredentials() -> MiniGit.KeychainCredential?

    /// gets sensitive info!
    func getCred() -> Cred?
}

public struct AnyRepositoryAccessMethodData: Identifiable, RepositoryAccessMethodData {
    public var id: Int { hash }
    public let hash: Int
    public let raw: Any
    private let _getCred: () -> Cred?
    public func getCred() -> Cred? {
        _getCred()
    }
    private let _userDescription: () -> String
    public var userDescription: String {
        _userDescription()
    }
//    let _toSwiftGit2Credentials: () -> SwiftGit2.Credentials?
    let _toMiniGitCredentials: () -> MiniGit.KeychainCredential?

//    public func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
//        _toSwiftGit2Credentials()
//    }

    public func toMiniGitCredentials() -> MiniGit.KeychainCredential? {
        _toMiniGitCredentials()
    }

    init<T: RepositoryAccessMethodData>(_ val: T) {
        self.raw = val
        self.hash = val.hash
        self._getCred = val.getCred
        self._userDescription = {val.userDescription}
//        self._toSwiftGit2Credentials = val.toSwiftGit2Credentials
        self._toMiniGitCredentials = val.toMiniGitCredentials
    }
}

struct UnauthenticatedAccessMethodData: RepositoryAccessMethodData {
    var hash: Int = 0
    
    var userDescription: String {
        "Unauthenticated"
    }
    
//    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
//        SwiftGit2.Credentials.default
//    }

    func toMiniGitCredentials() -> MiniGit.KeychainCredential? {
        return .init(id: UUID().uuidString, kind: .password, targetURL: "", userName: "", password: "")
    }

    func getCred() -> Cred? {
        Unauthenticated()
    }
}

struct SSHAccessMethodData: RepositoryAccessMethodData {
    var hash: Int { publicKeyData.hashValue }

    let publicKeyData: Data
    var userDescription: String {
        (try? publicKeyData.publicPEMKeyToSSHFormat()) ?? "SSH Key"
    }
//    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
//        if let creds = getData(), let privateKeyAsPEMString = creds.privateKeyAsPEMString {
//            return SwiftGit2.Credentials.sshMemory(
//                username: "git",
//                privateKey: privateKeyAsPEMString,
//                passphrase: ""
//            )
//        }
//        return nil
//    }

    func toMiniGitCredentials() -> MiniGit.KeychainCredential? {
        return .init(id: UUID().uuidString, kind: .ssh, targetURL: "", publicKey: publicKeyData.printAsPEMPublicKey(), privateKey: publicKeyData.printAsPEMPrivateKey())
    }

    /// gets sensitive info!
    let getData: () -> SSHKey?
    func getCred() -> Cred? { getData() }
}

struct AccessTokenAccessMethodData: RepositoryAccessMethodData {

    var hash: Int { 1 }
    
    let username: String
    let isPassword: Bool
    let providerName: String
    var userDescription: String {
        "\(providerName) \(isPassword ? "password" : "access token") for \(username)"
    }
//    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
//        if let creds = getData() {
//            return SwiftGit2.Credentials.plaintext(
//                username: username,
//                password: creds.accessTokenOrPassword
//            )
//        }
//        return nil
//        
//    }

    func toMiniGitCredentials() -> MiniGit.KeychainCredential? {
        return .init(
            id: username,
            kind: .password,
            targetURL: "",
            userName: username,
            password: { return getData()?.accessTokenOrPassword ?? "" }()
        )
    }
    /// gets sensitive info!
    let getData: () -> AccessTokenOrPassword?
    func getCred() -> Cred? { getData() }
}
