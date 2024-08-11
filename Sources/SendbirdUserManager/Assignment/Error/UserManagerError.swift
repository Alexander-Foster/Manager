//
//  UserManagerError.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation


public enum UserManagerError: Error {
    case userIdNotMatch
    case exceededMaximumUsers
    case unknwon
    case nicknameIsEmpty
}
