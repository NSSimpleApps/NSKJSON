//
//  NSKJSON5Parser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 01.05.17.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//


import Foundation

struct NSKJSON5Parser<Options: NSKOptions> {
    typealias Byte = Options.Byte
    typealias Buffer = Options.Buffer
    typealias Index = Options.Index
    typealias PlainParser = NSKPlainParser<Options>

    private init() {}
    
    private static func skipSpaces(buffer: Buffer, from: Index) -> Index {
        let endIndex = buffer.endIndex

        for index in from..<endIndex {
            if Options.isJson5Whitespace(buffer[index]) == false {
                return index
            }
        }
        return endIndex - 1
    }
    private static func skipSpacesWithLines(buffer: Buffer, from: Index) -> (index: Index, numberOfLines: Int) {
        let endIndex = buffer.endIndex
        var numberOfLines = 0
        
        for index in from..<endIndex {
            let byte = buffer[index]
            
            if Options.isJson5Whitespace(byte) == false {
                return (index, numberOfLines)
                
            } else if self.isNewLine(byte) {
                numberOfLines += 1
            }
        }
        return (endIndex - 1, numberOfLines)
    }
    
    @inline(__always)
    private static func isNewLine(_ character: Byte) -> Bool {
        return character == Options.newLine || character == Options.carriageReturn
    }
    
    static func skipSingleLineComment(buffer: Buffer, from: Index) -> Index? {
        let endIndex = buffer.endIndex
        if buffer.distance(from: from, to: endIndex) >= 2, buffer[from] == Options.slash && buffer[from + 1] == Options.slash {
            if case let index = from + 2, index < endIndex {
                for i in index..<endIndex {
                    if case let byte = buffer[i], self.isNewLine(byte) {
                        if case let nextIndex = i + 1, nextIndex < endIndex {
                            return nextIndex
                        } else {
                            return i
                        }
                    }
                }
                return endIndex - 1
            } else {
                return endIndex - 1
            }
        } else {
            return nil
        }
    }
    static func skipSingleLineCommentWithLines(buffer: Buffer, from: Index) -> (index: Index, numberOfLines: Int)? {
        let endIndex = buffer.endIndex
        if buffer.distance(from: from, to: endIndex) >= 2, buffer[from] == Options.slash && buffer[from + 1] == Options.slash {
            if case let index = from + 2, index < endIndex {
                for i in index..<endIndex {
                    if case let byte = buffer[i], self.isNewLine(byte) {
                        if case let nextIndex = i + 1, nextIndex < endIndex {
                            return (nextIndex, 1)
                        } else {
                            return (i, 1)
                        }
                    }
                }
                return (endIndex - 1, 0)
            } else {
                return (endIndex - 1, 0)
            }
        } else {
            return nil
        }
    }
    
    static func skipMultiLineComment(buffer: Buffer, from: Index) throws -> Index? {
        let endIndex = buffer.endIndex
        if buffer.distance(from: from, to: endIndex) >= 2, buffer[from] == Options.slash && buffer[from + 1] == Options.star {
            if case let initialIndex = from + 2, buffer.distance(from: initialIndex, to: endIndex) >= 2 {
                var nestingLevel = 1
                var numberOfLines = 0
                var i = initialIndex
                
                while i < endIndex {
                    let byte = buffer[i]
                    
                    if self.isNewLine(byte) {
                        numberOfLines += 1
                        
                    } else if byte == Options.star {
                        if case let nextIndex = i + 1, nextIndex < endIndex {
                            if buffer[nextIndex] == Options.slash {
                                nestingLevel -= 1
                                
                                if nestingLevel == 0 {
                                    if case let nextNextIndex = nextIndex + 1, nextNextIndex < endIndex {
                                        return nextNextIndex
                                    } else {
                                        return nextIndex
                                    }
                                } else {
                                    i += 2
                                    continue
                                }
                            }
                        }
                    } else if byte == Options.slash {
                        if case let nextIndex = i + 1, nextIndex < endIndex {
                            if buffer[nextIndex] == Options.star {
                                nestingLevel += 1
                                i += 2
                                continue
                            }
                        }
                    }
                    i += 1
                }
                throw NSKJSONError.error(description: "Unterminated multiline comment at \(endIndex - 1).")
            } else {
                throw NSKJSONError.error(description: "Unterminated multiline comment at \(from).")
            }
        } else {
            return nil
        }
    }
    static func skipMultiLineCommentWithLines(buffer: Buffer, from: Index) throws -> (index: Index, numberOfLines: Int)? {
        let endIndex = buffer.endIndex
        if buffer.distance(from: from, to: endIndex) >= 2, buffer[from] == Options.slash && buffer[from + 1] == Options.star {
            if case let initialIndex = from + 2, buffer.distance(from: initialIndex, to: endIndex) >= 2 {
                var nestingLevel = 1
                var numberOfLines = 0
                var i = initialIndex

                while i < endIndex {
                    let byte = buffer[i]

                    if self.isNewLine(byte) {
                        numberOfLines += 1

                    } else if byte == Options.star {
                        if case let nextIndex = i + 1, nextIndex < endIndex {
                            if buffer[nextIndex] == Options.slash {
                                nestingLevel -= 1

                                if nestingLevel == 0 {
                                    if case let nextNextIndex = nextIndex + 1, nextNextIndex < endIndex {
                                        return (nextNextIndex, numberOfLines)
                                    } else {
                                        return (nextIndex, numberOfLines)
                                    }
                                } else {
                                    i += 2
                                    continue
                                }
                            }
                        }
                    } else if byte == Options.slash {
                        if case let nextIndex = i + 1, nextIndex < endIndex {
                            if buffer[nextIndex] == Options.star {
                                nestingLevel += 1
                                i += 2
                                continue
                            }
                        }
                    }
                    i += 1
                }
                throw NSKJSONError.error(description: "Unterminated multiline comment at \(endIndex - 1).")
            } else {
                throw NSKJSONError.error(description: "Unterminated multiline comment at \(from).")
            }
        } else {
            return nil
        }
    }

    static func skipWhiteSpaces(buffer: Buffer, from: Index) throws -> Index {
        var index = from
        while true {
            let wsIndex = self.skipSpaces(buffer: buffer, from: index)
            
            if let slIndex = self.skipSingleLineComment(buffer: buffer, from: wsIndex) {
                if let mlIndex = try self.skipMultiLineComment(buffer: buffer, from: slIndex) {
                    index = mlIndex
                } else {
                    index = slIndex
                }
            } else if let mlIndex = try self.skipMultiLineComment(buffer: buffer, from: wsIndex) {
                if let slIndex = self.skipSingleLineComment(buffer: buffer, from: mlIndex) {
                    index = slIndex
                } else {
                    index = mlIndex
                }
            } else {
                return wsIndex
            }
        }
    }
    
    static func skipWhiteSpacesWithLines(buffer: Buffer, from: Index) throws -> (index: Index, numberOfLines: Int) {
        var index = from
        var numberOfLines = 0
        
        while true {
            let (wsIndex, wsNumberOfLines) = self.skipSpacesWithLines(buffer: buffer, from: index)
            numberOfLines += wsNumberOfLines
            
            if let (slIndex, slNumberOfLines) = self.skipSingleLineCommentWithLines(buffer: buffer, from: wsIndex) {
                if let (mlIndex, mlNumberOfLines) = try self.skipMultiLineCommentWithLines(buffer: buffer, from: slIndex) {
                    index = mlIndex
                    numberOfLines += (slNumberOfLines + mlNumberOfLines)
                } else {
                    index = slIndex
                    numberOfLines += slNumberOfLines
                }
            } else if let (mlIndex, mlNumberOfLines) = try self.skipMultiLineCommentWithLines(buffer: buffer, from: wsIndex) {
                if let (slIndex, slNumberOfLines) = self.skipSingleLineCommentWithLines(buffer: buffer, from: mlIndex) {
                    index = slIndex
                    numberOfLines += (mlNumberOfLines + slNumberOfLines)
                } else {
                    index = mlIndex
                    numberOfLines += mlNumberOfLines
                }
            } else {
                return (wsIndex, numberOfLines)
            }
        }
    }
    
    static func isSingleLineCommentHasValue(buffer: Buffer, from: Index) -> (index: Index, hasValue: Bool?) {
        if let (index, numberOfLines) = self.skipSingleLineCommentWithLines(buffer: buffer, from: from) {
            if index == buffer.endIndex - 1 {
                if numberOfLines == 0 {
                    return (index, false)
                } else {
                    return (index, Options.isJson5Whitespace(buffer[index]) == false)
                }
            } else {
                return (index, nil)
            }
        } else {
            return (from, nil)
        }
    }
    static func isMultiLineCommentHasValue(buffer: Buffer, from: Index) throws -> (index: Index, hasValue: Bool?) {
        if let index = try self.skipMultiLineComment(buffer: buffer, from: from) {
            if index == buffer.endIndex - 1 {
                let byte = buffer[index]
                if byte == Options.slash, buffer[index - 1] == Options.star {
                    return (index, false)
                } else {
                    return (index, Options.isJson5Whitespace(byte) == false)
                }
            } else {
                return (index, nil)
            }
        } else {
            return (from, nil)
        }
    }
    static func hasValue(buffer: Buffer, from: Index) throws -> Bool {
        var index = from
        while true {
            let wsIndex = self.skipSpaces(buffer: buffer, from: index)
            
            let (slIndex, slHasValue) = self.isSingleLineCommentHasValue(buffer: buffer, from: wsIndex)
            
            if let slHasValue = slHasValue {
                return slHasValue
            } else {
                let (mlIndex, mlHasValue) = try self.isMultiLineCommentHasValue(buffer: buffer, from: slIndex)
                
                if let mlHasValue = mlHasValue {
                    return mlHasValue
                } else {
                    if mlIndex > wsIndex {
                        index = mlIndex
                    } else {
                        return Options.isJson5Whitespace(buffer[mlIndex]) == false
                    }
                }
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////
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
                return (result + Options.string(buffer: buffer, from: begin, to: index), index - from)
                
            } else if byte == Options.backSlash {
                if index < endIndex - 1 {
                    let prefix = Options.string(buffer: buffer, from: begin, to: index)
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
    
    static func parseEscapeSequence(buffer: Buffer, from: Index) throws -> (string: String, length: Int) {
        do {
            return try PlainParser.parseEscapeSequence(buffer: buffer, from: from)
        } catch {
            if Options.isJson5Whitespace(buffer[from]) {
                let (index, numberOfLines) = try self.skipWhiteSpacesWithLines(buffer: buffer, from: from)
                if numberOfLines > 0 {
                    return ("\n", index - from)
                } else {
                    throw NSKJSONError.error(description: "Invalid comment format at \(from).")
                }
            } else if buffer.distance(from: from, to: buffer.endIndex) >= 3 {
                if buffer[from + 0] == Options.x, let b1 = Options.hexByte(buffer[from + 1]),
                    let b0 = Options.hexByte(buffer[from + 2]) {
                    
                    return (String(UnicodeScalar(b1 << 4 + b0)), 3)
                } else {
                    throw NSKJSONError.error(description: "Invalid hex sequence from \(from).")
                }
            } else {
                throw error
            }
        }
    }
    
    static func parseJson5DictionaryKey(buffer: Buffer, from: Index) throws -> (value: String, index: Index) {
        let endIndex = buffer.endIndex
        var index = from
        var begin = index
        var result = ""
        
        while index < endIndex {
            let byte = buffer[index]
            
            if Options.isControlCharacter(byte) {
                throw NSKJSONError.error(description: "Unescaped control character around character \(index).")
                
            } else {
                let nextIndex = index + 1
                if byte == Options.colon || (byte == Options.slash && nextIndex < endIndex && (buffer[nextIndex] == Options.slash || buffer[nextIndex] == Options.star)) {
                    result += Options.string(buffer: buffer, from: begin, to: index)
                    if result.isEmpty {
                        throw NSKJSONError.error(description: "Empty unquoted dictionary key is not allowed at \(index).")
                    } else {
                        return (result, index)
                    }
                } else if byte == Options.backSlash {
                    if index < endIndex - 1 {
                        let prefix = Options.string(buffer: buffer, from: begin, to: index)
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
        }
        throw NSKJSONError.error(description: "Unterminated sequence at \(endIndex).")
    }
    
    static func parseArray(buffer: Buffer, from: Index, nestingLevel: Int) throws -> (value: [Any], index: Index)? {
        guard buffer.distance(from: from, to: buffer.endIndex) >= 2 && buffer[from] == Options.beginArray else {
            return nil
        }
        
        let index = try self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        let terminator = Options.endArray
        
        if buffer[index] == terminator {
            return ([], index + 1)
            
        } else {
            var array: [Any] = []
            var index = index
            
            while true {
                let (value, valueIndex) = try self.parseValue(buffer: buffer, from: index, nestingLevel: nestingLevel)
                array.append(value)
                
                let (endIndex, hasTerminator) = try self.parseValueSpace(buffer: buffer, from: valueIndex, terminator: terminator)
                
                if hasTerminator {
                    return (array, endIndex + 1)
                    
                } else {
                    index = endIndex
                }
            }
        }
    }
    
    static func parseDictionary(buffer: Buffer, from: Index, nestingLevel: Int) throws -> (value: [String: Any], index: Index)? {
        guard buffer.distance(from: from, to: buffer.endIndex) >= 2 && buffer[from] == Options.beginDictionary else {
            return nil
        }
        
        let terminator = Options.endDictionary
        let index = try self.skipWhiteSpaces(buffer: buffer, from: from + 1)
        
        if buffer[index] == terminator {
            return ([:], index + 1)
            
        } else {
            var dictionary: [String: Any] = [:]
            var index = index
            
            while true {
                let (dictionaryKey, keyIndex) = try self.parseDictionaryKey(buffer: buffer, from: index)
                let spaceIndex = try self.parseDictionarySpace(buffer: buffer, from: keyIndex)
                
                let (value, valueIndex) = try self.parseValue(buffer: buffer, from: spaceIndex, nestingLevel: nestingLevel)
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
    
    static func parseString(buffer: Buffer, from: Index) throws -> (string: String, index: Index)? {
        if buffer.distance(from: from, to: buffer.endIndex) >= 2 {
            if case let byte = buffer[from], byte == Options.quotationMark || byte == Options.apostrophe {
                let (string, length) = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: byte)
                return (string, from + length + 2)
            } else {
                return nil
            }
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
        } else if let (primitive, length) = try PlainParser.parsePrimitive(buffer: buffer, from: from) {
            return (primitive, from + length)
        } else if let (number, length) = try NSKJSON5NumberParser<Options>.parseNumber(buffer: buffer, from: from) {
            return (number, from + length)
        } else {
            throw NSKJSONError.error(description: "Unable to parse JSON object at \(from).")
        }
    }
    
    static func parseObject(buffer: Buffer) throws -> Any {
        if buffer.isEmpty {
            throw NSKJSONError.error(description: "Empty input.")
        }
        
        if case let wsIndex = try self.skipWhiteSpaces(buffer: buffer, from: buffer.startIndex), Options.isPlainWhitespace(buffer[wsIndex]) == false {
            let (value, valueIndex) = try self.parseValue(buffer: buffer, from: wsIndex, nestingLevel: 0)
            
            if case let nextIndex = valueIndex, nextIndex < buffer.endIndex {
                if try self.hasValue(buffer: buffer, from: nextIndex) {
                    throw NSKJSONError.error(description: "Garbage at end.")
                } else {
                    return value
                }
            } else {
                return value
            }
        } else {
            throw NSKJSONError.error(description: "No json value found.")
        }
    }
    
    static func parseValueSpace(buffer: Buffer, from: Index, terminator: Byte) throws -> (index: Index, hasTerminator: Bool) {
        let leadingIndex = try self.skipWhiteSpaces(buffer: buffer, from: from)
        let byte = buffer[leadingIndex]
        
        if byte == terminator {
            return (leadingIndex, true)
            
        } else if byte == Options.comma {
            if case let nextIndex = leadingIndex + 1, nextIndex < buffer.endIndex {
                let trailingIndex = try self.skipWhiteSpaces(buffer: buffer, from: nextIndex)
                let byte = buffer[trailingIndex]
                
                if byte == Options.comma {
                    throw NSKJSONError.error(description: "Expected value but ',' found at \(trailingIndex).")
                    
                } else {
                    return (trailingIndex, byte == terminator)
                }
            } else {
                throw NSKJSONError.error(description: "Expected value or closing bracket after \(leadingIndex).")
            }
        } else {
            throw NSKJSONError.error(description: "Expected ',' or closing bracket at \(leadingIndex).")
        }
    }
    
    static func parseDictionaryKey(buffer: Buffer, from: Index) throws -> (value: String, index: Index) {
        if buffer.distance(from: from, to: buffer.endIndex) >= 2 {
            let byte = buffer[from]
            switch byte {
            case Options.quotationMark, Options.apostrophe:
                let (key, length) = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: byte)
                return (key, from + length + 2)
            default:
                return try self.parseJson5DictionaryKey(buffer: buffer, from: from)
            }
        } else {
            throw NSKJSONError.error(description: "Invalid dictionary key at \(from).")
        }
    }
    
    static func parseDictionarySpace(buffer: Buffer, from: Index) throws -> Index {
        let leadingIndex = try self.skipWhiteSpaces(buffer: buffer, from: from)
        
        if buffer[leadingIndex] == Options.colon {
            if case let nextIndex = leadingIndex + 1, nextIndex < buffer.endIndex {
                let trailingIndex = try self.skipWhiteSpaces(buffer: buffer, from: nextIndex)
                
                return trailingIndex
            } else {
                throw NSKJSONError.error(description: "Expected value at \(leadingIndex).")
            }
        } else {
            throw NSKJSONError.error(description: "Expected ':' at \(leadingIndex).")
        }
    }
}
