//
//  GenerateKeys.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

// adapted from: https://stackoverflow.com/a/45916908/3902590

import Security
import CryptoKit
import Foundation

protocol SecKeyConvertible: CustomStringConvertible {
    /// Creates a key from an X9.63 representation.
    init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes

    /// An X9.63 representation of the key.
    var x963Representation: Data { get }
}

extension P256.Signing.PrivateKey: SecKeyConvertible {
    public var description: String {
        return ""
    }
}
extension P256.KeyAgreement.PrivateKey: SecKeyConvertible {
    public var description: String {
        return ""
    }
}
extension P384.Signing.PrivateKey: SecKeyConvertible {
    public var description: String {
        return ""
    }
}
extension P384.KeyAgreement.PrivateKey: SecKeyConvertible {
    public var description: String {
        return ""
    }
}
extension P521.Signing.PrivateKey: SecKeyConvertible {
    public var description: String {
        return ""
    }
}
extension P521.KeyAgreement.PrivateKey: SecKeyConvertible {
    public var description: String {
        return ""
    }
}

protocol GenericPasswordConvertible: CustomStringConvertible {
    /// Creates a key from a raw representation.
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes

    /// A raw representation of the key.
    var rawRepresentation: Data { get }
}

extension Curve25519.KeyAgreement.PrivateKey: GenericPasswordConvertible {
    public var description: String {
        return ""
    }
}
extension Curve25519.Signing.PrivateKey: GenericPasswordConvertible {
    public var description: String {
        return ""
    }
}

extension Curve25519.KeyAgreement.PublicKey: GenericPasswordConvertible {
    public var description: String {
        return ""
    }
}
extension Curve25519.Signing.PublicKey: GenericPasswordConvertible {
    public var description: String {
        return ""
    }
}

func generate25519KeyPair(_ publicTag: String, privateTag: String, keySize: KeySize) -> (publicKey: Curve25519.KeyAgreement.PublicKey, privateKey: Curve25519.KeyAgreement.PrivateKey) {
    let privateKey = Curve25519.KeyAgreement.PrivateKey()
    let publicKey = privateKey.publicKey

    return (publicKey, privateKey)
}

// tuple type for public/private key pair at class level
typealias KeyPair = (publicKey: SecKey, privateKey: SecKey)
func generateKeyPair(_ publicTag: String, privateTag: String, keySize: KeySize) -> KeyPair? {
    let privateKey = P256.KeyAgreement.PrivateKey()
    let publicKey = privateKey.publicKey

    let privateAttributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                      kSecAttrKeyClass: kSecAttrKeyClassPrivate] as [String: Any]

    let publicAttributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                      kSecAttrKeyClass: kSecAttrKeyClassPublic] as [String: Any]


    // Get a SecKey representation.
    guard 
        let publicKey = SecKeyCreateWithData(
        publicKey.x963Representation as CFData,
        publicAttributes as CFDictionary,
        nil
    ),
        let privateKey = SecKeyCreateWithData(
            privateKey.x963Representation as CFData,
            privateAttributes as CFDictionary,
            nil)

    else { return nil }

    return (publicKey, privateKey)
//    var sanityCheck: OSStatus = noErr
//    var publicKey: SecKey?
//    var privateKey: SecKey?
//    
//    // Container dictionaries
//    var privateKeyAttr = [AnyHashable : Any]()
//    var publicKeyAttr = [AnyHashable: Any]()
//    var keyPairAttr = [AnyHashable : Any]()
//    
//    // Set top level dictionary for the keypair
//    keyPairAttr[(kSecAttrKeyType ) as AnyHashable] = (kSecAttrKeyTypeRSA as Any)
//    keyPairAttr[(kSecAttrKeySizeInBits as AnyHashable)] = keySize.rawValue
//
//    // Adjust key type to ECDSA (Elliptic Curve Digital Signature Algorithm)
//    keyPairAttr[kSecAttrKeyType as AnyHashable] = kSecAttrKeyTypeECSECPrimeRandom
//    keyPairAttr[kSecAttrKeySizeInBits as AnyHashable] = 256
//
//    // Set private key dictionary
//    privateKeyAttr[(kSecAttrIsPermanent as AnyHashable)] = Int(truncating: true)
//    privateKeyAttr[(kSecAttrApplicationTag as AnyHashable)] = privateTag
//    
//    // Set public key dictionary.
//    publicKeyAttr[(kSecAttrIsPermanent as AnyHashable)] = Int(truncating: true)
//    publicKeyAttr[(kSecAttrApplicationTag as AnyHashable)] = publicTag
//    publicKeyAttr[(kSecAttrProtocol as AnyHashable)] = (kSecAttrProtocolSSH as Any)
//    
//    keyPairAttr[(kSecPrivateKeyAttrs as AnyHashable)] = privateKeyAttr
//    keyPairAttr[(kSecPublicKeyAttrs as AnyHashable)] = publicKeyAttr
//    
//    sanityCheck = SecKeyGeneratePair((keyPairAttr as CFDictionary), &publicKey, &privateKey)
//    if sanityCheck == noErr && publicKey != nil && privateKey != nil {
//        return KeyPair(publicKey: publicKey!, privateKey: privateKey!)
//    }
//    return nil
}
