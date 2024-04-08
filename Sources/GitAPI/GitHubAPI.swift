//
//  GitHubAPI.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation

enum GitApiHelpers {
    static let GitApiDateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return dateFormatter
    }()
}

public final class GitHubAPI: GitAPI {
    public let baseUrl = URL(string: "https://api.github.com/")!
    public var userInfo: UserInfo?
    
    public static let shared: GitHubAPI = .init()
    init() {}
    
    public func fetchGrantedScopes(callback: @escaping (_ grantedScopes: [PermScope]?, _ metadata: [GitApiMetadata], _ error: Error?) -> Void) {
        self.get("user") { response, error in
            if let response = response, let gitHubUser = response.body.parse(as: GitHubUserModel.self) {
                guard gitHubUser.login == self.userInfo?.username else {
                    callback(nil, [], error)
                    return
                }
                let scopeStrings = response.headers.readStringList(from: "x-oauth-scopes")
                var metadata = [GitApiMetadata]()
                if let expirationDateString = response.headers["github-authentication-token-expiration"] as? String {
                    metadata.append(.tokenExpiration(GitApiHelpers.GitApiDateFormatter.date(from: expirationDateString) ?? Date()))
                }
                var scopes: [PermScope] = []
                for scope in scopeStrings {
                    if scope == "repo" {
                        scopes.append(.repoList(raw: scope))
                        scopes.append(.repoContents(raw: scope))
                    } else {
                        scopes.append(.unknown(raw: scope))
                    }
                }
                callback(scopes, metadata, nil)
            } else {
                callback(nil, [], error)
            }
        }
    }

    public func fetchUserRepos(callback: @escaping ([RepoModel]?, Error?) -> Void) {
        if let username = userInfo?.username {
            self.get("search/repositories", parameters: [
                "q": "user:\(username)",
                "per_page":"100"
            ]) { response, error in
                if let response = response, let gitHubRepoList = response.body.parse(as: GitHubListResult<GitHubRepoModel>.self) {
                    var repos: [RepoModel] = []
                    for gitHubRepo in gitHubRepoList.items {
                        repos.append(.init(
                            name: gitHubRepo.name,
                            httpsURL: gitHubRepo.clone_url,
                            sshURL: gitHubRepo.ssh_url,
                            isPrivate: gitHubRepo.private,
                            size: gitHubRepo.size,
                            updatedAt: gitHubRepo.updated_at
                        ))
                    }
                    callback(repos, nil)
                } else {
                    callback(nil, error)
                }
            }
        } else {
            callback(nil, GitApiError.failedToFetch)
        }
    }
}
