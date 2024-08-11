//
//  CreateUser.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation

actor CreateUser: APIDefinition, Request {
    let parameters: Parameter?

    nonisolated var method: HTTPMethod { .post }

    nonisolated var path: String { "users" }

    nonisolated var rateLimit: TimeInterval { 1 }

    init(user: SBUser) {
        self.parameters = Parameter(userId: user.userId, nickname: user.nickname ?? "", profileURL: user.profileURL ?? "")
    }
}

extension CreateUser {
    struct Parameter: Encodable {
        let userId: String
        let nickname: String
        let profileURL: String
        let issueAccessToken: Bool = true

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case nickname
            case profileURL = "profile_url"
            case issueAccessToken = "issue_access_token"
        }
    }

    struct Response: Decodable {
        let userId: String
        let nickname: String?
        let profileURL: String?
        let accessToken: String?

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case nickname
            case profileURL = "profile_url"
            case accessToken = "access_token"
        }
    }
}
