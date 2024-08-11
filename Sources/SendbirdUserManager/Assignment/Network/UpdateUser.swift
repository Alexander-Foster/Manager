//
//  UpdateUser.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation

actor UpdateUser: APIDefinition, Request {
    let parameters: Parameter?

    nonisolated var method: HTTPMethod { .put }

    nonisolated var path: String { "users/\(userId)" }

    private let userId: String

    init(user: SBUser) {
        self.userId = user.userId
        self.parameters = Parameter(nickname: user.nickname ?? "", profileURL: user.profileURL ?? "")
    }
}

extension UpdateUser {
    struct Parameter: Encodable {
        let nickname: String
        let profileURL: String
        let issueAccessToken: Bool = true

        enum CodingKeys: String, CodingKey {
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
