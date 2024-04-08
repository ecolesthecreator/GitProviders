//
//  SSHKey.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import Security
import KeychainAccess

extension String: Error { }

/// Should be safe in that using and passing around the object does not put any sensitive info into memory. Any sensitive info should be exposed through explicit use of a method.
public struct SSHKey: Cred {
    let keychain: Keychain
    let publicKeyKeychainName: String
    let privateKeyKeychainName: String
    /// okay to retain in memory, it's a public key
    var publicKeyData: Data? {
        try? keychain.getData(publicKeyKeychainName)
    }
    /// okay to retain in memory, it's a public key
    var publicKeyAsPEMFormat: String? {
        publicKeyData?.printAsPEMPublicKey()
    }
    /// okay to retain in memory, it's a public key
    var publicKeyAsSSHFormat: String? {
        try? publicKeyData?.ecPublicKeyToSSHFormat()
    }
    /// do not retain in memory, this data is highly sensitive!
    var privateKeyData: Data? {
        try? keychain.getData(privateKeyKeychainName)
    }
    /// do not retain in memory, this data is highly sensitive!
    var privateKeyAsPEMString: String? {
        privateKeyData?.printAsPEMPrivateKey()
    }
    
    
    private static let defaultPublicKeyKeychainName = "id_rsa.pub"
    private static let defaultPrivateKeyKeychainName = "id_rsa"
    
    public static func get(from keychain: Keychain) -> SSHKey? {
        let sshKey = SSHKey(
            keychain: keychain,
            publicKeyKeychainName: defaultPublicKeyKeychainName,
            privateKeyKeychainName: defaultPrivateKeyKeychainName
        )
        if sshKey.publicKeyData != nil {
            return sshKey
        }
        return nil
    }
    
    static func generateNew(for keychain: Keychain, withICloudSync: Bool, keySize: KeySize, keyType: KeyType) -> SSHKey? {
        guard keyType == .RSA else {
            // todo: support other key types
            return nil
        }
        if let bundleId = Bundle.main.bundleIdentifier {
            let publicKeyTag: String = "\(bundleId).publickey"
            let privateKeyTag: String = "\(bundleId).privatekey"
            
            for tag in [publicKeyTag, privateKeyTag] {
                let deleteQuery: [String: Any] = [kSecAttrApplicationTag as String: tag]
                SecItemDelete(deleteQuery as CFDictionary)
            }
            
            // todo: reset all git providers using this key
            
            let keyPair = generateKeyPair(publicKeyTag, privateTag: privateKeyTag, keySize: keySize)
            
            var pbError:Unmanaged<CFError>?
            var prError:Unmanaged<CFError>?
            
            guard let publicKey = keyPair?.publicKey,
                  let pbData = SecKeyCopyExternalRepresentation(publicKey, &pbError) as Data? else {
                return nil
            }
            guard let privateKey = keyPair?.privateKey, let prData = SecKeyCopyExternalRepresentation(privateKey, &prError) as Data? else {
                return nil
            }
            
            do {
                // store public key so that it's locked in the secure enclave until someone unlocks the device for the first time after a reboot
                let pbDataKeychain = keychain
                    .synchronizable(withICloudSync)
                    .accessibility(.afterFirstUnlock)
                try pbDataKeychain.remove(defaultPublicKeyKeychainName)
                try pbDataKeychain.set(pbData, key: defaultPublicKeyKeychainName)
                
                // store private key so that it's locked in the secure enclave except when the device is in an unlocked state
                let prDataKeychain = keychain
                    .synchronizable(withICloudSync)
                    .accessibility(.whenUnlocked)
                try prDataKeychain.remove(defaultPrivateKeyKeychainName)
                try prDataKeychain.set(prData, key: defaultPrivateKeyKeychainName)
                return .init(
                    keychain: keychain,
                    publicKeyKeychainName: defaultPublicKeyKeychainName,
                    privateKeyKeychainName: defaultPrivateKeyKeychainName
                )
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
        return nil
    }

    func storeKey<T: GenericPasswordConvertible>(_ key: T, account: String) throws {
        // Treat the key data as a generic password.
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: account,
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true,
                     kSecValueData: key.rawRepresentation] as [String: Any]


        // Add the key data.
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw "Unable to store item: \(status)"
        }
    }
}


