//
//  NSKNumberHelper.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 09.07.17.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

internal class NSKNumberHelper<C> where C: Collection, C.Iterator.Element: UnsignedInteger, C.Index == Int, C.Iterator.Element == C.SubSequence.Iterator.Element {
    
    private init() {}
    
    internal typealias Element = C.Iterator.Element
    
    internal static func skipDigits(buffer: C, from: C.Index, options: NSKOptions<Element>) -> C.Index {
        
        return NSKMatcher<C>.skip(buffer: buffer, from: from) { (element, index) -> Bool in
            
            return options.isDigit(element)
        }
    }
    
    internal static func skipHex(buffer: C, from: C.Index, options: NSKOptions<Element>) -> C.Index {
        
        return NSKMatcher<C>.skip(buffer: buffer, from: from) { (element, index) -> Bool in
            
            return options.isHex(element)
        }
    }
    
    internal static func parseDouble(buffer: C, string: String) -> (double: Double, numberLength: Int) {
        
        return string.withCString { (pointer: UnsafePointer<Int8>) -> (number: Double, numberLength: Int) in
            
            let doubleEndPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
            defer { doubleEndPointer.deallocate(capacity: 1) }
            
            let doubleResult = strtod(pointer, doubleEndPointer)
            let doubleDistance = pointer.distance(to: doubleEndPointer[0]!)
            
            return (doubleResult, doubleDistance)
        }
    }
    
    internal static func parseInteger(buffer: C, base: Int32, string: String) -> (integer: Int, numberLength: Int) {
        
        return string.withCString { (pointer: UnsafePointer<Int8>) -> (number: Int, numberLength: Int) in
            
            let intEndPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
            defer { intEndPointer.deallocate(capacity: 1) }
            
            let intResult = strtol(pointer, intEndPointer, base)
            let intDistance = pointer.distance(to: intEndPointer[0]!)
            
            return (intResult, intDistance)
        }
    }
    
    internal static func validateExponent(buffer: C, from: Int, options: NSKOptions<Element>, terminator: (_ buffer: C, _ index: Int) -> Bool) throws -> Int {
        
        let endIndex = buffer.endIndex - 1
        
        if from > endIndex {
            
            throw NSKJSONError.error(description: "Expected '+-' or digit at \(from).")
        }
        
        var index = from
        
        if buffer[index] == options.plus || buffer[index] == options.minus {
            
            index += 1
        }
        
        if index > endIndex {
            
            throw NSKJSONError.error(description: "Number with exponent but no additional digit at \(index).")
        }
        
        if options.isDigit(buffer[index]) {
            
            index = self.skipDigits(buffer: buffer, from: index + 1, options: options)
            
            if index > endIndex || terminator(buffer, index) {
                
                return index
                
            } else {
                
                throw NSKJSONError.error(description: "Invalid exponent format at \(index).")
            }
            
        } else {
            
            throw NSKJSONError.error(description: "Expected digit in exponent at \(index).")
        }
    }
}
