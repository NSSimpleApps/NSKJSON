//
//  NSKJSON5NumberParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 15.04.17.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation


internal final class NSKJSON5NumberParser<C> where C: Collection, C.Iterator.Element: UnsignedInteger, C.Index == Int {
    
    internal typealias Byte = C.Iterator.Element
    internal typealias Terminator = (_ buffer: C, _ index: Int) -> Bool
    
    internal let options: NSKOptions<Byte>
    
    internal init(options: NSKOptions<Byte>) {
        
        self.options = options
    }
    
    internal static func isValidPrefix(_ prefix: Byte, options: NSKOptions<Byte>) -> Bool {
        
        return NSKPlainNumberParser<C>.isValidPrefix(prefix, options: options) || prefix == options.dot || prefix == options.plus || prefix == options.I || prefix == options.N
    }
    
    internal func validateNumber(buffer: C, from: Int, terminator: Terminator) throws -> (isAFloatingPoint: Bool, base: Int32, length: Int) {
        
        let endIndex = buffer.endIndex - 1
        var index = from
        
        if buffer[index] == self.options.plus || buffer[index] == self.options.minus {
            
            index += 1
        }
        
        if index > endIndex {
            
            throw NSKJSONError.error(description: "Expected digit, '.', Infinity or NaN at \(index).")
        }
        
        if buffer[index] == self.options.I {
            
            let infinityMatch = NSKMatcher.match(buffer: buffer,
                                                 from: index + 1,
                                                 sequence: [self.options.n,
                                                            self.options.f,
                                                            self.options.i,
                                                            self.options.n,
                                                            self.options.i,
                                                            self.options.t,
                                                            self.options.y])
            
            switch infinityMatch {
            case .match:
                return (true, 10, index - from + 8)
                
            default:
                throw NSKJSONError.error(description: "Expected Infinity at \(index).")
            }
            
        } else if buffer[index] == self.options.N {
            
            let nanMatch = NSKMatcher.match(buffer: buffer,
                                            from: index + 1,
                                            sequence: [self.options.a, self.options.N])
            
            switch nanMatch {
            case .match:
                return (true, 10, index - from + 3)
                
            default:
                throw NSKJSONError.error(description: "Expected NaN at \(index).")
            }
        }
        
        if self.options.isZero(buffer[index]) && index < endIndex - 1 && (buffer[index + 1] == self.options.x || buffer[index + 1] == self.options.X) {
            
            index += 2
            
            if case let integerPartHexOffset = NSKNumberHelper<C>.skipHex(buffer: buffer, from: index, options: self.options) - index, integerPartHexOffset > 0 {
                
                index += integerPartHexOffset
                
                if index > endIndex || terminator(buffer, index) {
                    
                    return (false, 16, index - from)
                    
                } else {
                    
                    if buffer[index] == self.options.dot {
                        
                        index += 1
                    }
                    
                    if index > endIndex || terminator(buffer, index) {
                        
                        return (true, 16, index - from)
                    }
                    
                    index = NSKNumberHelper<C>.skipHex(buffer: buffer, from: index, options: self.options)
                    
                    if index > endIndex || terminator(buffer, index) {
                        
                        return (true, 16, index - from)
                        
                    } else {
                        
                        if buffer[index] == self.options.p || buffer[index] == self.options.P {
                            
                            index += 1
                            index = try NSKNumberHelper<C>.validateExponent(buffer: buffer, from: index, options: self.options, terminator: terminator)
                            
                            if index > endIndex || terminator(buffer, index) {
                                
                                return (true, 16, index - from)
                                
                            } else {
                                
                                throw NSKJSONError.error(description: "Invalid number format at \(index).")
                            }
                            
                        } else {
                            
                            throw NSKJSONError.error(description: "Expected terminator, 'p' or 'P' at \(index).")
                        }
                    }
                }
                
            } else {
                
                throw NSKJSONError.error(description: "Expected hex after '0x' at \(index).")
            }
        }
        
        let leadingDigitsLength = NSKNumberHelper<C>.skipDigits(buffer: buffer, from: index, options: self.options) - index
        
        index += leadingDigitsLength
        
        if (index > endIndex || terminator(buffer, index)) && leadingDigitsLength > 0 {
            
            return (false, 10, index - from)
        }
        
        var hasDot = false
        
        if buffer[index] == self.options.dot {
            
            index += 1
            hasDot = true
        }
        
        index = NSKNumberHelper<C>.skipDigits(buffer: buffer, from: index, options: self.options)
        
        if index > endIndex || terminator(buffer, index) {
            
            return (hasDot, 10, index - from)
        }
        
        if buffer[index] == self.options.e || buffer[index] == self.options.E {
            
            index += 1
            index = try NSKNumberHelper<C>.validateExponent(buffer: buffer, from: index, options: self.options, terminator: terminator)
            
            return (true, 10, index - from)
        }
        
        throw NSKJSONError.error(description: "Invalid number format \(index).")
    }
    
    internal func parseNumber(buffer: C, from: Int, terminator: Terminator) throws -> (number: Any, length: Int) {
        
        let (isAFloatingPoint, base, length) = try self.validateNumber(buffer: buffer, from: from, terminator: terminator)
        
        let string = options.string(bytes: buffer[from..<(from + length)])!
        let number: Any
        let numberLength: Int
        
        if isAFloatingPoint {
            
            let (double, doubleLength) = NSKNumberHelper<C>.parseDouble(buffer: buffer, string: string)
            
            (number, numberLength) = (double, doubleLength)
            
        } else {
            
            let (integer, integerLength) = NSKNumberHelper<C>.parseInteger(buffer: buffer, base: base, string: string)
            
            (number, numberLength) = (integer, integerLength)
        }
        
        if length != numberLength {
            
            throw NSKJSONError.error(description: "Invalid number format at \(from).")
        }
        
        return (number, numberLength)
    }
}

