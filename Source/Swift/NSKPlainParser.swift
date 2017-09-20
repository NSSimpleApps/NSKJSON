//
//  NSKPlainParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 14.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

internal class NSKPlainParser<C> where C: Collection, C.Iterator.Element: UnsignedInteger, C.Index == Int {
    
    internal typealias Byte = C.Iterator.Element
    internal typealias Terminator = (_ buffer: C, _ index: Int) -> Bool
    
    internal let options: NSKOptions<Byte>
    
    internal init(options: NSKOptions<Byte>) {
        
        self.options = options
    }
    
    internal final func skip(buffer: C, from: Int, set: Set<Byte>) -> (index: Int, hasValue: Bool, numberOfLines: Int) {
        
        let endIndex = buffer.endIndex
        var numberOfLines = 0
        
        for index in from..<endIndex {
            
            let byte = buffer[index]
            
            if set.contains(byte) == false {
                
                return (index, true, numberOfLines)
                
            } else if byte == self.options.newLine || byte == self.options.carriageReturn {
                
                numberOfLines += 1
            }
        }
        
        return (endIndex - 1, false, numberOfLines)
    }
    
    internal func skipWhiteSpaces(buffer: C, from: Int) throws -> (index: Int, hasValue: Bool, numberOfLines: Int) {
        
        return self.skip(buffer: buffer, from: from, set: self.options.whitespaces)
    }
    
    internal final func parseByteSequence(buffer: C, from: Int, terminator: Byte) throws -> (value: String, offset: Int) {
        
        return try self.parseByteSequence(buffer: buffer, from: from, terminator: { (buffer, index) -> Bool in
            
            return buffer[index] == terminator
        })
    }
    
    internal final func parseByteSequence(buffer: C, from: Int, terminator: Terminator) throws -> (value: String, offset: Int) {
        
        var index = from
        var begin = index
        var result = ""
        
        while index < buffer.endIndex {
            
            let byte = buffer[index]
            
            if self.options.isControlCharacter(byte) {
                
                throw NSKJSONError.error(description: "Unescaped control character around character \(index).")
                
            } else if terminator(buffer, index) {
            
                if let string = self.options.string(bytes: buffer[begin..<index]) {
                    
                    return (result + string, index - from)
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Unable to convert data to string at \(index).")
                }
                
            } else if byte == self.options.backSlash {
                
                if index >= buffer.endIndex - 1 {
                    
                    break
                }
                
                if let prefix = self.options.string(bytes: buffer[begin..<index]) {
                    
                    let escapeSequence = try self.parseEscapeSequence(buffer: buffer, from: index + 1)
                    
                    result += (prefix + escapeSequence.string)
                    index += (escapeSequence.offset + 1)
                    begin = index
                    
                    continue
                    
                } else {
                    
                    throw NSKJSONError.error(description: "Unable to convert data to string at \(index).")
                }
            }
            
            index += 1
        }
        
        throw NSKJSONError.error(description: "Unterminated sequence at \(index).")
    }
    
    /// [0-9a-fA-F]{4}
    internal final func parseCodeUnit(buffer: C, from: Int) throws -> UInt16 {
        
        let length: C.IndexDistance = 4
        
        let matchResult = NSKMatcher<C>.match(buffer: buffer,
                               from: from,
                               length: length,
                               where: { (elem, index) -> Bool in
                                
                                return self.options.isHex(elem)
        })
        
        switch matchResult {
        
        case .lengthMismatch, .outOfRange:
            throw NSKJSONError.error(description: "Expected at least 4 hex digits at \(from).")
            
        case .mismatch(let index):
            throw NSKJSONError.error(description: "Invalid hex digit in unicode escape sequence around character \(index).")
            
        case .match:
            let index = buffer.index(from, offsetBy: length)
            let hexString = self.options.string(bytes: buffer[from..<index])!
            
            return UInt16(strtol(hexString, nil, 16))
        }
    }
    
    // \\u[hex]{4} and hex is a trail code unit
    internal final func parseTrailCodeUnit(buffer: C, from: Int) throws -> UInt16 {
        
        let prefix = NSKMatcher<C>.match(buffer: buffer, from: from, sequence: [self.options.backSlash, self.options.u])
            
        switch prefix {
        
        case .lengthMismatch, .outOfRange:
            throw NSKJSONError.error(description: "Expected at least 6 characters at \(from).")
            
        case .mismatch(let index):
            throw NSKJSONError.error(description: "Expected '\\u' at \(index).")
            
        case .match:
            let codeUnit = try self.parseCodeUnit(buffer: buffer, from: from + 2)
            
            if UTF16.isTrailSurrogate(codeUnit) {
                
                return codeUnit
                
            } else {
                
                throw NSKJSONError.error(description: "Expected low-surrogate code point but did not find one at \(from).")
            }
        }
    }
    
    internal func parseEscapeSequence(buffer: C, from: Int) throws -> (string: String, offset: Int) {
                
        let b0 = buffer[from + 0]
        
        switch b0 {
            
        case self.options.quotationMark: return ("\"", 1)
        case self.options.apostrophe: return ("\'", 1)
        case self.options.backSlash : return ("\\", 1)
        case self.options.slash: return ("/", 1)
        case self.options.b: return ("\u{08}", 1)
        case self.options.f: return ("\u{0C}", 1)
        case self.options.n: return ("\u{0A}", 1)
        case self.options.r: return ("\u{0D}", 1)
        case self.options.t: return ("\u{09}", 1)
        case self.options.u:
            
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
    
    internal func parseNumber(buffer: C, from: Int) throws -> (value: Any, offset: Int) {
            
        let whiteSpaces = self.options.whitespaces
        let endArray = self.options.endArray
        let endDictionary = self.options.endDictionary
        let comma = self.options.comma
        
        let plainJSONTerminator =
        NSKPlainJSONTerminator(whiteSpaces: whiteSpaces,
                               endArray: endArray,
                               endDictionary: endDictionary,
                               comma: comma)
        
        let numberParser = NSKPlainNumberParser<C>(options: self.options)
        
        let (value, offset) = try numberParser.parseNumber(buffer: buffer, from: from, terminator: { (buffer, index) -> Bool in
                
                return plainJSONTerminator.contains(buffer: buffer, at: index)
        })
        
        return (value, offset)
    }
    
    internal final func parseArray(buffer: C, from: Int, nestingLevel: Int) throws -> (value: [Any], offset: Int) {
        
        guard buffer.endIndex - from >= 2 && buffer[from] == self.options.beginArray else {
            
            throw NSKJSONError.error(description: "Unable to parse array at \(from).")
        }
        
        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        let terminator = self.options.endArray
        
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
    
    internal final func parseDictionary(buffer: C, from: Int, nestingLevel: Int) throws -> (value: [String: Any], offset: Int) {
        
        guard buffer.endIndex - from >= 2 && buffer[from] == self.options.beginDictionary else {
            
            throw NSKJSONError.error(description: "Cannot parse dictionary at \(from).")
        }
        
        let terminator = self.options.endDictionary
        
        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        
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
    
    internal func parseValue(buffer: C, from: Int, nestingLevel: Int) throws -> (value: Any, offset: Int) {
        
        if nestingLevel > NSKNestingLevel {
            
            throw NSKJSONError.error(description: "Too many nested arrays or dictionaries at \(from).")
        }
        
        let byte = buffer[from]
        
        switch byte {
            
        case self.options.beginDictionary:
            let dictionary = try self.parseDictionary(buffer: buffer, from: from, nestingLevel: nestingLevel + 1)
            
            return (dictionary.value, dictionary.offset)
            
        case self.options.beginArray:
            let array = try self.parseArray(buffer: buffer, from: from, nestingLevel: nestingLevel + 1)
            
            return (array.value, array.offset)
            
        case self.options.t:
            let trueMatch = NSKMatcher<C>.match(buffer: buffer, from: from + 1, sequence: [self.options.r, self.options.u, self.options.e])
            
            switch trueMatch {
                
            case .match:
                return (true, 4)
                
            default:
                throw NSKJSONError.error(description: "Unable to parse 'true' at \(from).")
            }
        case self.options.f:
            let falseMatch = NSKMatcher<C>.match(buffer: buffer, from: from + 1, sequence: [self.options.a, self.options.l, self.options.s, self.options.e])
            
            switch falseMatch {
                
            case .match:
                return (false, 5)
                
            default:
                throw NSKJSONError.error(description: "Unable to parse 'false' at \(from).")
            }
        case self.options.n:
            let nullMatch = NSKMatcher<C>.match(buffer: buffer, from: from + 1, sequence: [self.options.u, self.options.l, self.options.l])
            
            switch nullMatch {
                
            case .match:
                return (NSNull(), 4)
                
            default:
                throw NSKJSONError.error(description: "Unable to parse 'null' at \(from).")
            }
        
        case let b where self.isNumberPrefix(byte: b):
            return try self.parseNumber(buffer: buffer, from: from)
        
        case self.options.quotationMark where from < buffer.endIndex - 1:
            
            let string = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: byte)
            
            return (string.value, string.offset + 2)
            
        default:
            throw NSKJSONError.error(description: "Unable to parse JSON object at \(from).")
        }
    }
    
    internal func isNumberPrefix(byte: Byte) -> Bool {
        
        return NSKPlainNumberParser<C>.isValidPrefix(byte, options: self.options)
    }
    
    internal final func parseObject(buffer: C) throws -> Any {
        
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
    
    internal func parseValueSpace(buffer: C, from: Int, terminator: Byte) throws -> (offset: Int, hasTerminator: Bool) {
        
        return try self.parseValueSpace(buffer: buffer, from: from, terminator: terminator, trailingComma: false)
    }
    
    internal final func parseValueSpace(buffer: C, from: Int, terminator: Byte, trailingComma: Bool) throws -> (offset: Int, hasTerminator: Bool) {
        
        let endIndex = buffer.endIndex
        let (leadingIndex, _, _) = try self.skipWhiteSpaces(buffer: buffer, from: from)
        let byte = buffer[leadingIndex]
        
        if byte == terminator {
            
            return (leadingIndex - from, true)
            
        } else if byte == self.options.comma {
            
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
                
                } else if byte == self.options.comma {
                    
                    throw NSKJSONError.error(description: "Expected value but ',' found at \(trailingIndex) during parsing value space.")
                    
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
    
    internal func parseDictionaryKey(buffer: C, from: Int) throws -> (value: String, offset: Int) {
        
        let quotationMark = self.options.quotationMark
        
        guard buffer.endIndex - from >= 2 && buffer[from] == quotationMark else {
            
            throw NSKJSONError.error(description: "Invalid dictionary format at \(from).")
        }
        
        let result = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: quotationMark)
        
        return (result.value, result.offset + 2)
    }
    
    internal final func parseDictionarySpace(buffer: C, from: Int) throws -> (offset: Int, hasNext: Bool) {
        
        let endIndex = buffer.endIndex - 1
        
        let (index, hasValue, _) = try self.skipWhiteSpaces(buffer: buffer, from: from)
        
        if hasValue {
            
            let byte = buffer[index]
            
            if byte == self.options.colon {
                
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
