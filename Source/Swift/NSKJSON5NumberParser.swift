//
//  NSKJSON5NumberParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 15.04.17.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation


struct NSKJSON5NumberParser<Options: NSKOptions> {
    typealias Byte = Options.Byte
    typealias Buffer = Options.Buffer
    typealias Index = Options.Index
    typealias PlainNumberParser = NSKPlainNumberParser<Options>
    
    private init() {}
    
    /// parse number according to the JSON5 format
    static func parseNumber(buffer: Buffer, from: Index) throws -> (number: Any, length: Int)? {
        let endIndex = buffer.endIndex
        if buffer.distance(from: from, to: endIndex) >= 1 {
            let byte = buffer[from]
            let signPart: [UInt8]
            let isNegative: Bool
            
            if let minus = Options.minus(byte) {
                signPart = [minus]
                isNegative = true
            } else if let plus = Options.plus(byte) {
                signPart = [plus]
                isNegative = false
            } else {
                signPart = []
                isNegative = false
            }
            let signPartCount = signPart.count
            let nextIndex = from + signPartCount
            if buffer.distance(from: nextIndex, to: endIndex) > 2,
               let zero = Options.zero(buffer[nextIndex]), let x = Options.x(buffer[nextIndex + 1]) {
                let index = nextIndex + 2
                if case let integerPart = self.hexIntegerPart(buffer: buffer, from: index), integerPart.isEmpty == false {
                    let leadingCount = 2 + signPartCount + integerPart.count
                    
                    if let decimalPart = try self.hexaDecimalPart(buffer: buffer, from: index + integerPart.count) {
                        let double = PlainNumberParser.double(digits: signPart + [zero, x] + integerPart + decimalPart)
                        
                        return (double, leadingCount + decimalPart.count)
                    } else {
                        if let int = PlainNumberParser.int(digits: signPart + integerPart, radix: 16) {
                            return (int, leadingCount)
                        } else {
                            throw NSKJSONError.error(description: "Number does not fit in Int at \(from).")
                        }
                    }
                } else {
                    throw NSKJSONError.error(description: "Incorrect hex number format at \(index).")
                }
            } else {
                let integerPart = PlainNumberParser.integerPart(buffer: buffer, from: nextIndex)
                if integerPart.isEmpty {
                    let index = from + signPartCount
                    if buffer.distance(from: index, to: endIndex) >= 8 {
                        if buffer[index] == Options.I,
                           buffer[index + 1] == Options.n,
                           buffer[index + 2] == Options.f,
                           buffer[index + 3] == Options.i,
                           buffer[index + 4] == Options.n,
                           buffer[index + 5] == Options.i,
                           buffer[index + 6] == Options.t,
                           buffer[index + 7] == Options.y {
                            
                            let length = signPartCount + 8
                            if isNegative {
                                return (-Double.infinity, length)
                            } else {
                                return (Double.infinity, length)
                            }
                        }
                    } else if buffer.distance(from: index, to: endIndex) >= 3 {
                        if buffer[index] == Options.N,
                           buffer[index + 1] == Options.a,
                           buffer[index + 2] == Options.N {
                            return (Double.nan, 3 + signPartCount)
                        }
                    }
                }
                
                let leadingCount = signPartCount + integerPart.count
                
                if let (decimalPart, isDecimalPartEmpty) = try self.decimalPart(buffer: buffer, from: nextIndex + integerPart.count) {
                    if isDecimalPartEmpty && integerPart.isEmpty {
                        throw NSKJSONError.error(description: "Incorrect number format at \(from).")
                    } else {
                        let double = PlainNumberParser.double(digits: signPart + integerPart + decimalPart)
                        return (double, leadingCount + decimalPart.count)
                    }
                } else {
                    if integerPart.isEmpty {
                        throw NSKJSONError.error(description: "Incorrect number format at \(from).")
                    }
                    if let int = PlainNumberParser.int(digits: signPart + integerPart, radix: 10) {
                        return (int, leadingCount)
                    } else {
                        throw NSKJSONError.error(description: "Number does not fit in Int at \(from).")
                    }
                }
            }
        } else {
            return nil
        }
    }
    
    static func hexaDecimalPart(buffer: Buffer, from: Index) throws -> [UInt8]? {
        if buffer.distance(from: from, to: buffer.endIndex) < 1 {
            return nil
        } else {
            let decimalPart: [UInt8]
            if let dot = Options.dot(buffer[from]) {
                let nextIndex = from + 1
                let digits = self.hexIntegerPart(buffer: buffer, from: nextIndex)
                decimalPart = [dot] + digits
                
            } else {
                decimalPart = self.hexIntegerPart(buffer: buffer, from: from)
            }
            
            if let exponentPart = try PlainNumberParser.exponentPart(buffer: buffer, from: from + decimalPart.count, exponent: Options.p(_:)) {
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
    
    static func decimalPart(buffer: Buffer, from: Index) throws -> ([UInt8], Bool)? {
        if buffer.distance(from: from, to: buffer.endIndex) < 1 {
            return nil
        } else {
            let isDecimalPartEmpty: Bool
            let decimalPart: [UInt8]
            
            if let dot = Options.dot(buffer[from]) {
                let nextIndex = from + 1
                let digits = PlainNumberParser.integerPart(buffer: buffer, from: nextIndex)
                decimalPart = [dot] + digits
                isDecimalPartEmpty = digits.isEmpty
            } else {
                decimalPart = PlainNumberParser.integerPart(buffer: buffer, from: from)
                isDecimalPartEmpty = decimalPart.isEmpty
            }
            
            if let exponentPart = try PlainNumberParser.exponentPart(buffer: buffer, from: from + decimalPart.count, exponent: Options.e(_:)) {
                return (decimalPart + exponentPart, isDecimalPartEmpty)
            } else {
                if decimalPart.isEmpty {
                    return nil
                } else {
                    return (decimalPart, isDecimalPartEmpty)
                }
            }
        }
    }
    static func hexIntegerPart(buffer: Buffer, from: Index) -> [UInt8] {
        if case let endIndex = buffer.endIndex, from < endIndex {
            var result: [UInt8] = []
            for index in from..<endIndex {
                if let hex = Options.hexByte(buffer[index]) {
                    result.append(hex)
                } else {
                    break
                }
            }
            return result
        } else {
            return []
        }
    }
}
