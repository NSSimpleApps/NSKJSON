//
//  NSKPlainNumberParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 03.04.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation


internal final class NSKPlainNumberParser<C> where C: Collection, C.Iterator.Element: UnsignedInteger, C.Index == Int {
    
    internal typealias Byte = C.Iterator.Element
    internal typealias Terminator = (_ buffer: C, _ index: Int) -> Bool
    
    internal let options: NSKOptions<Byte>
    
    internal init(options: NSKOptions<Byte>) {
        
        self.options = options
    }
    
    internal static func isValidPrefix(_ prefix: Byte, options: NSKOptions<Byte>) -> Bool {
        
        return options.isDigit(prefix) || prefix == options.minus
    }
    
    internal func validateNumber(buffer: C, from: Int, terminator: Terminator) throws -> (isAFloatingPoint: Bool, length: Int) {
        
        let endIndex = buffer.endIndex - 1
        var index = from
        
        if buffer[index] == self.options.minus {
            
            index += 1
        }
        
        if index > endIndex || self.options.isDigit(buffer[index]) == false {
            
            throw NSKJSONError.error(description: "Expected digit at \(index).")
        }
        
        if self.options.isZero(buffer[index]) {
            
            index += 1
            
            if index > endIndex || terminator(buffer, index) {
                
                return (false, index - from)
            }
            
            let byte = buffer[index]
            
            if self.options.isDigit(byte) {
                
                throw NSKJSONError.error(description: "Number with leading zero around character \(index).")
            }
        }
        
        index = NSKNumberHelper<C>.skipDigits(buffer: buffer, from: index, options: self.options)
        
        if index > endIndex || terminator(buffer, index) {
            
            return (false, index - from)
        }
        
        let byte = buffer[index]
        
        if byte == self.options.dot {
            
            index += 1
                
            if index > endIndex || self.options.isDigit(buffer[index]) == false {
                    
                throw NSKJSONError.error(description: "Number with decimal point but no additional digits around character \(index).")
                    
            } else {
                    
                index = NSKNumberHelper<C>.skipDigits(buffer: buffer, from: index, options: self.options)
                    
                if index > endIndex || terminator(buffer, index) {
                        
                    return (true, index - from)
                        
                } else if case let byte = buffer[index], byte == self.options.e || byte == self.options.E {
                    
                    index = try NSKNumberHelper<C>.validateExponent(buffer: buffer, from: index + 1, options: self.options, terminator: terminator)
                    
                    return (true, index - from)
                        
                } else {
                        
                    throw NSKJSONError.error(description: "Expected digit, 'e' or 'E' at \(index).")
                }
            }
                
        } else if byte == self.options.e || byte == self.options.E {
            
            index = try NSKNumberHelper<C>.validateExponent(buffer: buffer, from: index + 1, options: self.options, terminator: terminator)
            
            return (true, index - from)
            
        } else {
                
            throw NSKJSONError.error(description: "Invalid number format at \(index).")
        }
    }
    
    /// parse number in the plain JSON format
    internal func parseNumber(buffer: C, from: Int, terminator: Terminator) throws -> (number: Any, length: Int) {
        
        let (isAFloatingPoint, length) = try self.validateNumber(buffer: buffer, from: from, terminator: terminator)
        
        let string = options.string(bytes: buffer[from..<(from + length)])!
        
        let number: Any
        let numberLength: Int
        
        if isAFloatingPoint {
            
            let (double, doubleLength) = NSKNumberHelper<C>.parseDouble(buffer: buffer, string: string)
            
            if double.isNaN {
                
                throw NSKJSONError.error(description: "Number wound up as NaN around character \(from).")
                
            } else if double.isInfinite {
                
                throw NSKJSONError.error(description: "Number wound up as Infinity around character \(from).")
            }
            
            (number, numberLength) = (double, doubleLength)
            
        } else {
            
            let (integer, integerLength) = NSKNumberHelper<C>.parseInteger(buffer: buffer, base: 10, string: string)
            
            (number, numberLength) = (integer, integerLength)
        }
        
        if length != numberLength {
            
            throw NSKJSONError.error(description: "Invalid number format at \(from).")
        }
        
        return (number, numberLength)
    }
}
