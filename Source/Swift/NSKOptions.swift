//
//  NSKOptions.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 12.02.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation

protocol NSKOptions {
    associatedtype CodePoint: UnicodeCodec
    typealias Byte = CodePoint.CodeUnit
    typealias Buffer = UnsafeBufferPointer<Byte>
    typealias Index = Buffer.Index
    
    static var newLine        : Byte { get } // \n
    static var carriageReturn : Byte { get } // \r
    static var tab            : Byte { get } // \t
    static var space          : Byte { get } // ' '
    static var formFeed       : Byte { get }
    static var nbSpace        : Byte { get }
    static var beginArray     : Byte { get } // [
    static var endArray       : Byte { get } // ]
    static var beginDictionary: Byte { get } // {
    static var endDictionary  : Byte { get } // }
    static var colon          : Byte { get } // :
    static var quotationMark  : Byte { get } // "
    static var apostrophe     : Byte { get } // '
    static var slash          : Byte { get } // /
    static var backSlash      : Byte { get } // \
    static var comma          : Byte { get } //
    static var b              : Byte { get } // b
    static var n              : Byte { get } // n
    static var t              : Byte { get } // t
    static var r              : Byte { get } // r
    static var u              : Byte { get } // u
    static var e              : Byte { get } // e
    static var f              : Byte { get } // f
    static var a              : Byte { get } // a
    static var l              : Byte { get } // l
    static var s              : Byte { get } // s
    static var x              : Byte { get } // x
    static var star           : Byte { get } // *
    static var I              : Byte { get } // I
    static var i              : Byte { get } // i
    static var y              : Byte { get } // y
    static var N              : Byte { get } // N
    
    static func minus(_ character: Byte) -> UInt8? // -
    static func plus(_ character: Byte) -> UInt8? // +
    static func dot(_ character: Byte) -> UInt8? // .
    static func e(_ character: Byte) -> UInt8? // e or E
    static func p(_ character: Byte) -> UInt8? // p or P
    static func x(_ character: Byte) -> UInt8? // x or X
    static func zero(_ character: Byte) -> UInt8? // 0
    
    static func isPlainWhitespace(_ character: Byte) -> Bool
    static func isJSON5Whitespace(_ character: Byte) -> Bool
    static func isControlCharacter(_ character: Byte) -> Bool
    static func hexByte(_ character: Byte) -> UInt8? // [0-15]
    static func digit(_ character: Byte) -> UInt8? // [0-9]
}

extension NSKOptions {
    static func string(buffer: Buffer, from: Index, to: Index) throws -> String {
        var it = buffer[from..<to].makeIterator()
        var d = CodePoint()
        var index = from
        var scalarView = String.UnicodeScalarView()
        scalarView.reserveCapacity(buffer.distance(from: from, to: to))
        
        outer: while true {
            switch d.decode(&it) {
            case .emptyInput:
                break outer
            case .error:
                throw NSKJSONError.error(description: "Unable to convert data to a string at: \(index).")
            case .scalarValue(let scalar):
                scalarView.append(scalar)
                index += 1
            }
        }
        return String(scalarView)
    }
    
    
    static func buffer<ResultType>(data: Data, offset: Int, isBigEndian: Bool,
                                   block: (Result<Buffer, NSError>) throws -> ResultType) rethrows -> ResultType {
        if case let length = data.count - offset, length > 0 {
            let stride = MemoryLayout<Byte>.stride
            if length.isMultiple(of: stride) {
                switch (isBigEndian, __CFByteOrder(UInt32(CFByteOrderGetCurrent()))) {
                case (true, CFByteOrderBigEndian):
                    fallthrough
                case (false, CFByteOrderLittleEndian):
                    return try data.dropFirst(offset).withUnsafeBytes({ (rawBufferPointer) -> ResultType in
                        return try block(.success(rawBufferPointer.bindMemory(to: Byte.self)))
                    })
                case (false, CFByteOrderBigEndian):
                    fallthrough
                case (true, CFByteOrderLittleEndian):
                    return try data.reversed().dropLast(offset).withUnsafeBytes({ (rawBufferPointer) -> ResultType in
                        let pointer: [Byte] = rawBufferPointer.bindMemory(to: Byte.self).reversed()
                        return try pointer.withUnsafeBytes({ (rawBufferPointer) -> ResultType in
                            return try block(.success(rawBufferPointer.bindMemory(to: Byte.self)))
                        })
                    })
                default:
                    return try block(.failure(NSKJSONError.error(description: "Incorrect byte order.")))
                }
            } else {
                return try block(.failure(NSKJSONError.error(description: "Byte size: \(stride) is not divider for data length: \(length).")))
            }
        } else {
            return try block(.failure(NSKJSONError.error(description: "Empty input.")))
        }
    }
}

struct NSKOptionsUTF8: NSKOptions {
    private init() {}
    typealias CodePoint = UTF8
    
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
    static let zero             : Byte = 0x30
    
    static func isPlainWhitespace(_ character: Byte) -> Bool {
        return character == self.space ||
        character == self.newLine ||
        character == self.carriageReturn ||
        character == self.tab
    }
    static func isJSON5Whitespace(_ character: Byte) -> Bool {
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
    
    static func hexByte(_ character: Byte) -> UInt8? {
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
}

protocol NSKWideOptions: NSKOptions {
}
extension NSKWideOptions {
    @inline(__always)
    private static func getByte(from character: Byte) -> NSKOptionsUTF8.Byte? {
        return NSKOptionsUTF8.Byte(exactly: character)
    }
    
    static func isPlainWhitespace(_ character: Byte) -> Bool {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.isPlainWhitespace(byte)
        }
        return false
    }
    static func isJSON5Whitespace(_ character: Byte) -> Bool {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.isJSON5Whitespace(byte)
        }
        return false
    }
    static func isControlCharacter(_ character: Byte) -> Bool {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.isControlCharacter(byte)
        }
        return false
    }
    static func hexByte(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.hexByte(byte)
        }
        return nil
    }
    static func minus(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.minus(byte)
        }
        return nil
    }
    static func plus(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.plus(byte)
        }
        return nil
    }
    static func dot(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.dot(byte)
        }
        return nil
    }
    static func e(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.e(byte)
        }
        return nil
    }
    static func p(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.p(byte)
        }
        return nil
    }
    static func x(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.x(byte)
        }
        return nil
    }
    static func zero(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.zero(byte)
        }
        return nil
    }
    static func digit(_ character: Byte) -> UInt8? {
        if let byte = self.getByte(from: character) {
            return NSKOptionsUTF8.digit(byte)
        }
        return nil
    }
}

struct NSKOptionsUTF16: NSKWideOptions {
    private init() {}
    typealias CodePoint = UTF16
    
    static let newLine          : Byte = Byte(NSKOptionsUTF8.newLine)
    static let carriageReturn   : Byte = Byte(NSKOptionsUTF8.carriageReturn)
    static let tab              : Byte = Byte(NSKOptionsUTF8.tab)
    static let space            : Byte = Byte(NSKOptionsUTF8.space)
    static let formFeed         : Byte = Byte(NSKOptionsUTF8.formFeed)
    static let nbSpace          : Byte = Byte(NSKOptionsUTF8.nbSpace)
    static let beginArray       : Byte = Byte(NSKOptionsUTF8.beginArray)
    static let endArray         : Byte = Byte(NSKOptionsUTF8.endArray)
    static let beginDictionary  : Byte = Byte(NSKOptionsUTF8.beginDictionary)
    static let endDictionary    : Byte = Byte(NSKOptionsUTF8.endDictionary)
    static let colon            : Byte = Byte(NSKOptionsUTF8.colon)
    static let quotationMark    : Byte = Byte(NSKOptionsUTF8.quotationMark)
    static let apostrophe       : Byte = Byte(NSKOptionsUTF8.apostrophe)
    static let slash            : Byte = Byte(NSKOptionsUTF8.slash)
    static let backSlash        : Byte = Byte(NSKOptionsUTF8.backSlash)
    static let comma            : Byte = Byte(NSKOptionsUTF8.comma)
    static let b                : Byte = Byte(NSKOptionsUTF8.b)
    static let n                : Byte = Byte(NSKOptionsUTF8.n)
    static let t                : Byte = Byte(NSKOptionsUTF8.t)
    static let r                : Byte = Byte(NSKOptionsUTF8.r)
    static let u                : Byte = Byte(NSKOptionsUTF8.u)
    static let e                : Byte = Byte(NSKOptionsUTF8.e)
    static let f                : Byte = Byte(NSKOptionsUTF8.f)
    static let a                : Byte = Byte(NSKOptionsUTF8.a)
    static let l                : Byte = Byte(NSKOptionsUTF8.l)
    static let s                : Byte = Byte(NSKOptionsUTF8.s)
    static let x                : Byte = Byte(NSKOptionsUTF8.x)
    static let star             : Byte = Byte(NSKOptionsUTF8.star)
    static let I                : Byte = Byte(NSKOptionsUTF8.I)
    static let i                : Byte = Byte(NSKOptionsUTF8.i)
    static let y                : Byte = Byte(NSKOptionsUTF8.y)
    static let N                : Byte = Byte(NSKOptionsUTF8.N)
}

struct NSKOptionsUTF32: NSKWideOptions {
    private init() {}
    typealias CodePoint = UTF32
    
    static let newLine          : Byte = Byte(NSKOptionsUTF8.newLine)
    static let carriageReturn   : Byte = Byte(NSKOptionsUTF8.carriageReturn)
    static let tab              : Byte = Byte(NSKOptionsUTF8.tab)
    static let space            : Byte = Byte(NSKOptionsUTF8.space)
    static let formFeed         : Byte = Byte(NSKOptionsUTF8.formFeed)
    static let nbSpace          : Byte = Byte(NSKOptionsUTF8.nbSpace)
    static let beginArray       : Byte = Byte(NSKOptionsUTF8.beginArray)
    static let endArray         : Byte = Byte(NSKOptionsUTF8.endArray)
    static let beginDictionary  : Byte = Byte(NSKOptionsUTF8.beginDictionary)
    static let endDictionary    : Byte = Byte(NSKOptionsUTF8.endDictionary)
    static let colon            : Byte = Byte(NSKOptionsUTF8.colon)
    static let quotationMark    : Byte = Byte(NSKOptionsUTF8.quotationMark)
    static let apostrophe       : Byte = Byte(NSKOptionsUTF8.apostrophe)
    static let slash            : Byte = Byte(NSKOptionsUTF8.slash)
    static let backSlash        : Byte = Byte(NSKOptionsUTF8.backSlash)
    static let comma            : Byte = Byte(NSKOptionsUTF8.comma)
    static let b                : Byte = Byte(NSKOptionsUTF8.b)
    static let n                : Byte = Byte(NSKOptionsUTF8.n)
    static let t                : Byte = Byte(NSKOptionsUTF8.t)
    static let r                : Byte = Byte(NSKOptionsUTF8.r)
    static let u                : Byte = Byte(NSKOptionsUTF8.u)
    static let e                : Byte = Byte(NSKOptionsUTF8.e)
    static let f                : Byte = Byte(NSKOptionsUTF8.f)
    static let a                : Byte = Byte(NSKOptionsUTF8.a)
    static let l                : Byte = Byte(NSKOptionsUTF8.l)
    static let s                : Byte = Byte(NSKOptionsUTF8.s)
    static let x                : Byte = Byte(NSKOptionsUTF8.x)
    static let star             : Byte = Byte(NSKOptionsUTF8.star)
    static let I                : Byte = Byte(NSKOptionsUTF8.I)
    static let i                : Byte = Byte(NSKOptionsUTF8.i)
    static let y                : Byte = Byte(NSKOptionsUTF8.y)
    static let N                : Byte = Byte(NSKOptionsUTF8.N)
}
