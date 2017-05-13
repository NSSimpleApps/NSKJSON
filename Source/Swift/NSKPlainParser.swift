//
//  NSKPlainParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 14.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

internal class NSKPlainParser {
    
    internal let options: NSKOptions
    
    internal init(options: NSKOptions) {
        
        self.options = options
    }
    
    internal final func skip(buffer: UnsafeBufferPointer<UInt8>, set: Set<UInt8>, from: Int) -> (index: Int, hasValue: Bool, numberOfLines: Int) {
        
        let endIndex = buffer.endIndex
        var numberOfLines = 0
        
        for index in from..<endIndex {
            
            let byte = buffer[index]
            
            if set.contains(byte) == false {
                
                return (index, true, numberOfLines)
                
            } else if byte == NSKNewLine || byte == NSKCarriageReturn {
                
                numberOfLines += 1
            }
        }
        
        return (endIndex - 1, false, numberOfLines)
    }
    
    internal func skipWhiteSpaces(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (index: Int, hasValue: Bool, numberOfLines: Int) {
        
        return self.skip(buffer: buffer, set: NSKWhitespaces, from: from)
    }
    
    internal final func parseByteSequence(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (value: String, offset: Int) {
        
        let encoding = self.options.encoding
        var index = from
        var begin = index
        var result = ""
        
        while index < buffer.endIndex {
            
            let byte = buffer[index]
            
            if byte.isControlCharacter {
                
                throw NSKJSONError.error(description: "Unescaped control character around character \(index).")
                
            } else if terminator.contains(buffer: buffer, at: index) {
                
                if let string = String(bytes: buffer[begin..<index], encoding: encoding) {
                    
                    return (result + string, index - from)
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Unable to convert data to string at \(index).")
                }
                
            } else if byte == NSKBackSlash {
                
                if let prefix = String(bytes: buffer[begin..<index], encoding: encoding) {
                    
                    result += prefix
                    
                    let escapeSequence = try self.parseSlashSequence(buffer: buffer, from: index)
                    
                    result += escapeSequence.string
                    index += escapeSequence.offset
                    begin = index
                    
                    continue
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Unable to convert data to string at \(index).")
                }
            }
            
            index += 1
        }
        
        throw NSKJSONError.error(description: "Expected terminator at \(index).")
    }
    
    internal final func parseString(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: NSKTerminator.Type) throws -> (value: String, offset: Int) {
        
        guard buffer.endIndex - from >= 2 && terminator.contains(buffer: buffer, at: from) else {
            
            throw NSKJSONError.error(description: "Invalid string format at \(from).")
        }
        
        let result = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: terminator)
        
        return (result.value, result.offset + 2)
    }
    
    /// [0-9a-fA-F]{4}
    internal final func parseCodeUnit(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> UInt16 {
        
        let length = buffer.endIndex - from
        
        guard length >= 4 else {
            
            throw NSKJSONError.error(description: "Expected at least 4 hex digits instead of \(length) at \(from).")
        }
        
        let b3 = buffer[from + 0]
        let b2 = buffer[from + 1]
        let b1 = buffer[from + 2]
        let b0 = buffer[from + 3]
        
        if b0.isHex && b1.isHex && b2.isHex && b3.isHex {
            
            let hexString = String(bytes: [b3, b2, b1, b0], encoding: .utf8)!
            
            return UInt16(strtol(hexString, nil, 16))
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid hex digit in unicode escape sequence around character \(from).")
        }
    }
    
    // \\u[hex]{4} and hex is a trail code unit
    internal final func parseTrailCodeUnit(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> UInt16 {
        
        let length = buffer.endIndex - from
        
        guard length >= 6 else {
            
            throw NSKJSONError.error(description: "Expected at least 6 characters but have \(length) at \(from).")
        }
        
        guard buffer[from] == NSKBackSlash && buffer[from + 1] == NSKu else {
            
            throw NSKJSONError.error(description: "Expected '\\' or 'u' at \(from).")
        }
        
        let codeUnit = try self.parseCodeUnit(buffer: buffer, from: from + 2)
        
        if UTF16.isTrailSurrogate(codeUnit) {
            
            return codeUnit
            
        } else {
            
            throw NSKJSONError.error(description: "Expected low-surrogate code point but did not find one at \(from).")
        }
    }
    
    internal final func parseSlashSequence(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (string: String, offset: Int) {
        
        let length = buffer.endIndex - from
        
        guard length >= 2 && buffer[from] == NSKBackSlash else {
            
            throw NSKJSONError.error(description: "Expected '\\' at \(from).")
        }
        
        let (string, offset) = try self.parseEscapeSequence(buffer: buffer, from: from + 1)
        
        return (string, offset + 1)
    }
    
    internal func parseEscapeSequence(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (string: String, offset: Int) {
                
        let b0 = buffer[from + 0]
        
        switch b0 {
            
        case NSKQuotationMark: return ("\"", 1)
        case NSKSingleQuotationMark: return ("\'", 1)
        case NSKBackSlash : return ("\\", 1)
        case NSKSlash: return ("/", 1)
        case NSKb: return ("\u{08}", 1)
        case NSKf: return ("\u{0C}", 1)
        case NSKn: return ("\u{0A}", 1)
        case NSKr: return ("\u{0D}", 1)
        case NSKt: return ("\u{09}", 1)
        case NSKu:
            
            let codeUnit = try self.parseCodeUnit(buffer: buffer, from: from + 1)
            
            if let scalar = UnicodeScalar(codeUnit) {
                
                return (String(scalar), 5)
                
            } else if UTF16.isTrailSurrogate(codeUnit) {
                
                throw NSKJSONError.error(description: "Unable to convert hex escape sequence (no high character) to UTF8-encoded character at \(from + 1).")
                
            } else {
                
                let trailCodeUnit = try self.parseTrailCodeUnit(buffer: buffer, from: from + 5)
                
                let highValue = (UInt32(codeUnit  - 0xD800) << 10)
                let lowValue  =  UInt32(trailCodeUnit - 0xDC00)
                
                return (String(UnicodeScalar(highValue + lowValue + 0x10000)!), 11)
            }
            
        default:
            throw NSKJSONError.error(description: "Invalid escape character at \(from).")
        }
    }
    
    internal func parseNumber(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (value: Any, offset: Int) {
        
        let (value, offset) = try NSKPlainNumberParser.parseNumber(buffer: buffer, from: from, terminator: NSKPlainJSONTerminator.self)
        
        return (value, offset)
    }
    
    internal final func parsePrimitive(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (value: Any, offset: Int) {
        
        let b0 = buffer[from]
        let length = buffer.endIndex - from
        
        if b0 == NSKt && length >= 4 { // maybe true
            
            let b1 = buffer[from + 1]
            let b2 = buffer[from + 2]
            let b3 = buffer[from + 3]
            
            if b1 == NSKr && b2 == NSKu && b3 == NSKe {
                
                return (true, 4)
            }
            
        } else if b0 == NSKf && length >= 5 { // maybe false
            
            let b1 = buffer[from + 1]
            let b2 = buffer[from + 2]
            let b3 = buffer[from + 3]
            let b4 = buffer[from + 4]
            
            if b1 == NSKa && b2 == NSKl && b3 == NSKs && b4 == NSKe {
                
                return (false, 5)
            }
            
        } else if b0 == NSKn && length >= 4 { // maybe null
            
            let b1 = buffer[from + 1]
            let b2 = buffer[from + 2]
            let b3 = buffer[from + 3]
            
            if b1 == NSKu && b2 == NSKl && b3 == NSKl {
                
                return (NSNull(), 4)
            }
        }
        
        throw NSKJSONError.error(description: "Unable to parse primitive value at \(from).")
    }
    
    internal final func parseArray(buffer: UnsafeBufferPointer<UInt8>, from: Int, nestingLevel: Int) throws -> (value: [Any], offset: Int) {
        
        guard buffer.endIndex - from >= 2 && buffer[from] == NSKBeginArray else {
            
            throw NSKJSONError.error(description: "Unable to parse array at \(from).")
        }
        
        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        let terminator = NSKEndArray
        
        if hasValue == false {
            
            throw NSKJSONError.error(description: "Unexpected EOF while parsing array at \(index).")
            
        } else if buffer[index] == terminator {
            
            return ([], index + 1 - from)
            
        } else {
            
            var array: [Any] = []
            var index = index
            
            while true {
                
                let value = try self.parseValue(buffer: buffer, from: index, nestingLevel: nestingLevel)
                
                array.append(value.value)
                index += value.offset
                
                let (offset, hasTerminator) = try self.parseValueSpace(buffer: buffer, from: index, terminator: terminator)
                
                if hasTerminator {
                    
                    return (array, index + offset + 1 - from)
                    
                } else {
                    
                    index += offset
                }
            }
        }
    }
    
    internal final func parseDictionary(buffer: UnsafeBufferPointer<UInt8>, from: Int, nestingLevel: Int) throws -> (value: [String: Any], offset: Int) {
        
        guard buffer.endIndex - from >= 2 && buffer[from] == NSKBeginDictionary else {
            
            throw NSKJSONError.error(description: "Cannot parse dictionary at \(from).")
        }

        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        let terminator = NSKEndDictionary
        
        if hasValue == false {
            
            throw NSKJSONError.error(description: "Unexpected EOF during parsing dictionary at \(index).")
            
        } else if buffer[index] == terminator {
            
            return ([:], index + 1 - from)
            
        } else {
            
            var dictionary: [String: Any] = [:]
            var index = index
            
            while true {
                
                let (dictionaryKey, keyOffset) = try self.parseDictionaryKey(buffer: buffer, from: index)
                let (spaceOffset, hasNextValue)  = try self.parseDictionarySpace(buffer: buffer, from: index + keyOffset)
                
                if hasNextValue {
                    
                    let trailingOffset = keyOffset + spaceOffset
                    
                    let (value, valueOffset) = try self.parseValue(buffer: buffer, from: index + trailingOffset, nestingLevel: nestingLevel)
                    let (newOffset, hasTerminator) = try self.parseValueSpace(buffer: buffer, from: index + trailingOffset + valueOffset, terminator: terminator)
                    
                    dictionary[dictionaryKey] = value
                    
                    if hasTerminator {
                        
                        return (dictionary, index + trailingOffset + valueOffset + newOffset + 1 - from)
                        
                    } else {
                        
                        index += trailingOffset + valueOffset + newOffset
                    }
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Expected dictionary value at \(index + keyOffset + spaceOffset).")
                }
            }
        }
    }
    
    internal func stringTerminator(byte: UInt8) -> NSKTerminator.Type? {
        
        if byte == NSKQuotationMark {
            
            return NSKQuotationTerminator.self
            
        } else {
            
            return nil
        }
    }
    
    internal func isNumberPrefix(_ prefix: UInt8) -> Bool {
        
        return NSKPlainNumberParser.isNumberPrefix(prefix)
    }
    
    internal final func parseValue(buffer: UnsafeBufferPointer<UInt8>, from: Int, nestingLevel: Int) throws -> (value: Any, offset: Int) {
        
        if nestingLevel > NSKNestingLevel {
            
            throw NSKJSONError.error(description: "Too many nested arrays or dictionaries around character \(from).")
        }
        
        let byte = buffer[from]
        
        switch byte {
            
        case NSKBeginDictionary:
            
            let dictionary = try self.parseDictionary(buffer: buffer, from: from, nestingLevel: nestingLevel + 1)
            
            return (dictionary.value, dictionary.offset)
            
        case NSKBeginArray:
            
            let array = try self.parseArray(buffer: buffer, from: from, nestingLevel: nestingLevel + 1)
            
            return (array.value, array.offset)
            
        case NSKt, NSKf, NSKn:
            
            return try self.parsePrimitive(buffer: buffer, from: from)
        
        case let b where self.isNumberPrefix(b):
            
            return try self.parseNumber(buffer: buffer, from: from)
            
        default:
            
            if let terminator = self.stringTerminator(byte: byte) {
                
                let string = try self.parseString(buffer: buffer, from: from, terminator: terminator)
                
                return (string.value, string.offset)
                
            } else {
                
                throw NSKJSONError.error(description: "Unable to parse JSON object at \(from).")
            }
        }
    }
    
    internal final func parseObject(buffer: UnsafeBufferPointer<UInt8>) throws -> Any {
        
        if buffer.isEmpty {
            
            throw NSKJSONError.error(description: "Empty input.")
        }
        
        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: buffer.startIndex)
        
        if hasValue {
            
            let (value, offset) = try self.parseValue(buffer: buffer, from: index, nestingLevel: 0)
            
            if index + offset < buffer.endIndex {
                
                let (_, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: index + offset)
                
                if hasValue {
                    
                    throw NSKJSONError.error(description: "Garbage at end.")
                }
            }
                
            return value
            
        } else {
            
            throw NSKJSONError.error(description: "No json value found.")
        }
    }
    
    internal func parseValueSpace(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: UInt8) throws -> (offset: Int, hasTerminator: Bool) {
        
        return try self.parseValueSpace(buffer: buffer, from: from, terminator: terminator, trailingComma: false)
    }
    
    internal final func parseValueSpace(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: UInt8, trailingComma: Bool) throws -> (offset: Int, hasTerminator: Bool) {
        
        let endIndex = buffer.endIndex
        let (leadingIndex, _, _) = try self.skipWhiteSpaces(buffer: buffer, from: from)
        
        let byte = buffer[leadingIndex]
        
        if byte == terminator {
            
            return (leadingIndex - from, true)
            
        } else if byte == NSKComma {
            
            if leadingIndex == endIndex - 1 {
                
                throw NSKJSONError.error(description: "Expected value or closing bracket after \(leadingIndex).")
                
            } else {
                
                let (trailingIndex, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: leadingIndex + 1)
                
                let byte = buffer[trailingIndex]
                
                if byte == terminator {
                    
                    if trailingComma {
                        
                        return (trailingIndex - from, true)
                        
                    } else {
                        
                        throw NSKJSONError.error(description: "0 or 1 commas allowed at \(trailingIndex).")
                    }
                    
                } else if hasValue == true {
                    
                    return (trailingIndex - from, false)
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Unexpected EOF at \(trailingIndex) during parsing value space.")
                }
            }
            
        } else {
            
            throw NSKJSONError.error(description: "Expected ',' or closing bracket at \(leadingIndex).")
        }
    }
    
    internal func parseDictionaryKey(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (value: String, offset: Int) {
        
        return try self.parseString(buffer: buffer, from: from, terminator: NSKQuotationTerminator.self)
    }
    
    internal final func parseDictionarySpace(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (offset: Int, hasNext: Bool) {
        
        let endIndex = buffer.endIndex - 1
        
        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: from)
        
        if hasValue {
            
            let byte = buffer[index]
            
            if byte == NSKColon {
                
                if index < endIndex - 1 {
                    
                    let (index, hasNextValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: index + 1)
                    
                    return (index - from, hasNextValue)
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Expected value (may be with terminator) at \(index).")
                }
                
            } else {
                
                throw NSKJSONError.error(description: "Expected ':' at \(index).")
            }
            
        } else {
            
            throw NSKJSONError.error(description: "Unexpected EOF during parsing dictionary space at \(index).")
        }
    }
}
