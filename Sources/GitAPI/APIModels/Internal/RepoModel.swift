//
//  RepoModel.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

import Foundation

public struct RepoModel: InternalModel, Identifiable, Hashable {
    public var id: Int { hashValue }
    public let name: String
    public let httpsURL: String
    public let sshURL: String
    public let isPrivate: Bool
    public let size: Int
    public let updatedAt: Date

    public var urlAsURLType: URL {
        return URL(string: httpsURL)!
    }

    public init(
        name: String,
        httpsURL: String,
        sshURL: String,
        isPrivate: Bool,
        size: Int,
        updatedAt: Date
    ) {
        self.name = name
        self.httpsURL = httpsURL
        self.sshURL = sshURL
        self.isPrivate = isPrivate
        self.size = size
        self.updatedAt = updatedAt
    }
}
