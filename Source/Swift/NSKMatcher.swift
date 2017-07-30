//
//  NSKMatcher.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 25.06.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//


import Foundation

internal class NSKMatcher<C> where C: Collection, C.Iterator.Element: Equatable, C.Iterator.Element == C.SubSequence.Iterator.Element {
    
    private init() {}
    
    internal typealias Element = C.Iterator.Element
    
    internal enum Result {
        
        case outOfRange
        case lengthMismatch
        case mismatch(index: C.Index)
        case match
    }
    
    internal static func skip(buffer: C, from: C.Index, where predicate: (Element, C.Index) -> Bool) -> C.Index {
        
        var index = from
        
        while index < buffer.endIndex && predicate(buffer[index], index) {
            
            index = buffer.index(after: index)
        }
        
        return index
    }
    
    internal static func match(buffer: C, from: C.Index, length: C.IndexDistance, where predicate: (Element, C.Index) -> Bool) -> Result {
        
        if from >= buffer.endIndex {
            
            return .outOfRange
            
        } else if length > buffer.distance(from: from, to: buffer.endIndex) {
            
            return .lengthMismatch
            
        } else {
            
            let endIndex = buffer.index(from, offsetBy: length)
            var index = from
            
            while index < endIndex {
                
                if predicate(buffer[index], index) == false {
                    
                    return .mismatch(index: index)
                }
                
                index = buffer.index(after: index)
            }
            
            return .match
        }
    }
    
    internal static func match<S: Sequence>(buffer: C, from: C.Index, sequence: S) -> Result where S.Iterator.Element == Element {
        
        if from >= buffer.endIndex {
            
            return .outOfRange
            
        } else {
            
            var index = from
            
            for elem in sequence {
                
                if index >= buffer.endIndex {
                    
                    return .lengthMismatch
                    
                } else if elem != buffer[index] {
                    
                    return .mismatch(index: index)
                }
                
                index = buffer.index(after: index)
            }
            
            return .match
        }
    }
}
