//
//  NSKTerminator.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 05.03.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation

internal struct NSKPlainJSONTerminator<T: Hashable> {
    
    internal let whiteSpaces: Set<T>
    internal let endArray: T
    internal let endDictionary: T
    internal let comma: T
    
    internal func contains<C>(buffer: C, at index: C.Index) -> Bool where C : Collection, C.Iterator.Element == T {
        let b = buffer[index]
        
        return self.whiteSpaces.contains(b) || b == self.endArray || b == self.endDictionary || b == self.comma        
    }
}

internal struct NSKJSON5Comment<T: Hashable> {
    
    internal let slash: T
    internal let star: T
    
    internal func contains<C>(buffer: C, at index: C.Index) -> Bool where C : Collection, C.Iterator.Element == T {
        if buffer.distance(from: index, to: buffer.endIndex) >= 2 {
            let b0 = buffer[index]
            let b1 = buffer[buffer.index(after: index)]
            
            switch (b0, b1) {
            case (self.slash, self.slash):
                return true
            case (self.slash, self.star):
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
}

internal struct NSKJSON5Terminator<T: Hashable> {
    
    internal let terminator: NSKPlainJSONTerminator<T>
    internal let comment: NSKJSON5Comment<T>
    
    internal init(terminator: NSKPlainJSONTerminator<T>, slash: T, star: T) {
        self.terminator = terminator
        self.comment = NSKJSON5Comment(slash: slash, star: star)
    }
    
    internal func contains<C>(buffer: C, at index: C.Index) -> Bool where C : Collection, C.Iterator.Element == T {
        
        if self.terminator.contains(buffer: buffer, at: index) {
            return true
            
        } else {
            return self.comment.contains(buffer: buffer, at: index)
        }
    }
}

internal struct NSKDictionaryKeyTerminator<T: Hashable> {
    internal let terminators: Set<T>
    internal let comment: NSKJSON5Comment<T>
    
    internal init(whiteSpaces: Set<T>, colon: T, slash: T, star: T) {
        self.terminators = whiteSpaces.union([colon])
        self.comment = NSKJSON5Comment(slash: slash, star: star)
    }
    
    internal func contains<C>(buffer: C, at index: C.Index) -> Bool where C : Collection, C.Iterator.Element == T {
        
        if self.terminators.contains(buffer[index]) {
            return true
            
        } else {
            return self.comment.contains(buffer: buffer, at: index)
        }
    }
}

