//
//  GetUserList.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation

actor GetUserList: APIDefinition, Request {
    let parameters: Parameter?

    nonisolated var method: HTTPMethod { .get }

    nonisolated var path: String { "users" }

    init(nickname: String) {
        parameters = Parameter(nickname: nickname)
    }
}

extension GetUserList {
    struct Parameter: Encodable {
        let nickname: String
        let limit: Int = 100
    }

    struct Response: Decodable {
        let users: [UserResponse]

        struct UserResponse: Decodable {
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
}

