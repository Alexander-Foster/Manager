//
//  AssignNetworkError.swift
//  SendbirdUserManager
//
//  Created by Chang Woo Son on 8/11/24.
//

import Foundation


public enum AssignNetworkError: Error {
    case rateLimitExceeded
    case maxRequestExceeded
    case invalidResponse
}
