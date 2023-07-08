//
//  World.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import Foundation

public enum CacheStoreOption: String, Codable {
    case object
    case array
}

public enum CacheKey: String, Codable {
    case seasons
    
    public var path: URL {
        .documents.appendingPathComponent(rawValue)
    }
}

public enum CacheReadResult<T: Cacheable> {
    case object(T?)
    case array([T])
}

public protocol Cacheable: Codable {
    static var key: CacheKey { get }
    static var storeOption: CacheStoreOption { get }
    func store()
    static func read() -> CacheReadResult<Self>
    static func clearCache()
}

public extension Cacheable {
    static var storeOption: CacheStoreOption { .object }
    
    func store() {
        switch Self.storeOption {
        case .object:
            save(self)
        case .array:
            let arrayToSave = Self.read(type: [Self].self) ?? []
            save(arrayToSave + [self])
        }
    }
    
    static func read() -> CacheReadResult<Self> {
        switch Self.storeOption {
        case .object:
            return .object(read(type: Self.self))
        case .array:
            return .array(read(type: [Self].self) ?? [])
        }
    }
    
    static func clearCache() {
        guard FileManager.default.fileExists(atPath: Self.key.path.path()) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: Self.key.path)
        } catch {
            print(error)
            fatalError()
        }
    }
    
    private func save<T: Codable>(_ obj: T) {
        do {
            let data = try JSONEncoder().encode(obj)
            try data.write(to: Self.key.path)
        } catch {
            print("Unable to save!!!")
            fatalError()
        }
    }
    
    private static func read<T: Codable>(type: T.Type) -> T? {
        do {
            let data = try Data(contentsOf: Self.key.path)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            return nil
        }
    }
}

// MARK: - Helpers
extension URL {
    static var documents: URL {
        return FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
