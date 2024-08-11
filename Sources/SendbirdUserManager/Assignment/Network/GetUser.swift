//
//  GetUser.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation

actor GetUser: APIDefinition, Request {
    nonisolated var parameters: Parameter? { nil }

    nonisolated var method: HTTPMethod { .get }

    nonisolated var path: String { "users/\(userId)" }

    private let userId: String

    init(userId: String) {
        self.userId = userId

    }
}

extension GetUser {
    typealias Parameter = EmptyParameter

    struct Response: Decodable {
        let userId: String
        let nickname: String?
        let profileURL: String?

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case nickname
            case profileURL = "profile_url"
        }
    }
}
