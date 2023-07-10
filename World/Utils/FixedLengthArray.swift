//
//  FixedLengthArray.swift
//  World
//
//  Created by Shyam Kumar on 7/9/23.
//

import Foundation

/// 1-indexed array that performs a "soft-delete" on elements
public struct FixedLengthArray<Element: Codable>: Codable {
    struct DeletableElement: Codable {
        var element: Element
        var isDeleted: Bool = false
    }
    
    private var elements: [DeletableElement]
    
    public init(_ elements: Element...) {
        self.elements = elements.map({ .init(element: $0) })
    }
    
    public init(_ elements: [Element]) {
        self.elements = elements.map({ .init(element: $0) })
    }
    
    public func get(_ index: Int) -> Element? {
        guard index <= elements.count && index > 0 else { fatalError() }
        let deletableElement = elements[index - 1]
        guard !deletableElement.isDeleted else { return nil }
        return deletableElement.element
    }
    
    public mutating func remove(_ index: Int) {
        guard index <= elements.count && index > 0 else { fatalError() }
        let deletableElement = elements[index - 1]
        guard !deletableElement.isDeleted else {
            fatalError("Cannot delete element that has already been deleted")
        }
        elements[index - 1].isDeleted = true
    }
}
