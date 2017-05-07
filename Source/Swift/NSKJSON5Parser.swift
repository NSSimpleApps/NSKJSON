//
//  NSKJSON5Parser.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 01.05.17.
//
//

import Foundation

internal final class NSKJSON5Parser: NSKPlainParser {
    
    internal override func skipWhiteSpaces(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (index: Int, hasValue: Bool, numberOfLines: Int) {
        
        var currentIndex = from
        var numberOfLines = 0
        
        while true {
            
            let (index, hasValue, wsLines) = try super.skipWhiteSpaces(buffer: buffer, from: currentIndex)
            
            numberOfLines += wsLines
            
            if hasValue {
                
                let length = buffer.endIndex - index
                
                if length >= 2 {
                    
                    let b0 = buffer[index + 0]
                    let b1 = buffer[index + 1]
                    
                    switch (b0, b1) {
                        
                    case (NSKSlash, NSKSlash):
                        
                        let (index, hasNext, slLines) = self.skipSingleLineComment(buffer: buffer, from: index)
                        numberOfLines += slLines
                        
                        if hasNext {
                            
                            currentIndex = index
                            
                        } else {
                            
                            return (index, false, numberOfLines)
                        }
                        
                    case (NSKSlash, NSKStar):
                        
                        let (index, hasNext, mlLines) = try skipMultiLineComment(buffer: buffer, from: index)
                        numberOfLines += mlLines
                        
                        if hasNext {
                            
                            currentIndex = index
                            
                        } else {
                            
                            return (index, false, numberOfLines)
                        }
                        
                    default:
                        
                        return (index, true, numberOfLines)
                    }
                    
                } else {
                    
                    return (index, true, numberOfLines)
                }
                
            } else {
                
                return (index, false, numberOfLines)
            }
        }
    }
    
    internal func skipSingleLineComment(buffer: UnsafeBufferPointer<UInt8>, from: Int) -> (index: Int, hasNext: Bool, numberOfLines: Int) {
        
        let endIndex = buffer.endIndex
        let length = endIndex - from
        
        if length < 2 || (buffer[from] != NSKSlash || buffer[from + 1] != NSKSlash) {
            
            return (from, from < endIndex - 1, 0)
            
        } else {
            
            for index in from + 2 ..< endIndex {
                
                if buffer[index] == NSKNewLine {
                    
                    if index == endIndex - 1 {
                        
                        return (index, false, 1)
                        
                    } else {
                        
                        let nextIndex = index + 1
                        
                        return (nextIndex, nextIndex < endIndex - 1, 1)
                    }
                }
            }
            
            return (endIndex - 1, false, 0)
        }
    }
    
    internal func skipMultiLineComment(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (index: Int, hasNext: Bool, numberOfLines: Int) {
        
        func match(buffer: UnsafeBufferPointer<UInt8>, from: Int, args: UInt8...) -> (isMatch: Bool, hasNext: Bool) {
            
            let endIndex = buffer.endIndex
            let index = from + args.count
            
            if index > endIndex {
                
                return (false, from < endIndex)
                
            } else {
                
                if args == Array(buffer[from..<index]) {
                    
                    return (true, index < endIndex)
                    
                } else {
                    
                    return (false, from < endIndex)
                }
            }
        }
        
        let endIndex = buffer.endIndex
        let length = endIndex - from
        
        if (length < 2) || (buffer[from] != NSKSlash || buffer[from + 1] != NSKStar) {
            
            return (from, from < endIndex - 1, 0)
            
        } else {
            
            var nestingLevel = 1
            var index = from + 2
            var numberOfLines = 0
            
            while index < endIndex {
                
                let (hasNewLine, hasNextAfterNewLine) = match(buffer: buffer, from: index, args: NSKNewLine)
                
                if hasNewLine {
                    
                    if hasNextAfterNewLine {
                        
                        numberOfLines += 1
                        index += 1
                        
                        continue
                        
                    } else {
                        
                        break
                    }
                }
                
                let (hasOpeningComment, hasNextAfterOpeningComment) = match(buffer: buffer, from: index, args: NSKSlash, NSKStar)
                
                if hasOpeningComment {
                    
                    nestingLevel += 1
                    
                    if hasNextAfterOpeningComment {
                        
                        index += 2
                        
                        continue
                        
                    } else {
                        
                        break
                    }
                }
                
                let (hasClosingComment, hasNextAfterClosingComment) = match(buffer: buffer, from: index, args: NSKStar, NSKSlash)
                
                if hasClosingComment {
                    
                    nestingLevel -= 1
                    
                    if nestingLevel == 0 {
                        
                        if hasNextAfterClosingComment {
                            
                            let nextIndex = index + 2
                            
                            return (nextIndex, nextIndex < endIndex - 1, numberOfLines)
                            
                        } else {
                            
                            return (index + 1, false, numberOfLines)
                        }
                        
                    } else {
                        
                        index += 2
                        
                        continue
                    }
                }
                
                index += 1
            }
            
            throw NSError(domain: "1", code: 1, userInfo: ["d": "Unterminated multiline comment at \(index)."])
        }
    }
    
    override func parseEscapeSequence(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (string: String, offset: Int) {
        
        let b0 = buffer[from + 0]
        
        switch b0 {
            
        case NSKx:
            let result = try self.parseXSequence(buffer: buffer, from: from + 1)
            
            return (result, 3)
            
        case let byte where NSKWhitespaces.contains(byte):
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
    
    internal final func parseXSequence(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> String {
        
        let length = buffer.endIndex - from
        
        guard length >= 2 else {
            
            throw NSKJSONError.error(description: "Expected at least 2 hex digits instead of \(length) at \(from).")
        }
        
        let b1 = buffer[from + 0]
        let b0 = buffer[from + 1]
        
        if b0.isHex && b1.isHex {
            
            return String(bytes: [b1, b0], encoding: .utf8)!
            
        } else {
            
            throw NSKJSONError.error(description: "Invalid hex digit in unicode escape sequence around character \(from).")
        }
    }
    
    internal override final func parseNumber(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (value: Any, offset: Int) {
        
        let (value, offset) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: from, terminator: NSKJSON5Terminator.self)
        
        return (value, offset)
    }
    
    internal override final func stringTerminator(byte: UInt8) -> NSKTerminator.Type? {
        
        if byte == NSKSingleQuotationMark {
            
            return NSKSingleQuotationTerminator.self
            
        } else {
            
            return super.stringTerminator(byte: byte)
        }
    }
    
    internal override final func isNumberPrefix(_ prefix: UInt8) -> Bool {
        
        return NSKJSON5NumberParser.isNumberPrefix(prefix)
    }
    
    internal override final func parseValueSpace(buffer: UnsafeBufferPointer<UInt8>, from: Int, terminator: UInt8) throws -> (offset: Int, hasTerminator: Bool) {
        
        return try self.parseValueSpace(buffer: buffer, from: from, terminator: terminator, trailingComma: true)
    }
    
    internal override final func parseDictionaryKey(buffer: UnsafeBufferPointer<UInt8>, from: Int) throws -> (value: String, offset: Int) {
        
        if let stringTerminator = self.stringTerminator(byte: buffer[from]) {
            
            return try self.parseString(buffer: buffer, from: from, terminator: stringTerminator)
            
        } else {
            
            return try self.parseByteSequence(buffer: buffer, from: from, terminator: NSKDictionaryKeyTerminator.self)
        }
    }
}
