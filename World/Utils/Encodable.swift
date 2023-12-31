//
//  Encodable.swift
//  World
//
//  Created by Shyam Kumar on 7/8/23.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    var data: Data? {
        guard let dictionary = dictionary else { return nil }
        return try? JSONSerialization.data(withJSONObject: dictionary as Any)
    }
}
