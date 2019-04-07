//
//  NSKOptions.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 12.02.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation

protocol NSKOptions {
    associatedtype Byte: UnsignedInteger
    typealias Buffer = UnsafeBufferPointer<Byte>
    typealias Index = Buffer.Index
    
    static var newLine: Byte { get } // \n
    static var carriageReturn: Byte { get } // \r
    static var tab: Byte { get } // \t
    static var space: Byte { get } // ' '
    
    static var formFeed: Byte { get }
    static var nbSpace: Byte { get }
    
    
    static var beginArray: Byte { get } // [
    static var endArray: Byte { get } // ]
    static var beginDictionary: Byte { get } // {
    static var endDictionary: Byte { get } // }
    static var colon: Byte { get } // :
    static var quotationMark: Byte { get } // "
    static var apostrophe: Byte { get } // '
    static var slash: Byte { get } // /
    static var backSlash: Byte { get } // \
    static var comma: Byte { get } //
    
    static var b: Byte { get } // b
    static var n: Byte { get } // n
    static var t: Byte { get } // t
    static var r: Byte { get } // r
    static var u: Byte { get } // u
    static var e: Byte { get } // e
    static var f: Byte { get } // f
    static var a: Byte { get } // a
    static var l: Byte { get } // l
    static var s: Byte { get } // s
    static var x: Byte { get } // x
    static func minus(_ character: Byte) -> UInt8? // -
    static func plus(_ character: Byte) -> UInt8? // +
    static func dot(_ character: Byte) -> UInt8? // .
    static func e(_ character: Byte) -> UInt8? // e or E
    static func p(_ character: Byte) -> UInt8? // p or P
    static func x(_ character: Byte) -> UInt8? // x or X
    static func zero(_ character: Byte) -> UInt8? // 0
    static var star: Byte { get } // *
    static var I: Byte { get } // I
    static var i: Byte { get } // i
    static var y: Byte { get } // y
    static var N: Byte { get } // N
    
    static func isPlainWhitespace(_ character: Byte) -> Bool
    static func isJson5Whitespace(_ character: Byte) -> Bool
    static func isControlCharacter(_ character: Byte) -> Bool
    static func hexByte(_ character: Byte) -> UInt8? // [0-15]
    static func digit(_ character: Byte) -> UInt8? // [0-9]
    
    static func string(buffer: Buffer, from: Index, to: Index) -> String
}

extension NSKOptions {
    static func buffer<ResultType>(data: Data, offset: Int, isBigEndian: Bool,
                                   block: (Result<Buffer, Error>) throws -> ResultType) rethrows -> ResultType {
        if case let length = data.count - offset, length > 0 {
            let stride = MemoryLayout<Byte>.stride
            if length.isMultiple(of: stride) {
                switch (isBigEndian, __CFByteOrder(UInt32(CFByteOrderGetCurrent()))) {
                case (true, CFByteOrderBigEndian):
                    fallthrough
                case (false, CFByteOrderLittleEndian):
                    return try data[offset...].withUnsafeBytes({ (rawBufferPointer) -> ResultType in
                        return try block(.success(rawBufferPointer.bindMemory(to: Byte.self)))
                    })
                case (false, CFByteOrderBigEndian):
                    fallthrough
                case (true, CFByteOrderLittleEndian):
                    return try data.reversed()[..<(data.endIndex - offset)].withUnsafeBytes({ (rawBufferPointer) -> ResultType in
                        let pointer: [Byte] = rawBufferPointer.bindMemory(to: Byte.self).reversed()
                        return try pointer.withUnsafeBytes({ (raw) -> ResultType in
                            return try block(.success(raw.bindMemory(to: Byte.self)))
                        })
                    })
                default:
                    return try block(.failure(NSKJSONError.error(description: "Incorrect byte order.")))
                }
            } else {
                return try block(.failure(NSKJSONError.error(description: "Byte size: \(stride) if not divider for data length: \(length).")))
            }
        } else {
            return try block(.failure(NSKJSONError.error(description: "Empty input.")))
        }
    }
}
extension NSKJSON {
    struct OptionsUTF8: NSKOptions {
        private init() {}
        typealias Byte = UTF8.CodeUnit
        
        static let newLine          : Byte = 0x0A
        static let carriageReturn   : Byte = 0x0D
        static let tab              : Byte = 0x09
        static let space            : Byte = 0x20
        static let formFeed         : Byte = 0x0C
        static let nbSpace          : Byte = 0xA0
        static let beginArray       : Byte = 0x5B
        static let endArray         : Byte = 0x5D
        static let beginDictionary  : Byte = 0x7B
        static let endDictionary    : Byte = 0x7D
        static let colon            : Byte = 0x3A
        static let quotationMark    : Byte = 0x22
        static let apostrophe       : Byte = 0x27
        static let slash            : Byte = 0x2F
        static let backSlash        : Byte = 0x5C
        static let comma            : Byte = 0x2C
        static let b                : Byte = 0x62
        static let n                : Byte = 0x6E
        static let t                : Byte = 0x74
        static let r                : Byte = 0x72
        static let u                : Byte = 0x75
        static let e                : Byte = 0x65
        static let f                : Byte = 0x66
        static let a                : Byte = 0x61
        static let l                : Byte = 0x6C
        static let s                : Byte = 0x73
        private static let minus    : Byte = 0x2D
        private static let plus     : Byte = 0x2B
        private static let dot      : Byte = 0x2E
        private static let E        : Byte = 0x45
        private static let P        : Byte = 0x50
        private static let p        : Byte = 0x70
        static let x                : Byte = 0x78
        private static let X        : Byte = 0x58
        static let star             : Byte = 0x2A
        static let I                : Byte = 0x49
        static let i                : Byte = 0x69
        static let y                : Byte = 0x79
        static let N                : Byte = 0x4E
        private static let zero     : Byte = 0x30
        
        static func isPlainWhitespace(_ character: Byte) -> Bool {
            return character == self.space ||
            character == self.newLine ||
            character == self.carriageReturn ||
            character == self.tab
        }
        static func isJson5Whitespace(_ character: Byte) -> Bool {
            if self.isPlainWhitespace(character) {
                return true
            } else {
                return character == self.formFeed || character == self.nbSpace
            }
        }
        static func isControlCharacter(_ character: Byte) -> Bool {
            return character >= 0 && character <= 0x1F
        }
        
        static func minus(_ character: Byte) -> UInt8? {
            return (character == self.minus) ? character : nil
        }
        static func plus(_ character: Byte) -> UInt8? {
            return (character == self.plus) ? character : nil
        }
        static func dot(_ character: Byte) -> UInt8? {
            return (character == self.dot) ? character : nil
        }
        static func e(_ character: Byte) -> UInt8? {
            if character == self.e || character == self.E {
                return character
            } else {
                return nil
            }
        }
        static func p(_ character: Byte) -> UInt8? {
            if character == self.p || character == self.P {
                return character
            } else {
                return nil
            }
        }
        static func x(_ character: Byte) -> UInt8? {
            if character == self.x || character == self.X {
                return character
            } else {
                return nil
            }
        }
        static func zero(_ character: Byte) -> UInt8? {
            return (character == self.zero) ? character : nil
        }
        
        static func hexByte(_ character: Byte) -> Byte? {
            if let digit = self.digit(character) {
                return digit
            } else if character >= self.a && character <= self.f {
                return character
            } else if character >= 0x41 && character <= 0x46 {
                return character
            } else {
                return nil
            }
        }
        static func digit(_ character: Byte) -> UInt8? {
            return (character >= self.zero && character <= 0x39) ? character : nil
        }
        
        static func utf8Buffer<ResultType>(data: Data, offset: Int,
                                           block: (Buffer) throws -> ResultType) rethrows -> ResultType {
            return try data[offset...].withUnsafeBytes { (raw) -> ResultType in
                return try block(raw.bindMemory(to: Byte.self))
            }
        }
        
        static func string(buffer: Buffer, from: Index, to: Index) -> String {
            return String(decoding: buffer[from..<to], as: UTF8.self)
        }
    }
    
    struct OptionsUTF16: NSKOptions {
        private init() {}
        typealias Byte = UTF16.CodeUnit
        
        static let newLine          : Byte = Byte(OptionsUTF8.newLine)
        static let carriageReturn   : Byte = Byte(OptionsUTF8.carriageReturn)
        static let tab              : Byte = Byte(OptionsUTF8.tab)
        static let space            : Byte = Byte(OptionsUTF8.space)
        static let formFeed         : Byte = Byte(OptionsUTF8.formFeed)
        static let nbSpace          : Byte = Byte(OptionsUTF8.nbSpace)
        static let beginArray       : Byte = Byte(OptionsUTF8.beginArray)
        static let endArray         : Byte = Byte(OptionsUTF8.endArray)
        static let beginDictionary  : Byte = Byte(OptionsUTF8.beginDictionary)
        static let endDictionary    : Byte = Byte(OptionsUTF8.endDictionary)
        static let colon            : Byte = Byte(OptionsUTF8.colon)
        static let quotationMark    : Byte = Byte(OptionsUTF8.quotationMark)
        static let apostrophe       : Byte = Byte(OptionsUTF8.apostrophe)
        static let slash            : Byte = Byte(OptionsUTF8.slash)
        static let backSlash        : Byte = Byte(OptionsUTF8.backSlash)
        static let comma            : Byte = Byte(OptionsUTF8.comma)
        static let b                : Byte = Byte(OptionsUTF8.b)
        static let n                : Byte = Byte(OptionsUTF8.n)
        static let t                : Byte = Byte(OptionsUTF8.t)
        static let r                : Byte = Byte(OptionsUTF8.r)
        static let u                : Byte = Byte(OptionsUTF8.u)
        static let e                : Byte = Byte(OptionsUTF8.e)
        static let f                : Byte = Byte(OptionsUTF8.f)
        static let a                : Byte = Byte(OptionsUTF8.a)
        static let l                : Byte = Byte(OptionsUTF8.l)
        static let s                : Byte = Byte(OptionsUTF8.s)
        static let x                : Byte = Byte(OptionsUTF8.x)
        static let star             : Byte = Byte(OptionsUTF8.star)
        static let I                : Byte = Byte(OptionsUTF8.I)
        static let i                : Byte = Byte(OptionsUTF8.i)
        static let y                : Byte = Byte(OptionsUTF8.y)
        static let N                : Byte = Byte(OptionsUTF8.N)
        
        @inline(__always)
        private static func getByte(from character: Byte) -> OptionsUTF8.Byte? {
            return OptionsUTF8.Byte(exactly: character)
        }
        
        static func isPlainWhitespace(_ character: Byte) -> Bool {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.isPlainWhitespace(byte)
            }
            return false
        }
        static func isJson5Whitespace(_ character: Byte) -> Bool {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.isJson5Whitespace(byte)
            }
            return false
        }
        static func isControlCharacter(_ character: Byte) -> Bool {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.isControlCharacter(byte)
            }
            return false
        }
        
        static func hexByte(_ character: Byte) -> OptionsUTF8.Byte? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.hexByte(byte)
            }
            return nil
        }
        static func minus(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.minus(byte)
            }
            return nil
        }
        static func plus(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.plus(byte)
            }
            return nil
        }
        static func dot(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.dot(byte)
            }
            return nil
        }
        static func e(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.e(byte)
            }
            return nil
        }
        static func p(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.p(byte)
            }
            return nil
        }
        static func x(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.x(byte)
            }
            return nil
        }
        static func zero(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.zero(byte)
            }
            return nil
        }
        static func digit(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.digit(byte)
            }
            return nil
        }
        static func string(buffer: Buffer, from: Index, to: Index) -> String {
            return String(decoding: buffer[from..<to], as: UTF16.self)
        }
    }
    
    struct OptionsUTF32: NSKOptions {
        private init() {}
        typealias Byte = UTF32.CodeUnit
        
        static let newLine          : Byte = Byte(OptionsUTF8.newLine)
        static let carriageReturn   : Byte = Byte(OptionsUTF8.carriageReturn)
        static let tab              : Byte = Byte(OptionsUTF8.tab)
        static let space            : Byte = Byte(OptionsUTF8.space)
        static let formFeed         : Byte = Byte(OptionsUTF8.formFeed)
        static let nbSpace          : Byte = Byte(OptionsUTF8.nbSpace)
        static let beginArray       : Byte = Byte(OptionsUTF8.beginArray)
        static let endArray         : Byte = Byte(OptionsUTF8.endArray)
        static let beginDictionary  : Byte = Byte(OptionsUTF8.beginDictionary)
        static let endDictionary    : Byte = Byte(OptionsUTF8.endDictionary)
        static let colon            : Byte = Byte(OptionsUTF8.colon)
        static let quotationMark    : Byte = Byte(OptionsUTF8.quotationMark)
        static let apostrophe       : Byte = Byte(OptionsUTF8.apostrophe)
        static let slash            : Byte = Byte(OptionsUTF8.slash)
        static let backSlash        : Byte = Byte(OptionsUTF8.backSlash)
        static let comma            : Byte = Byte(OptionsUTF8.comma)
        static let b                : Byte = Byte(OptionsUTF8.b)
        static let n                : Byte = Byte(OptionsUTF8.n)
        static let t                : Byte = Byte(OptionsUTF8.t)
        static let r                : Byte = Byte(OptionsUTF8.r)
        static let u                : Byte = Byte(OptionsUTF8.u)
        static let e                : Byte = Byte(OptionsUTF8.e)
        static let f                : Byte = Byte(OptionsUTF8.f)
        static let a                : Byte = Byte(OptionsUTF8.a)
        static let l                : Byte = Byte(OptionsUTF8.l)
        static let s                : Byte = Byte(OptionsUTF8.s)
        static let x                : Byte = Byte(OptionsUTF8.x)
        static let star             : Byte = Byte(OptionsUTF8.star)
        static let I                : Byte = Byte(OptionsUTF8.I)
        static let i                : Byte = Byte(OptionsUTF8.i)
        static let y                : Byte = Byte(OptionsUTF8.y)
        static let N                : Byte = Byte(OptionsUTF8.N)
        
        @inline(__always)
        private static func getByte(from character: Byte) -> OptionsUTF8.Byte? {
            return OptionsUTF8.Byte(exactly: character)
        }
        
        static func isPlainWhitespace(_ character: Byte) -> Bool {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.isPlainWhitespace(byte)
            }
            return false
        }
        static func isJson5Whitespace(_ character: Byte) -> Bool {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.isJson5Whitespace(byte)
            }
            return false
        }
        static func isControlCharacter(_ character: Byte) -> Bool {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.isControlCharacter(byte)
            }
            return false
        }
        static func hexByte(_ character: Byte) -> OptionsUTF8.Byte? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.hexByte(byte)
            }
            return nil
        }
        static func minus(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.minus(byte)
            }
            return nil
        }
        static func plus(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.plus(byte)
            }
            return nil
        }
        static func dot(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.dot(byte)
            }
            return nil
        }
        static func e(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.e(byte)
            }
            return nil
        }
        static func p(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.p(byte)
            }
            return nil
        }
        static func x(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.x(byte)
            }
            return nil
        }
        static func zero(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.zero(byte)
            }
            return nil
        }
        static func digit(_ character: Byte) -> UInt8? {
            if let byte = self.getByte(from: character) {
                return OptionsUTF8.digit(byte)
            }
            return nil
        }
        static func string(buffer: Buffer, from: Index, to: Index) -> String {
            return String(decoding: buffer[from..<to], as: UTF32.self)
        }
    }
}
