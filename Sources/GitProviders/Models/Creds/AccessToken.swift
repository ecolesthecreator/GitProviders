//
//  AccessToken.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import KeychainAccess

public struct AccessTokenOrPassword: Cred {
    public let username: String
    public let accessTokenOrPassword: String
    public let isPassword: Bool // if false, means it's an access token
}

// make it so that we can store the UserInfo type (which holds username and access token) in the keychain
extension AccessTokenOrPassword: Storeable {
    public func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(username, forKey: "username")
        archiver.encode(accessTokenOrPassword, forKey: "accessTokenOrPassword")
        archiver.encode(isPassword ? "1" : "0", forKey: "isPassword")
        archiver.finishEncoding()
        return archiver.encodedData
    }
    
    public init?(data: Data) {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            return nil
        }
        defer {
            unarchiver.finishDecoding()
        }
        guard let username = unarchiver.decodeObject(of: NSString.self, forKey: "username") as? String else { return nil }
        guard let accessTokenOrPassword = unarchiver.decodeObject(of: NSString.self,  forKey: "accessTokenOrPassword") as? String else { return nil }
        guard let isPassword = unarchiver.decodeObject(of: NSString.self, forKey: "isPassword") as? String else { return nil }
        self.init(username: username, accessTokenOrPassword: accessTokenOrPassword, isPassword: isPassword == "1")
    }
}
