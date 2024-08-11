//
//  AssignUserManager.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation



final class AssignUserManager: SBUserManager {

    var networkClient: SBNetworkClient
    var userStorage: SBUserStorage

    private var recentAppId: String?

    struct Configure: APIConfigure {
        var host: String
        var basePath: String { "v3" }
        var token: String
    }

    init() {
        networkClient = AssignNetworkClient()
        userStorage = AssignUserStorage()
    }

    func initApplication(applicationId: String, apiToken: String) {

        if recentAppId != applicationId {
            // 앱 내에 저장된 모든 데이터는 삭제되어야 합니다
            userStorage = AssignUserStorage()
        }
        recentAppId = applicationId
        // SDK을 초기화합니다
        API.configure(Configure(
            host: "https://api-\(applicationId).sendbird.com",
            token: apiToken
        ))
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        let user = SBUser(userId: params.userId, nickname: params.nickname, profileURL: params.profileURL)

        // network 요청 성공 후 저장.
        networkClient.request(request: CreateUser(user: user)) { [weak self] result in
            switch result {
            case .success(let success):
                if user.userId == success.userId {
                    self?.userStorage.upsertUser(user)
                    completionHandler?(.success(user))
                } else {
                    completionHandler?(.failure(UserManagerError.userIdNotMatch))
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        guard params.count <= 10 else {
            completionHandler?(.failure(UserManagerError.exceededMaximumUsers))
            return
        }

        let users = params.map { SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL) }

        var responseItems: [SBUser] = []
        var responseCount = 0
        var failure: Error = UserManagerError.unknwon

        for user in users {
            networkClient.request(request: CreateUser(user: user)) { [weak self] result in
                switch result {
                case .success(let success):
                    responseCount += 1
                    if user.userId == success.userId {
                        responseItems.append(user)
                    }
                case .failure(let error):
                    responseCount += 1
//                    if let error = error as? AssignNetworkError {
//                        completionHandler?(.failure(error))
//                        
//                    } else {
                        failure = error
//                    }
                }

                if responseCount == params.count {
                    responseItems.forEach { self?.userStorage.upsertUser($0) }
                    completionHandler?(responseItems.count == params.count ? .success(responseItems) : .failure(failure))
                }
            }
        }
    }
    
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        let user = SBUser(userId: params.userId, nickname: params.nickname, profileURL: params.profileURL)

        // network 요청 성공 후 저장.
        networkClient.request(request: UpdateUser(user: user)) { [weak self] result in
            switch result {
            case .success(let success):
                if user.userId == success.userId {
                    self?.userStorage.upsertUser(user)
                    completionHandler?(.success(user))
                } else {
                    completionHandler?(.failure(UserManagerError.userIdNotMatch))
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {

        if let user = userStorage.getUser(for: userId) {
            completionHandler?(.success(user))
            return
        }

        networkClient.request(request: GetUser(userId: userId)) { [weak self] result in
            switch result {
            case .success(let success):
                let user = SBUser(userId: success.userId, nickname: success.nickname, profileURL: success.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        guard !nicknameMatches.isEmpty else {
            completionHandler?(.failure(UserManagerError.nicknameIsEmpty))
            return
        }

        let users = userStorage.getUsers(for: nicknameMatches)
        if !users.isEmpty {
            completionHandler?(.success(users))
            return
        }

        networkClient.request(request: GetUserList(nickname: nicknameMatches)) { [weak self] result in
            switch result {
            case .success(let success):
                let users = success.users.map { SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL) }
                users.forEach { self?.userStorage.upsertUser($0) }
                completionHandler?(.success(users))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
}
