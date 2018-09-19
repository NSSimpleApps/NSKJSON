//
//  NSKJSON5Parser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 01.05.17.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//


import Foundation


internal final class NSKJSON5Parser<C>: NSKPlainParser<C> where C: Collection, C.Iterator.Element: UnsignedInteger, C.Index == Int {
    
    internal override func skipWhiteSpaces(buffer: C, from: Int) throws -> (index: Int, hasValue: Bool, numberOfLines: Int) {
        let whitespaces = self.options.json5Whitespaces
        var index = from
        var numberOfLines = 0
        
        while true {
            let (wsIndex, wsHasValue, wsLines) = self.skip(buffer: buffer, from: index, set: whitespaces)
            
            numberOfLines += wsLines
            index = wsIndex
            
            if wsHasValue {
                let (slIndex, slHasNext, slHasValue, slLines) = self.skipSingleLineComment(buffer: buffer, from: index, whitespaces: whitespaces)
                
                numberOfLines += slLines
                index = slIndex
                
                if slHasNext {
                    let (mlIndex, mlHasNext, mlHasValue, mlLines) = try self.skipMultiLineComment(buffer: buffer, from: index, whitespaces: whitespaces)
                    
                    numberOfLines += mlLines
                    index = mlIndex
                    
                    if mlHasNext {
                        if wsIndex == index {
                            return (index, mlHasValue, numberOfLines)
                            
                        } else {
                            continue
                        }
                    } else {
                        return (index, mlHasValue, numberOfLines)
                    }
                } else {
                    return (index, slHasValue, numberOfLines)
                }
            } else {
                return (index, false, numberOfLines)
            }
        }
    }
    
    internal func skipSingleLineComment(buffer: C, from: Int, whitespaces: Set<Byte>) -> (index: Int, hasNext: Bool, hasValue: Bool, numberOfLines: Int) {
        let length = buffer.distance(from: from, to: buffer.endIndex)
        let endIndex = buffer.endIndex - 1
        
        if length < 2 || (buffer[from] != self.options.slash || buffer[from + 1] != self.options.slash) {
            return (from, from + 1 <= endIndex, whitespaces.contains(buffer[from]) == false, 0)
            
        } else {
            let startIndex = from + 2
            
            if startIndex > endIndex {
                return (endIndex, false, false, 0)
            }
            for index in startIndex...endIndex {
                let byte = buffer[index]
                
                if byte == self.options.newLine || byte == self.options.carriageReturn {
                    if index == endIndex {
                        return (index, false, false, 1)
                        
                    } else {
                        let nextIndex = index + 1
                        return (nextIndex, nextIndex < endIndex, whitespaces.contains(buffer[nextIndex]) == false, 1)
                    }
                }
            }
            return (endIndex, false, whitespaces.contains(buffer[endIndex]) == false, 0)
        }
    }
    
    internal func skipMultiLineComment(buffer: C, from: Int, whitespaces: Set<Byte>) throws -> (index: Int, hasNext: Bool, hasValue: Bool, numberOfLines: Int) {
        let length = buffer.distance(from: from, to: buffer.endIndex)
        let endIndex = buffer.endIndex - 1
        
        if (length < 2) || (buffer[from] != self.options.slash || buffer[from + 1] != self.options.star) {
            return (from, from + 1 <= endIndex, whitespaces.contains(buffer[from]) == false, 0)
            
        } else {
            var nestingLevel = 1
            var index = from + 2
            var numberOfLines = 0
            
            while index <= endIndex {
                let byte = buffer[index]
                
                if byte == self.options.newLine || byte == self.options.carriageReturn {
                    numberOfLines += 1
                    
                } else if byte == self.options.slash {
                    if index < endIndex {
                        if buffer[index + 1] == self.options.star {
                            nestingLevel += 1
                            index += 2
                            continue
                            
                        } else {
                            index += 2
                            continue
                        }
                    } else {
                        break
                    }
                } else if byte == self.options.star {
                    if index < endIndex {
                        let nextIndex = index + 1
                        
                        if buffer[nextIndex] == self.options.slash {
                            nestingLevel -= 1
                            
                            if nestingLevel == 0 {
                                if nextIndex == endIndex {
                                    return (nextIndex, false, false, numberOfLines)
                                    
                                } else {
                                    return (nextIndex + 1, nextIndex + 1 < endIndex, whitespaces.contains(buffer[nextIndex + 1]) == false, numberOfLines)
                                }
                            } else {
                                index += 2
                                continue
                            }
                        } else {
                            index += 2
                            continue
                        }
                    } else {
                        break
                    }
                }
                index += 1
            }
            throw NSKJSONError.error(description: "Unterminated multiline comment at \(index).")
        }
    }
    
    internal override func parseValue(buffer: C, from: Int, nestingLevel: Int) throws -> (value: Any, offset: Int) {
        let byte = buffer[from]
        
        switch byte {
        case self.options.apostrophe where from < buffer.endIndex - 1:
            let string = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: byte)
            
            return (string.value, string.offset + 2)
            
        default:
            return try super.parseValue(buffer: buffer, from: from, nestingLevel: nestingLevel)
        }
    }
    
    internal override func isNumberPrefix(byte: Byte) -> Bool {
        return NSKJSON5NumberParser<C>.isValidPrefix(byte, options: self.options)
    }
    
    override func parseEscapeSequence(buffer: C, from: Int) throws -> (string: String, offset: Int) {
        
        let b0 = buffer[from + 0]
        
        switch b0 {
        case self.options.x, self.options.X:
            let result = try self.parseXSequence(buffer: buffer, from: from + 1)
            return (result, 3)
            
        case let byte where self.options.whitespaces.contains(byte):
            let (index, hasValue, numberOfLines) = try self.skipWhiteSpaces(buffer: buffer, from: from)
            
            if hasValue && numberOfLines > 0 {
                return ("\n", index - from)
                
            } else {
                throw NSKJSONError.error(description: "Invalid comment format at \(from).")
            }
            
        default:
            return try super.parseEscapeSequence(buffer: buffer, from: from)
        }
    }
    
    internal func parseXSequence(buffer: C, from: Int) throws -> String {
        let length = 2
        let matchResult = NSKMatcher<C>.match(buffer: buffer,
                                              from: from,
                                              length: length,
                                              where: { (elem, index) -> Bool in
                                                
                                                return self.options.isHex(elem)
        })
        
        switch matchResult {
            
        case .outOfRange, .lengthMismatch:
            throw NSKJSONError.error(description: "Expected at least 2 hex digits instead of \(length) at \(from).")
            
        case .mismatch(let index):
            throw NSKJSONError.error(description: "Invalid hex digit in unicode escape sequence around character \(index).")
            
        case .match:
            let b1 = buffer[from + 0]
            let b0 = buffer[from + 1]
            return self.options.string(bytes: [b1, b0])!
        }
    }
    
    internal override func parseNumber(buffer: C, from: Int) throws -> (value: Any, offset: Int) {
        let whiteSpaces = self.options.json5Whitespaces
        let endArray = self.options.endArray
        let endDictionary = self.options.endDictionary
        let comma = self.options.comma
        let slash = self.options.slash
        let star = self.options.star
        let plainJSONTerminator =
            NSKPlainJSONTerminator(whiteSpaces: whiteSpaces,
                                   endArray: endArray,
                                   endDictionary: endDictionary,
                                   comma: comma)
        let json5Terminator =
        NSKJSON5Terminator(terminator: plainJSONTerminator,
                           slash: slash, star: star)
        let numberParser = NSKJSON5NumberParser<C>(options: self.options)
        
        let (value, offset) = try numberParser.parseNumber(buffer: buffer, from: from, terminator: { (buffer, index) -> Bool in
            return json5Terminator.contains(buffer: buffer, at: index)
        })
        
        return (value, offset)
    }
    
    internal override func parseDictionaryKey(buffer: C, from: Int) throws -> (value: String, offset: Int) {
        if buffer.endIndex - from >= 2 {
            let byte = buffer[from]
                
            if byte == self.options.quotationMark || byte == self.options.apostrophe {
                let result = try self.parseByteSequence(buffer: buffer, from: from + 1, terminator: byte)
                
                return (result.value, result.offset + 2)
                
            } else if byte != self.options.colon {
                let whitespaces = self.options.json5Whitespaces
                let colon = self.options.colon
                let slash = self.options.slash
                let star = self.options.star
                let result = try self.parseByteSequence(buffer: buffer, from: from, terminator: { (buffer, index) -> Bool in
                    
                    let terminator = NSKDictionaryKeyTerminator(whiteSpaces: whitespaces, colon: colon, slash: slash, star: star)
                    return terminator.contains(buffer: buffer, at: index)
                })
                
                return (result.value, result.offset)
            }
        }
        throw NSKJSONError.error(description: "Invalid dictionary format at \(from).")
    }
}
