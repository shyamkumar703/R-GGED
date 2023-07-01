//
//  NonEmptyCircularArray.swift
//  World
//
//  Created by Shyam Kumar on 6/30/23.
//

import Foundation

struct NonEmptyCircularArray<T> {
    private var head: T
    private var tail: [T]
    
    public init(_ elements: T...) {
        self.head = elements.first!
        var interTail = [T]()
        for elementIndex in 1..<elements.count {
            interTail.append(elements[elementIndex])
        }
        
        self.tail = interTail
    }
    
    public init(_ elements: [T]) {
        self.head = elements.first!
        var interTail = [T]()
        for elementIndex in 1..<elements.count {
            interTail.append(elements[elementIndex])
        }
        
        self.tail = interTail
    }
    
    public mutating func getFirst() -> T {
        guard let newHead = tail.popFirst() else {
            // tail is empty
            return head
        }
        let tempHead = head
        self.head = newHead
        tail.append(tempHead)
        return tempHead
    }
    
    public func toArray() -> [T] {
        return [head] + tail
    }
}

extension NonEmptyCircularArray: CustomStringConvertible {
    var description: String {
        return ([head] + tail).description
    }
}

extension Array {
    mutating func popFirst() -> Element? {
        guard let first else { return nil }
        self.removeFirst()
        return first
    }
}
