//
//  FixedLengthArray.swift
//  World
//
//  Created by Shyam Kumar on 7/9/23.
//

import Foundation

/// 1-indexed array that performs a "soft-delete" on elements
public struct FixedLengthArray<Element: Codable & Equatable>: Codable, Equatable {
    struct DeletableElement: Codable, Equatable {
        var element: Element
        var isDeleted: Bool = false
    }
    
    private var _elements: [DeletableElement]
    public var elements: [Element] {
        _elements
            .filter({ !$0.isDeleted })
            .map({ $0.element })
    }
    
    public var count: Int {
        elements.count
    }
    
    public init(_ elements: Element...) {
        self._elements = elements.map({ .init(element: $0) })
    }
    
    public init(_ elements: [Element]) {
        self._elements = elements.map({ .init(element: $0) })
    }
    
    public func get(_ index: Int) -> Element? {
        guard index <= _elements.count && index > 0 else { fatalError() }
        let deletableElement = _elements[index - 1]
        guard !deletableElement.isDeleted else { return nil }
        return deletableElement.element
    }
    
    public mutating func remove(_ index: Int) {
        guard index <= _elements.count && index > 0 else { fatalError() }
        let deletableElement = _elements[index - 1]
        guard !deletableElement.isDeleted else {
            fatalError("Cannot delete element that has already been deleted")
        }
        _elements[index - 1].isDeleted = true
    }
    
    /// Unsafe accessor - use `get` for safe optional return value
    public subscript(index: Int) -> Element {
        return get(index)!
    }
}

extension FixedLengthArray where Element: Identifiable {
    public mutating func remove(_ element: Element) {
        guard let index = _elements.firstIndex(where: { $0.element == element }) else {
            fatalError("Element with id \(element.id) not in array")
        }
        
        self.remove(index + 1) // 1-indexed
    }
}
