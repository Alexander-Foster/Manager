//
//  Encodable+.swift
//  Network
//
//  Created by Chang Woo Son on 5/4/24.
//

import Foundation


extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    var data: Data? {
        guard let args = dictionary?.map({ key, value in
            "\(key):\(value)"
        }).joined(separator: ", ") else { return nil }

        return "{\"op\": \"subscribe\", \"args\": [\"\(args)\"]}".data(using: .utf8)
    }
}
