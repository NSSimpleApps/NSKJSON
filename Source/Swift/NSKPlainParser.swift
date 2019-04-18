//
//  NSKPlainParser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 14.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation


struct NSKPlainParser<Options: NSKOptions> {
    typealias Byte = Options.Byte
    typealias Buffer = Options.Buffer
    typealias Index = Options.Index
    
    private init() {}
    
    static func skipWhiteSpaces(buffer: Buffer, from: Index) -> Index {
        let endIndex = buffer.endIndex
        for index in from..<endIndex {
            if Options.isPlainWhitespace(buffer[index]) == false {
                return index
            }
        }
        return endIndex - 1
    }
    
    static func parseByteSequence(buffer: Buffer, from: Index, terminator: Byte) throws -> (value: String, length: Int) {
        let endIndex = buffer.endIndex
        var index = from
        var begin = index
        var result = ""
        
        while index < endIndex {
            let byte = buffer[index]
            
            if Options.isControlCharacter(byte) {
                throw NSKJSONError.error(description: "Unescaped control character around character \(index).")
                
            } else if byte == terminator {
                let string = try Options.string(buffer: buffer, from: begin, to: index)
                return (result + string, index - from)
                
            } else if byte == Options.backSlash {
                if index < endIndex - 1 {
                    let prefix = try Options.string(buffer: buffer, from: begin, to: index)
                    let escapeSequence = try self.parseEscapeSequence(buffer: buffer, from: index + 1)
                    
                    result += (prefix + escapeSequence.string)
                    index += (escapeSequence.length + 1)
                    begin = index
                    continue
                } else {
                    break
                }
            }
            index += 1
        }
        throw NSKJSONError.error(description: "Unterminated sequence at \(endIndex).")
    }
    
    /// [0-9a-fA-F]{4}
    static func parseCodeUnit(buffer: Buffer, from: Index) throws -> UInt16 {
        if buffer.distance(from: from, to: buffer.endIndex) >= 4 {
            if let b3 = Options.hexByte(buffer[from]),
                let b2 = Options.hexByte(buffer[from + 1]),
                let b1 = Options.hexByte(buffer[from + 2]),
                let b0 = Options.hexByte(buffer[from + 3]) {
                
                return (UInt16(b3 << 4 + b2) << 4 + UInt16(b1)) << 4 + UInt16(b0)
            } else {
                throw NSKJSONError.error(description: "Invalid hex sequence from \(from).")
            }
        } else {
            throw NSKJSONError.error(description: "Expected at least 4 hex digits at \(from).")
        }
    }
    
    // \\u[hex]{4} and hex is a trail code unit
    static func parseTrailCodeUnit(buffer: Buffer, from: Index) throws -> UInt16 {
        if buffer.distance(from: from, to: buffer.endIndex) >= 6 {
            if buffer[from] == Options.backSlash && buffer[from + 1] == Options.u {
                let codeUnit = try self.parseCodeUnit(buffer: buffer, from: from + 2)
                
                if UTF16.isTrailSurrogate(codeUnit) {
                    return codeUnit
                    
                } else {
                    throw NSKJSONError.error(description: "Expected low-surrogate code point but did not find one at \(from).")
                }
            } else {
                throw NSKJSONError.error(description: "Expected '\\u' at \(from).")
            }
        } else {
            throw NSKJSONError.error(description: "Expected at least 6 characters from \(from).")
        }
    }
    
    static func parseEscapeSequence(buffer: Buffer, from: Index) throws -> (string: String, length: Int) {
        switch buffer[from] {
        case Options.n: return ("\n", 1)
        case Options.t: return ("\t", 1)
        case Options.quotationMark: return ("\"", 1)
        case Options.apostrophe: return ("\'", 1)
        case Options.backSlash : return ("\\", 1)
        case Options.slash: return ("/", 1)
        case Options.b: return ("\u{08}", 1)
        case Options.f: return ("\u{0C}", 1)
        case Options.r: return ("\r", 1)
        
        case Options.u:
            let codeUnit = try self.parseCodeUnit(buffer: buffer, from: from + 1)
            
            if let scalar = UnicodeScalar(codeUnit) {
                return (String(scalar), 5)
                
            } else if UTF16.isTrailSurrogate(codeUnit) {
                throw NSKJSONError.error(description: "Unable to convert hex escape sequence (no high character) to UTF8-encoded character at \(from + 1).")
                
            } else {
                let trailCodeUnit = try self.parseTrailCodeUnit(buffer: buffer, from: from + 5)
                
                let highValue = UInt32(codeUnit  - 0xD800) << 10
                let lowValue  =  UInt32(trailCodeUnit - 0xDC00)
                
                return (String(UnicodeScalar(highValue + lowValue + 0x10000)!), 11)
            }
        default:
            throw NSKJSONError.error(description: "Invalid escape character at \(from).")
        }
    }
    
    static func parseArray(buffer: Buffer, from: Index, nestingLevel: Int) throws -> (value: [Any], index: Index)? {
        guard buffer.distance(from: from, to: buffer.endIndex) >= 2 && buffer[from] == Options.beginArray else {
            return nil
        }
        
        let index = self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        let terminator = Options.endArray
        
        if buffer[index] == terminator {
            return ([], index + 1)
            
        } else {
            var array: [Any] = []
            var index = index
            
            while true {
                let (value, valueIndex) = try self.parseValue(buffer: buffer, from: index, nestingLevel: nestingLevel)
                array.append(value)
                
                let (spaceIndex, hasTerminator) = try self.parseValueSpace(buffer: buffer, from: valueIndex, terminator: terminator)
                
                if hasTerminator {
                    return (array, spaceIndex + 1)
                    
                } else {
                    index = spaceIndex
                }
            }
        }
    }
    
    static func parseDictionary(buffer: Buffer, from: Index, nestingLevel: Int) throws -> (value: [String: Any], index: Index)? {
        guard buffer.distance(from: from, to: buffer.endIndex) >= 2 && buffer[from] == Options.beginDictionary else {
            return nil
        }
        
        let terminator = Options.endDictionary
        let index = self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        
        if buffer[index] == terminator {
            return ([:], index + 1)
            
        } else {
            var dictionary: [String: Any] = [:]
            var index = index
            
            while true {
                let (dictionaryKey, keyIndex) = try self.parseDictionaryKey(buffer: buffer, from: index)
                let dictionarySpaceIndex  = try self.parseDictionarySpace(buffer: buffer, from: keyIndex)
                
                let (value, valueIndex) = try self.parseValue(buffer: buffer, from: dictionarySpaceIndex, nestingLevel: nestingLevel)
                let (trailingIndex, hasTerminator) = try self.parseValueSpace(buffer: buffer, from: valueIndex, terminator: terminator)
                
                dictionary[dictionaryKey] = value
                
                if hasTerminator {
                    return (dictionary, trailingIndex + 1)
                    
                } else {
                    index = trailingIndex
                }
            }
        }
    }
    
    static func parsePrimitive(buffer: Buffer, from: Index) throws -> (value: Any, length: Int)? {
        if buffer.distance(from: from, to: buffer.endIndex) >= 4 {
            switch buffer[from] {
            case Options.n:
                if buffer[from + 1] == Options.u && buffer[from + 2] == Options.l && buffer[from + 3] == Options.l {
                    return (NSNull(), 4)
                } else {
                    throw NSKJSONError.error(description: "Unable to parse null at \(from).")
                }
            case Options.t:
                if buffer[from + 1] == Options.r && buffer[from + 2] == Options.u && buffer[from + 3] == Options.e {
                    return (true, 4)
                } else {
                    throw NSKJSONError.error(description: "Unable to parse true at \(from).")
                }
            case Options.f:
                if buffer.distance(from: from + 4, to: buffer.endIndex) >= 1, buffer[from + 1] == Options.a && buffer[from + 2] == Options.l && buffer[from + 3] == Options.s && buffer[from + 4] == Options.e {
                    return (false, 5)
                } else {
                    throw NSKJSONError.error(description: "Unable to parse false at \(from).")
                }
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func parseString(buffer: Buffer, from: Index) throws -> (string: String, index: Index)? {
        let quotationMark = Options.quotationMark
        if buffer.distance(from: from, to: buffer.endIndex) >= 2, buffer[from] == quotationMark {
            let (value, length) = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: quotationMark)
            return (value, from + length + 2)
        } else {
            return nil
        }
    }
    
    static func parseValue(buffer: Buffer, from: Index, nestingLevel: Int) throws -> (value: Any, index: Index) {
        if nestingLevel > NSKJSON.nestingLevel {
            throw NSKJSONError.error(description: "Too many nested arrays or dictionaries at \(from).")
        }
        if let (dictionary, dictionaryIndex) = try self.parseDictionary(buffer: buffer, from: from, nestingLevel: nestingLevel + 1) {
            return (dictionary, dictionaryIndex)
        } else if let (array, arrayIndex) = try self.parseArray(buffer: buffer, from: from, nestingLevel: nestingLevel + 1) {
            return (array, arrayIndex)
        } else if let (string, stringIndex) = try self.parseString(buffer: buffer, from: from) {
            return (string, stringIndex)
        } else if let (primitive, length) = try self.parsePrimitive(buffer: buffer, from: from) {
            return (primitive, from + length)
        } else if let (number, length) = try NSKPlainNumberParser<Options>.parseNumber(buffer: buffer, from: from) {
            return (number, from + length)
        } else {
            throw NSKJSONError.error(description: "Unable to parse JSON object at \(from).")
        }
    }
    
    static func parseObject(buffer: Buffer) throws -> Any {
        if buffer.isEmpty {
            throw NSKJSONError.error(description: "Empty input.")
        }
        
        if case let index = self.skipWhiteSpaces(buffer: buffer, from: buffer.startIndex), Options.isPlainWhitespace(buffer[index]) == false {
            let (value, nextIndex) = try self.parseValue(buffer: buffer, from: index, nestingLevel: 0)
            let lastIndex = self.skipWhiteSpaces(buffer: buffer, from: nextIndex)
            
            if lastIndex >= nextIndex, Options.isPlainWhitespace(buffer[lastIndex]) == false {
                throw NSKJSONError.error(description: "Garbage at end.")
            } else {
                return value
            }
        } else {
            throw NSKJSONError.error(description: "No json value found.")
        }
    }
    
    static func parseValueSpace(buffer: Buffer, from: Index, terminator: Byte) throws -> (index: Index, hasTerminator: Bool) {
        let leadingIndex = self.skipWhiteSpaces(buffer: buffer, from: from)
        let byte = buffer[leadingIndex]
        
        if byte == terminator {
            return (leadingIndex, true)
            
        } else if byte == Options.comma {
            if case let nextIndex = leadingIndex + 1, nextIndex < buffer.endIndex {
                let trailingIndex = self.skipWhiteSpaces(buffer: buffer, from: nextIndex)
                let byte = buffer[trailingIndex]
                
                if byte == terminator {
                    throw NSKJSONError.error(description: "No trailing comma allowed at \(leadingIndex).")
                    
                } else if byte == Options.comma {
                    throw NSKJSONError.error(description: "Expected value but ',' found at \(trailingIndex).")
                    
                } else {
                    return (trailingIndex, false)
                }
            } else {
                throw NSKJSONError.error(description: "Expected value or closing bracket after \(leadingIndex).")
            }
        } else {
            throw NSKJSONError.error(description: "Expected ',' or closing bracket at \(leadingIndex).")
        }
    }
    
    static func parseDictionaryKey(buffer: Buffer, from: Index) throws -> (value: String, index: Index) {
        let quotationMark = Options.quotationMark

        guard buffer.distance(from: from, to: buffer.endIndex) >= 2 && buffer[from] == quotationMark else {
            throw NSKJSONError.error(description: "Invalid dictionary key at \(from).")
        }
        let (value, length) = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: quotationMark)

        return (value, from + length + 2)
    }
    
    static func parseDictionarySpace(buffer: Buffer, from: Index) throws -> Index {
        let leadingIndex = self.skipWhiteSpaces(buffer: buffer, from: from)
        
        if buffer[leadingIndex] == Options.colon {
            if case let nextIndex = leadingIndex + 1, nextIndex < buffer.endIndex {
                let trailingIndex = self.skipWhiteSpaces(buffer: buffer, from: nextIndex)
                
                return trailingIndex
            } else {
                throw NSKJSONError.error(description: "Expected value at \(leadingIndex).")
            }
        } else {
            throw NSKJSONError.error(description: "Expected ':' at \(leadingIndex).")
        }
    }
}
