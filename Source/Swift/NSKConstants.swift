//
//  NSKConstants.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 16.10.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

internal let NSKNewLine: UInt8     = 0x0A // \n

internal let NSKWhitespaces: Set<UInt8> = [
0x09, // Horizontal tab
NSKNewLine, // Line feed or New line
0x0D, // Carriage return
0x20, // Space
]

internal let NSKBeginArray: UInt8     = 0x5B // [
internal let NSKEndArray: UInt8       = 0x5D // ]

internal let NSKBeginDictionary: UInt8    = 0x7B // {
internal let NSKEndDictionary: UInt8      = 0x7D // }

internal let NSKColon: UInt8  = 0x3A // :

internal let NSKQuotationMark: UInt8  = 0x22 // "
internal let NSKSingleQuotationMark: UInt8  = 0x27 // '

internal let NSKSlash: UInt8         = 0x2F // /
internal let NSKBackSlash: UInt8         = 0x5C // \

internal let NSKComma: UInt8         = 0x2C // ,

internal let NSKb: UInt8 = 0x62 // b
internal let NSKn: UInt8 = 0x6E // n

internal let NSKt: UInt8 = 0x74 // t
internal let NSKr: UInt8 = 0x72 // r
internal let NSKu: UInt8 = 0x75 // u
internal let NSKe: UInt8 = 0x65 // e

internal let NSKf: UInt8 = 0x66 // f
internal let NSKa: UInt8 = 0x61 // a
internal let NSKl: UInt8 = 0x6C // l
internal let NSKs: UInt8 = 0x73 // s

internal let NSKMinus: UInt8 = 0x2D // -
internal let NSKPlus: UInt8 = 0x2B // +
internal let NSKDot: UInt8 = 0x2E // .
internal let NSKE: UInt8 = 0x45 // E

internal let NSKP: UInt8 = 0x50 // P
internal let NSKp: UInt8 = 0x70 // p
internal let NSKx: UInt8 = 0x78 // x
internal let NSKStar: UInt8 = 0x2A // *

internal let NSKI: UInt8 = 0x49 // I
internal let NSKi: UInt8 = 0x69 // i
internal let NSKy: UInt8 = 0x79 // y

internal let NSKN: UInt8 = 0x4E // N

