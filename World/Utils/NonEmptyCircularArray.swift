//
//  NonEmptyCircularArray.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import Foundation

public struct NonEmptyCircularArray<Element: Codable>: Codable {
    private var head: Element
    private var tail: [Element]
    
    public var count: Int {
        tail.count + 1
    }
    
    public init(_ elements: Element...) {
        self.head = elements.first!
        var interElementail = [Element]()
        for elementIndex in 1..<elements.count {
            interElementail.append(elements[elementIndex])
        }
        
        self.tail = interElementail
    }
    
    public init(_ elements: [Element]) {
        self.head = elements.first!
        var interElementail = [Element]()
        for elementIndex in 1..<elements.count {
            interElementail.append(elements[elementIndex])
        }
        
        self.tail = interElementail
    }
    
    public mutating func getFirst() -> Element {
        guard let newHead = tail.popFirst() else {
            // tail is empty
            return head
        }
        let tempHead = head
        self.head = newHead
        tail.append(tempHead)
        return tempHead
    }
    
    public func toArray() -> [Element] {
        return [head] + tail
    }
    
    public subscript(index: Int) -> Element {
        if index == 0 { return head }
        return tail[index - 1]
    }
}

extension NonEmptyCircularArray: CustomStringConvertible {
    public var description: String {
        return ([head] + tail).description
    }
}

extension NonEmptyCircularArray: Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for index in 0..<lhs.count {
            guard lhs[index] == rhs[index] else { return false }
        }
        
        return true
    }
}
