//
//  NSKJSON5NumberParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 15.04.17.
//
//

import Foundation

internal final class NSKJSON5NumberParser: NSKPlainNumberParser {
    
    internal static func iss(_ prefix: UInt8) -> Bool {
        
        return prefix.isDigit || prefix == NSKMinus || prefix == NSKDot || prefix == NSKPlus || prefix == NSKI || prefix == NSKN
    }
    
    internal override static func isNumberPrefix(_ prefix: UInt8) -> Bool {
        
        return prefix.isDigit || prefix == NSKMinus || prefix == NSKDot || prefix == NSKPlus || prefix == NSKI || prefix == NSKN
    }
    
    internal static func validateInfinity(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws {
        
        if self.validateSequence([NSKI, NSKn, NSKf, NSKi, NSKn, NSKi, NSKt, NSKy], buffer: buffer, from: from) == false {
            
            throw NSKJSONError.error(description: "Expected 'Infinity' at \(from).")
        }
    }
    
    internal static func validateNaN(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws {
        
        if self.validateSequence([NSKN, NSKa, NSKN], buffer: buffer, from: from) == false {
            
            throw NSKJSONError.error(description: "Expected 'NaN' at \(from).")
        }
    }
    
    /// [hex]*
    internal static func skipHex(buffer: UnsafeBufferPointer<UInt8>, from: Int) -> Int {
        
        var index = from
        
        while index < buffer.endIndex {
            
            if buffer[index].isHex {
                
                index += 1
                
            } else {
                
                break
            }
        }
        return index - from
    }
    
    internal static func validateHexFraction(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> Int {
        
        let hexLength = self.skipHex(buffer: buffer, from: from)
        
        if hexLength == 0 {
            
            throw NSKJSONError.error(description: "Expected hex at \(from).")
        }
        
        let index = from + hexLength
        
        if index >= buffer.endIndex || terminator.contains(buffer: buffer, at: index) {
            
            return index - from
            
        } else if case let exponent = buffer[index], exponent == NSKp || exponent == NSKP  {
            
            let expLength = try self.validateExponent(buffer: buffer, from: index, exponents: [exponent], terminator: terminator)
            
            return index + expLength - from
            
        } else {
            
            throw NSKJSONError.error(description: "Expected 'p' or 'P' at \(index).")
        }
    }
    
    // [hex]+ or [hex]+\.[hex]+[pP][+-][0-9]+
    internal override static func validateHexFormat(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (isAFloatingPoint: Bool, length: Int) {
        
        let hexLength = self.skipHex(buffer: buffer, from: from)
        let index = from + hexLength
        
        if terminator.contains(buffer: buffer, at: index) {
            
            return (false, index - from)
        }
        
        let byte = buffer[index]
        
        if byte == NSKDot && index < buffer.endIndex - 1 {
            
            let nextIndex = index + 1
            let fractionLength = try self.validateHexFraction(buffer: buffer, from: nextIndex, terminator: terminator)
            
            return (true, nextIndex + fractionLength - from)
            
        } else if byte == NSKP || byte == NSKp {
                
            let expLength = try self.validateExponent(buffer: buffer, from: index, exponents: [byte], terminator: terminator)
            
            return (true, index + expLength - from)
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid hex number format at \(from).")
        }
    }
    
    /// (-)?0  or  -0.[0-9]+  or (-)?[1-9]
    internal override static func validatePrefix(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> NSKPrefixValidation {
        
        var index = from
        let b0 = buffer[index]
        var hasMinus = false
        
        if b0 == NSKPlus || b0 == NSKMinus {
            
            index += 1
            
            hasMinus = b0 == NSKMinus
        }
        
        if index >= buffer.endIndex {
            
            throw NSKJSONError.error(description: "Invalid number format at \(index).")
        }
        
        if buffer[index] == NSKI {
            
            do {
                
                try self.validateInfinity(buffer: buffer, from: index)
                
                let result: Double
                
                if hasMinus {
                    
                    result = -Double.infinity
                    
                } else {
                    
                    result = Double.infinity
                }
                
                return NSKPrefixValidation.result(value: result, length: 8 + index - from)
                
            } catch {
                
                throw error
            }
        }
        
        if buffer[index] == NSKN {
            
            do {
                
                try self.validateNaN(buffer: buffer, from: index)
                
                return NSKPrefixValidation.result(value: Double.nan, length: 3 + index - from)
                
            } catch {
                
                throw error
            }
        }
        
        if buffer[index] == NSKDot {
            
            index += 1
            
            if index >= buffer.endIndex || buffer[index].isDigit == false {
                
                throw NSKJSONError.error(description: "Expected digit, '.', 'Infinity' or 'NaN' at \(index).")
                
            } else {
                
                return NSKPrefixValidation.validator(validator: .number, hasDecimalMarker: true, length: index - from)
            }
            
        } else if index < buffer.endIndex - 2 && buffer[index].isZero && (buffer[index + 1] == NSKx || buffer[index + 1] == NSKX) {
            
            return NSKPrefixValidation.validator(validator: .hex, hasDecimalMarker: false, length: index + 2 - from)
            
        } else if buffer[index].isDigit {
            
            return NSKPrefixValidation.validator(validator: .number, hasDecimalMarker: false, length: index - from)
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid number format at \(index).")
        }
    }
    
    internal override static func validateAfterPoint(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) -> (isValid: Bool, hasTerminator: Bool) {
        
        if terminator.contains(buffer: buffer, at: from) {
            
            return (true, true)
            
        } else if case let byte = buffer[from], byte == NSKE || byte == NSKe {
            
            return (true, false)
            
        } else {
            
            return super.validateAfterPoint(buffer: buffer, from: from, terminator: terminator)
        }
    }
    
    internal override static func validateIntegerBeforeExponent(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> Int {
        
        return self.skipInteger(buffer: buffer, from: from)
    }
    
    internal override static func validateDouble(_ double: Double, index: Int) throws {
        
        
    }
}

