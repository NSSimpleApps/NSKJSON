//
//  NSKPlainNumberParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 03.04.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation


struct NSKPlainNumberParser<Options: NSKOptions> {
    typealias Byte = Options.Byte
    typealias Buffer = Options.Buffer
    typealias Index = Buffer.Index
    
    private init() {}
    
    /// parse number according to the plain JSON format
    static func parseNumber(buffer: Buffer, from: Index) throws -> (number: Any, length: Int)? {
        if buffer.distance(from: from, to: buffer.endIndex) >= 1 {
            let byte = buffer[from]
            let signPart: [UInt8]
            let integerPart: [UInt8]
            
            if let minus = Options.minus(byte) {
                if case let digits = self.integerPart(buffer: buffer, from: from + 1), digits.isEmpty == false {
                    signPart = [minus]
                    integerPart = digits
                } else {
                    throw NSKJSONError.error(description: "Expected digit at \(from).")
                }
            } else if Options.plus(byte) != nil {
                throw NSKJSONError.error(description: "Leading '+' is not allowed at \(from).")
                
            } else {
                signPart = []
                integerPart = self.integerPart(buffer: buffer, from: from)
            }
            
            if integerPart.isEmpty {
                return nil
            } else {
                let integerCount = signPart.count + integerPart.count
                let index = from + integerCount
                
                if integerPart.count > 1 && integerPart[0] == 0x30 {
                    throw NSKJSONError.error(description: "Leading '0' is not allowed at \(index).")
                }
                
                if let decimalPart = try self.decimalPart(buffer: buffer, from: index) {
                    let double = self.double(digits: signPart + integerPart + decimalPart)
                    if double.isNaN || double.isInfinite {
                        throw NSKJSONError.error(description: "Invalid number format at \(from).")
                    } else {
                        return (double, integerCount + decimalPart.count)
                    }
                } else {
                    if let int = self.int(digits: integerPart, radix: 10, isNegative: signPart.isEmpty == false) {
                        return (int, integerCount)
                    } else {
                        throw NSKJSONError.error(description: "Number does not fit in Int at \(from).")
                    }
                }
            }
        } else {
            return nil
        }
    }
    
    static func decimalPart(buffer: Buffer, from: Index) throws -> [UInt8]? {
        if buffer.distance(from: from, to: buffer.endIndex) < 1 {
            return nil
        } else {
            let decimalPart: [UInt8]
            if let dot = Options.dot(buffer[from]) {
                let nextIndex = from + 1
                
                if case let digits = self.integerPart(buffer: buffer, from: nextIndex), digits.isEmpty == false {
                    decimalPart = [dot] + digits
                } else {
                    throw NSKJSONError.error(description: "Expected digits at \(nextIndex).")
                }
            } else {
                decimalPart = self.integerPart(buffer: buffer, from: from)
            }
            
            if let exponentPart = try self.exponentPart(buffer: buffer, from: from + decimalPart.count, exponent: Options.e(_:)) {
                return decimalPart + exponentPart
            } else {
                if decimalPart.isEmpty {
                    return nil
                } else {
                    return decimalPart
                }
            }
        }
    }
    static func integerPart(buffer: Buffer, from: Index) -> [UInt8] {
        if case let endIndex = buffer.endIndex, from < endIndex {
            var result: [UInt8] = []
            for index in from..<endIndex {
                if let digit = Options.digit(buffer[index]) {
                    result.append(digit)
                } else {
                    break
                }
            }
            return result
        } else {
            return []
        }
    }
    static func exponentPart(buffer: Buffer, from: Index, exponent: (Byte) -> UInt8?) throws -> [UInt8]? {
        let endIndex = buffer.endIndex
        if buffer.distance(from: from, to: endIndex) >= 1 {
            if let exponent = exponent(buffer[from]) {
                if case let nextIndex = from + 1, nextIndex < endIndex {
                    let predix: [UInt8]
                    let index: Index
                    let nextByte = buffer[nextIndex]
                    
                    if let minus = Options.minus(nextByte) {
                        predix = [exponent, minus]
                        index = nextIndex + 1
                    } else if let plus = Options.plus(nextByte) {
                        predix = [exponent, plus]
                        index = nextIndex + 1
                    } else {
                        predix = [exponent]
                        index = nextIndex
                    }
                    if case let digits = self.integerPart(buffer: buffer, from: index), digits.isEmpty == false {
                        return predix + digits
                    } else {
                        throw NSKJSONError.error(description: "Expected digits at \(index).")
                    }
                } else {
                    throw NSKJSONError.error(description: "Expected digits at \(from).")
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    static func int(digits: [UInt8], radix: Int, isNegative: Bool) -> Int? {
        var result: Int = 0
        let sign = isNegative ? -1 : 1
        
        for digit in digits {
            let (partialValue, overflow) = result.multipliedReportingOverflow(by: radix)
            if overflow {
                return nil
            } else {
                let (partialValue, overflow) = partialValue.addingReportingOverflow(sign * Int(digit - 0x30))
                if overflow {
                    return nil
                } else {
                    result = partialValue
                }
            }
        }
        return result
    }
    
    static func double(digits: [UInt8]) -> Double {
        return digits.withUnsafeBytes { (raw) -> Double in
            return atof(raw.bindMemory(to: Int8.self).baseAddress)
        }
    }
}
