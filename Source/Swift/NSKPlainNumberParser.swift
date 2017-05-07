//
//  NSKPlainNumberParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 03.04.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation

internal enum NSKValidator {
    
    case number
    case fraction(Set<UInt8>)
    case exponential(UInt8)
    case hex
}

internal enum NSKBase {
    
    case decimal
    case hex
    
    var baseValue: Int32 {
        
        switch self {
            
        case .decimal:
            return 10
            
        case .hex:
            return 16
        }
    }
}

internal enum NSKPrefixValidation {
    
    case result(value: Any, length: Int)
    case validator(validator: NSKValidator, hasDecimalMarker: Bool, length: Int)
}

internal class NSKPlainNumberParser {
    
    private init() {}
    
    internal class func isNumberPrefix(_ prefix: UInt8) -> Bool {
        
        return prefix.isDigit || prefix == NSKMinus
    }
    
    internal class func validateHexFormat(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (isAFloatingPoint: Bool, length: Int) {
        
        throw NSKJSONError.error(description: "Error at \(from). Hex format is not supported.")
    }
    
    /// [0-9]*
    internal static func skipInteger(buffer: UnsafeBufferPointer<UInt8>, from: Int) -> Int {
        
        var index = from
        
        while index < buffer.endIndex {
            
            if buffer[index].isDigit {
                
                index += 1
                
            } else {
                
                break
            }
        }
        return index - from
    }
    
    internal class func validateAfterPoint(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) -> (isValid: Bool, hasTerminator: Bool) {
        
        if from < buffer.endIndex && buffer[from].isDigit {
            
            return (true, false)
            
        } else {
            
            return (false, false)
        }
    }
    
    /// [0-9]+(\.)?[0-9]+([eE])?([+-])?[0-9]+
    internal static func validateSeparator(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (hasDecimalMarker: Bool, hasTerminator: Bool) {
        
        if terminator.contains(buffer: buffer, at: from) {
            
            return (false, true)
            
        } else {
            
            let byte = buffer[from]
            let error = NSKJSONError.error(description: "Expected digit, exponent or '.' at \(from).")
            
            if byte == NSKDot {
                
                let (isValid, hasTerminator) = self.validateAfterPoint(buffer: buffer, from: from + 1, terminator: terminator)
                
                if isValid {
                    
                    return (true, hasTerminator)
                    
                } else {
                    
                    throw error
                }
                
            } else if byte.isDigit {
                
                return (false, false)
                
            } else {
                
                throw error
            }
        }
    }
    
    /// [0-9]+(\.)?[0-9]+([eE])?([+-])?[0-9]+
    internal static func validateNumber(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (isAFloatingPoint: Bool, length: Int) {
        
        let index = from + self.skipInteger(buffer: buffer, from: from)
        
        if terminator.contains(buffer: buffer, at: index) {
            
            return (false, index - from)
        }
        
        let byte = buffer[index]
        
        if byte == NSKE || byte == NSKe {
            
            let exponentialLength = try self.validateExponent(buffer: buffer, from: index, exponents: [byte], terminator: terminator)
            
            return (true, index + exponentialLength - from)
            
        } else {
            
            let (hasDecimalMarker, hasTerminator) = try self.validateSeparator(buffer: buffer, from: index, terminator: terminator)
            
            if hasTerminator {
                
                if hasDecimalMarker {
                    
                    return (hasDecimalMarker, index + 1 - from)
                    
                } else {
                    
                    return (hasDecimalMarker, index - from)
                }
                
            } else {
                
                let nextIndex = index + 1
                let fractionLength = try self.validateFraction(buffer: buffer, from: nextIndex, exponents: [NSKE, NSKe], terminator: terminator)
                
                return (true, nextIndex + fractionLength - from)
            }
        }
    }
    
    internal class func validateIntegerBeforeExponent(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> Int {
        
        let integerLength = self.skipInteger(buffer: buffer, from: from)
        
        if integerLength == 0 {
            
            throw NSKJSONError.error(description: "Expected digits at \(from).")
            
        } else {
            
            return integerLength
        }
    }
    
    /// [0-9]+([eE])?([+-])?[0-9]+
    internal static func validateFraction(buffer: UnsafeBufferPointer<UInt8>, from: Int, exponents: Set<UInt8>, terminator: NSKTerminator.Type) throws -> Int {
        
        let integerLength = try self.validateIntegerBeforeExponent(buffer: buffer, from: from)
        
        let index = from + integerLength
        
        if index >= buffer.endIndex || terminator.contains(buffer: buffer, at: index) {
            
            return index - from
            
        } else if case let exponent = buffer[index], exponents.contains(exponent) {
            
            let expLength = try self.validateExponent(buffer: buffer, from: index, exponents: [exponent], terminator: terminator)
            
            return index + expLength - from
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid number format at \(index).")
        }
    }
    
    /// [eE][+-]?[0-9]+
    internal static func validateExponent(buffer: UnsafeBufferPointer<UInt8>, from: Int, exponents: Set<UInt8>, terminator: NSKTerminator.Type) throws -> Int {
        
        var index = from
        
        if case let exponent = buffer[index], exponents.contains(exponent) == false {
            
            throw NSKJSONError.error(description: "Expected \(UnicodeScalar(exponent)) at \(index).")
            
        } else {
            
            index += 1
        }
        
        if index >= buffer.endIndex {
            
            throw NSKJSONError.error(description: "Expected digit or '+-' at \(index).")
        }
        
        if buffer[index] == NSKPlus || buffer[index] == NSKMinus {
            
            index += 1
        }
        
        if index >= buffer.endIndex || buffer[index].isDigit == false {
            
            throw NSKJSONError.error(description: "Expected digit at \(index).")
        }
        
        let expLength = self.skipInteger(buffer: buffer, from: index)
        let endIndex = index + expLength
        
        if terminator.contains(buffer: buffer, at: endIndex) {
            
            return endIndex - from
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid exponential format at \(endIndex).")
        }
    }
    
    /// (-)?0  or  -0.[0-9]+  or (-)?[1-9]
    internal class func validatePrefix(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> NSKPrefixValidation {
        
        var index = from
        
        if buffer[index] == NSKPlus {
            
            throw NSKJSONError.error(description: "Leading '+' at \(index).")
        }
        
        if buffer[index].isNonZeroDigit {
            
            return NSKPrefixValidation.validator(validator: .number, hasDecimalMarker: false, length: 0)
        }
        
        if buffer[index] == NSKMinus {
            
            index += 1
            
            if index >= buffer.endIndex || buffer[index].isDigit == false {
                
                throw NSKJSONError.error(description: "Expected digit after '-' at \(index).")
            }
        }
        
        var hasLeadingZero = false
        
        if buffer[index].isZero {
            
            if index == buffer.endIndex - 1 {
                
                return NSKPrefixValidation.result(value: 0, length: index + 1 - from)
                
            } else {
                
                index += 1
                
                if terminator.contains(buffer: buffer, at: index) {
                    
                    return NSKPrefixValidation.result(value: 0, length: index - from)
                }
            }
            
            hasLeadingZero = true
        }
        
        if buffer[index].isNonZeroDigit {
            
            if hasLeadingZero {
                
                throw NSKJSONError.error(description: "Leading zero at \(index).")
                
            } else {
                
                return NSKPrefixValidation.validator(validator: .number, hasDecimalMarker: false, length: index - from)
            }
        }
        
        if buffer[index] == NSKDot {
            
            if index == buffer.endIndex - 1 || terminator.contains(buffer: buffer, at: index + 1) {
                
                throw NSKJSONError.error(description: "Number with decimal point but no additional digits around character \(index).")
            }
            
            index += 1
            
            if buffer[index].isDigit {
                
                return NSKPrefixValidation.validator(validator: .fraction([NSKe, NSKE]), hasDecimalMarker: true, length: index - from)
                
            } else {
                
                throw NSKJSONError.error(description: "Expected digit after \(index).")
            }
            
        } else if case let exponent = buffer[index], exponent == NSKe || exponent == NSKE {
            
            return NSKPrefixValidation.validator(validator: .exponential(exponent), hasDecimalMarker: true, length: index - from)
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid number format at \(index).")
        }
    }
    
    internal static func parseDouble(buffer: UnsafeBufferPointer<UInt8>, from: Int, length: Int) -> (number: Double, numberLength: Int) {
        
        let doublePointer = UnsafeMutablePointer<Int8>.allocate(capacity: length)
        defer { doublePointer.deallocate(capacity: length) }
        
        memcpy(doublePointer, buffer.baseAddress?.advanced(by: from), length)
        
        let doubleEndPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
        defer { doubleEndPointer.deallocate(capacity: 1) }
        
        let doubleResult = strtod(doublePointer, doubleEndPointer)
        let doubleDistance = doublePointer.distance(to: doubleEndPointer[0]!)
        
        return (doubleResult, doubleDistance)
    }
    
    internal static func parseInteger(buffer: UnsafeBufferPointer<UInt8>, from: Int, length: Int, base: NSKBase) -> (number: Int, numberLength: Int) {
        
        let intPointer = UnsafeMutablePointer<Int8>.allocate(capacity: length)
        defer { intPointer.deallocate(capacity: length) }
        
        memcpy(intPointer, buffer.baseAddress?.advanced(by: from), length)
        
        let intEndPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
        defer { intEndPointer.deallocate(capacity: 1) }
        
        let intResult = strtol(intPointer, intEndPointer, base.baseValue)
        let intDistance = intPointer.distance(to: intEndPointer[0]!)
        
        return (intResult, intDistance)
    }
    
    /// parse number in the plain JSON format
    internal static func parseNumber(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (number: Any, length: Int) {
        
        let prefix = try self.validatePrefix(buffer: buffer, from: from, terminator: terminator)
        
        switch prefix {
            
        case .result(let value, let length):
            return (value, length)
        
        case .validator(let validator, let hasDecimalMarker, let prefixLength):
            
            let isFloatingPoint: Bool
            let remainingLength: Int
            var base = NSKBase.decimal
            
            switch validator {
                
            case .number:
                
                (isFloatingPoint, remainingLength) = try self.validateNumber(buffer: buffer, from: from + prefixLength, terminator: terminator)
                
            case .fraction(let exponents):
                remainingLength = try self.validateFraction(buffer: buffer, from: from + prefixLength, exponents: exponents, terminator: terminator)
                isFloatingPoint = true
                
            case .exponential(let exponent):
                remainingLength = try self.validateExponent(buffer: buffer, from: from + prefixLength, exponents: [exponent], terminator: terminator)
                isFloatingPoint = true
            
            case .hex:
                (isFloatingPoint, remainingLength) = try self.validateHexFormat(buffer: buffer, from: from + prefixLength, terminator: terminator)
                base = NSKBase.hex
            }
            
            let totalLength = prefixLength + remainingLength
            
            let number: Any
            let numberLength: Int
            
            if isFloatingPoint || hasDecimalMarker {
                
                let (double, length) = self.parseDouble(buffer: buffer, from: from, length: totalLength)
                
                do {
                    
                    try self.validateDouble(double, index: from)
                    
                    (number, numberLength) = (double, length)
                    
                } catch {
                    
                    throw error
                }
                
            } else {
                
                let (integer, length) = self.parseInteger(buffer: buffer, from: from, length: totalLength, base: base)
                
                (number, numberLength) = (integer, length)
            }
            
            if totalLength != numberLength {
                
                throw NSKJSONError.error(description: "Invalid number format at \(from).")
            }
            
            return (number, totalLength)
        }
    }
    
    internal class func validateDouble(_ double: Double, index: Int) throws {
        
        if double.isNaN {
            
            throw NSKJSONError.error(description: "Number wound up as NaN around character \(index).")
            
        } else if double.isInfinite {
            
            throw NSKJSONError.error(description: "Number wound up as Infinity around character \(index).")
        }
    }
    
    internal static func validateSequence(_ sequence: [UInt8], buffer: UnsafeBufferPointer<UInt8>, from: Int) -> Bool {
        
        let length = buffer.endIndex - from
        
        if sequence.isEmpty || length < sequence.count {
            
            return false
            
        } else {
            
            return Array(buffer[from..<(from + sequence.count)]) == sequence
        }
    }
}

