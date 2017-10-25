//
//  NSKOptions.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 12.02.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import Foundation

internal final class NSKOptions<T: UnsignedInteger> {
    internal let encoding: String.Encoding
    internal let trailingComma: Bool
    internal let transformer: (UInt8) -> T
    
    internal init(encoding: String.Encoding, trailingComma: Bool, transformer: @escaping (UInt8) -> T) {
        self.encoding = encoding
        self.trailingComma = trailingComma
        self.transformer = transformer
    }
    
    // \n
    private(set) internal lazy var newLine: T = { self.transformer(0x0A) }()
    
    // \r
    private(set) internal lazy var carriageReturn: T = { self.transformer(0x0D) }()
    
    private(set) internal lazy var whitespaces: Set<T> = {
        return [self.transformer(0x09), // horizontal tab
                self.newLine, // new line
                self.carriageReturn, // carriage return
                self.transformer(0x20) // space
        ] }()
    
    // whitespaces +
    private(set) internal lazy var json5Whitespaces: Set<T> = {
        return self.whitespaces.union([self.transformer(0x0C), // form feed
                                       self.transformer(0xA0) // non-breaking space
            ]) }()
    
    // [
    private(set) internal lazy var beginArray: T = { self.transformer(0x5B) }()
    
    // ]
    private(set) internal lazy var endArray: T = { self.transformer(0x5D) }()
    
    // {
    private(set) internal lazy var beginDictionary: T = { self.transformer(0x7B) }()
    
    // }
    private(set) internal lazy var endDictionary: T = { self.transformer(0x7D) }()
    
    // :
    private(set) internal lazy var colon: T = { self.transformer(0x3A) }()
    
    // "
    private(set) internal lazy var quotationMark: T = { self.transformer(0x22) }()
    
    // '
    private(set) internal lazy var apostrophe: T = { self.transformer(0x27) }()
    
    // /
    private(set) internal lazy var slash: T = { self.transformer(0x2F) }()
    
    // \
    private(set) internal lazy var backSlash: T = { self.transformer(0x5C) }()
    
    // ,
    private(set) internal lazy var comma: T = { self.transformer(0x2C) }()
    
    // b
    private(set) internal lazy var b: T = { self.transformer(0x62) }()
    
    // n
    private(set) internal lazy var n: T = { self.transformer(0x6E) }()
    
    // t
    private(set) internal lazy var t: T = { self.transformer(0x74) }()
    
    // r
    private(set) internal lazy var r: T = { self.transformer(0x72) }()
    
    // u
    private(set) internal lazy var u: T = { self.transformer(0x75) }()
    
    // e
    private(set) internal lazy var e: T = { self.transformer(0x65) }()
    
    // f
    private(set) internal lazy var f: T = { self.transformer(0x66) }()
    
    // a
    private(set) internal lazy var a: T = { self.transformer(0x61) }()
    
    // l
    private(set) internal lazy var l: T = { self.transformer(0x6C) }()
    
    // s
    private(set) internal lazy var s: T = { self.transformer(0x73) }()
    
    // -
    private(set) internal lazy var minus: T = { self.transformer(0x2D) }()
    
    // +
    private(set) internal lazy var plus: T = { self.transformer(0x2B) }()
    
    // .
    private(set) internal lazy var dot: T = { self.transformer(0x2E) }()
    
    // E
    private(set) internal lazy var E: T = { self.transformer(0x45) }()
    
    // P
    private(set) internal lazy var P: T = { self.transformer(0x50) }()
    
    // p
    private(set) internal lazy var p: T = { self.transformer(0x70) }()
    
    // x
    private(set) internal lazy var x: T = { self.transformer(0x78) }()
    
    // X
    private(set) internal lazy var X: T = { self.transformer(0x58) }()
    
    // *
    private(set) internal lazy var star: T = { self.transformer(0x2A) }()
    
    // I
    private(set) internal lazy var I: T = { self.transformer(0x49) }()
    
    // i
    private(set) internal lazy var i: T = { self.transformer(0x69) }()
    
    // y
    private(set) internal lazy var y: T = { self.transformer(0x79) }()
    
    // N
    private(set) internal lazy var N: T = { self.transformer(0x4E) }()
    
    // 0x1F
    private lazy var controlCharacters: Set<T> = {
        return Set((UInt8(0x00)...UInt8(0x1F)).map(self.transformer))
    }()
    
    // [a-f,A-F]
    private lazy var hexCharactes: Set<T> = {
        let capitalAF = Set((UInt8(0x41)...UInt8(0x46)).map(self.transformer))
        let af = Set((UInt8(0x61)...UInt8(0x66)).map(self.transformer))
        
        return capitalAF.union(af)
    }()
    
    // 0
    private lazy var zero: T = { self.transformer(0x30) }()
    
    // 9
    private lazy var digitCharacters: Set<T> = {
        return Set((UInt8(0x30)...UInt8(0x39)).map(self.transformer))
    }()
    
    internal func isControlCharacter(_ character: T) -> Bool {
        return self.controlCharacters.contains(character)
    }
    
    internal func isHex(_ character: T) -> Bool {
        return self.isDigit(character) || self.hexCharactes.contains(character)
    }
    
    internal func isZero(_ character: T) -> Bool {
        return character == self.zero
    }
    
    internal func isDigit(_ character: T) -> Bool {
        return self.digitCharacters.contains(character)
    }
    
    internal func isDigitButZero(_ character: T) -> Bool {
        return self.isDigit(character) && character != self.zero
    }
    
    private func string(array: [T]) -> String? {
        return array.withUnsafeBytes { (unsafeRawBufferPointer) -> String? in
            return String(bytes: unsafeRawBufferPointer, encoding: self.encoding)
        }
    }
    
    internal func string<S: Sequence>(bytes: S) -> String? where S.Iterator.Element == T {
        return self.string(array: Array(bytes))
    }
    
    internal func string(codePoint: T) -> String {
        return self.string(array: [codePoint]) ?? "\u{FFFD}"
    }
}
