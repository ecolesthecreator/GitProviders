//
//  Clone.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import Foundation
import SwiftGit2

public func clone(
    with creds: Credentials,
    from remoteURL: URL,
    named nickName: String,
    _ callback: @escaping (
        _ success: Repository?,
        _ completedObjects: Int?,
        _ totalObjects: Int?,
        _ message: String?
    ) -> ()) {
    callback(nil, nil, nil, nil)
        let lastPathComponent = remoteURL.lastPathComponent
            .replacingOccurrences(of: ".git", with: "")
            .replacingOccurrences(of: ".com", with: "")
        print("Cloning Repo: \(lastPathComponent)")
        let localUrl = URL.documentsDirectory
            .appending(component: "git", directoryHint: .isDirectory)
            .appending(component: lastPathComponent)
    let result = Repository.clone(from: remoteURL, to: localUrl, credentials: creds, checkoutProgress: { str, n1, n2 in
        callback(nil, n1, n2, nil)
    })
    switch result {
    case .success(let repository):
        callback(repository, nil, nil, nil)
    case .failure(let err):
        if err.localizedDescription.lowercased().contains("credentials") {
            // ask for credentials
        }
        callback(nil, nil, nil, err.localizedDescription)
    }
}
