//
//  NSKTerminator.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 05.03.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation

internal protocol NSKTerminator {
    
    static func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int) -> Bool
}

internal class NSKQuotationTerminator: NSKTerminator {
    
    internal static func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int) -> Bool {
        
        return buffer[index] == NSKQuotationMark
    }
}

internal class NSKSingleQuotationTerminator: NSKTerminator {
    
    internal static func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int) -> Bool {
        
        return buffer[index] == NSKSingleQuotationMark
    }
}


internal class NSKPlainJSONTerminator: NSKTerminator {
    
    internal class func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int) -> Bool {
        
        return self.contains(buffer: buffer, at: index, set: NSKWhitespaces)
    }
    
    internal static func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int, set: Set<UInt8>) -> Bool {
        
        if index >= buffer.endIndex {
            
            return true
            
        } else {
            
            let b = buffer[index]
            
            return set.contains(b) || b == NSKEndArray || b == NSKEndDictionary || b == NSKComma
        }
    }
}

internal class NSKJSON5Terminator: NSKPlainJSONTerminator {
    
    internal override class func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int) -> Bool {
        
        if self.contains(buffer: buffer, at: index, set: NSKJSON5Whitespaces) {
            
            return true
            
        } else {
            
            let length = buffer.endIndex - index
            
            if length >= 2 {
                
                let b0 = buffer[index + 0]
                let b1 = buffer[index + 1]
                
                switch (b0, b1) {
                    
                case (NSKSlash, NSKSlash):
                    return true
                    
                case (NSKSlash, NSKStar):
                    return true
                    
                default:
                    return false
                }
                
            } else {
                
                return false
            }
        }
    }
}

internal class NSKDictionaryKeyTerminator: NSKJSON5Terminator {
    
    internal override static func contains(buffer: UnsafeBufferPointer<UInt8>, at index: Int) -> Bool {
        
        let contains = super.contains(buffer: buffer, at: index)
        
        if contains {
            
            return true
            
        } else {
            
            return buffer[index] == NSKColon
        }
    }
}

