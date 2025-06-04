//
//  NSKJSON.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 11.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

public final class NSKJSON: Sendable {
    @frozen
    public enum Version: Int, Sendable {
        case plain
        case json5
    }
    public static let nestingLevel = 100
    
    private init() {}
    
    public static func jsonObject(with data: Data, version: Version) throws -> Any {
        let encoding: String.Encoding
        let offset: Int
        
        if let bom = data.parseBOM() {
            encoding = bom.encoding
            offset = bom.offset
            
        } else {
            encoding = data.parseASCIIEncoding
            offset = 0
        }
        
        switch encoding {
        case .utf8:
            return try NSKOptionsUTF8.utf8Buffer(data: data, offset: offset,
                                                 block: { (buffer) -> Any in
                switch version {
                case .plain:
                    return try NSKPlainParser<NSKOptionsUTF8>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<NSKOptionsUTF8>.parseObject(buffer: buffer)
                }
            })
        case .utf16BigEndian, .utf16LittleEndian:
            return try NSKOptionsUTF16.buffer(data: data, offset: offset, isBigEndian: encoding == .utf16BigEndian,
                                              block: { (result) -> Any in
                let buffer = try result.get()
                switch version {
                case .plain:
                    return try NSKPlainParser<NSKOptionsUTF16>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<NSKOptionsUTF16>.parseObject(buffer: buffer)
                }
            })
        case .utf32BigEndian, .utf32LittleEndian:
            return try NSKOptionsUTF32.buffer(data: data, offset: offset, isBigEndian: encoding == .utf32BigEndian,
                                              block: { (result) -> Any in
                let buffer = try result.get()
                switch version {
                case .plain:
                    return try NSKPlainParser<NSKOptionsUTF32>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<NSKOptionsUTF32>.parseObject(buffer: buffer)
                }
            })
        default:
            throw NSKJSONError.error(description: "\(encoding) is not supported yet.")
        }
    }
    
    public static func jsonObject<S: StringProtocol>(fromString string: S, version: Version) throws -> Any {
        let count = string.utf8.count
        
        return try string.withCString { (start) -> Any in
            try UnsafeBufferPointer(start: start, count: count).withMemoryRebound(to: UInt8.self, { (buffer) -> Any in
                switch version {
                case .plain:
                    return try NSKPlainParser<NSKOptionsUTF8>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<NSKOptionsUTF8>.parseObject(buffer: buffer)
                }
            })
        }
    }
}
