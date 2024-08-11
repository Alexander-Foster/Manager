//
//  AssignUserStorage.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation


class AssignUserStorage: SBUserStorage {
    
    private var cache = [String: SBUser]()
    private let queue = DispatchQueue(label: "com.assign.queue", attributes: .concurrent)

    init() {}

    func getUsers() -> [SBUser] {
        var users = [SBUser]()

        queue.sync {
            users = Array(self.cache.values)
        }

        return users
    }

    func getUser(for userId: String) -> (SBUser)? {
        var user: (SBUser)?

        queue.sync {
            user = self.cache[userId]
        }

        return user
    }

    func upsertUser(_ user: SBUser) {
        queue.async(flags: .barrier) {
            self.cache[user.userId] = user
        }
    }

    func getUsers(for nickname: String) -> [SBUser] {
        cache.values.filter { $0.nickname?.contains(nickname) ?? false }
    }
}
