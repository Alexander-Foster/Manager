//
//  NetworkError.swift
//  Network
//
//  Created by Chang Woo Son on 6/20/24.
//

import Foundation


public enum NetworkError: Error {
    /// Indicates a response failed to map to a JSON structure.
    case jsonMapping(CoreResponse)
    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(CoreResponse)
    /// Indicates a response failed to map to a Decodable object.
    case objectMapping(Swift.Error, CoreResponse)

    case nonHTTPResponse(URLResponse)

    case underlying(Swift.Error, CoreResponse?)

    case undifined
}


extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .jsonMapping:
            return "Failed to map data to JSON."
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        case .statusCode:
            return "Status code didn't fall within the given range."
        case .underlying(let error, _):
            return error.localizedDescription
        case .nonHTTPResponse:
            return "Failed to convert nonHTTPResponse"
        case .undifined:
            return "Undifined Error"
        }
    }
}

public extension NetworkError {
    /// Depending on error type, returns a `Response` object.
    var response: CoreResponse? {
        switch self {
        case .jsonMapping(let response): return response
        case .objectMapping(_, let response): return response
        case .statusCode(let response): return response
        case .underlying(_, let response): return response
        case .nonHTTPResponse: return nil
        case .undifined: return nil
        }
    }

    /// Depending on error type, returns an underlying `Error`.
    internal var underlyingError: Swift.Error? {
        switch self {
        case .jsonMapping: return nil
        case .objectMapping(let error, _): return error
        case .statusCode: return nil
        case .underlying(let error, _): return error
        case .nonHTTPResponse: return nil
        case .undifined: return nil
        }
    }
}

// MARK: - Error User Info

extension NetworkError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
