//
//  NSKJSON.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 11.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

public class NSKJSON {
    @frozen
    public enum Version: Int {
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
            return try OptionsUTF8.utf8Buffer(data: data, offset: offset,
                                          block: { (buffer) -> Any in
                switch version {
                case .plain:
                    return try NSKPlainParser<OptionsUTF8>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<OptionsUTF8>.parseObject(buffer: buffer)
                }
            })
        case .utf16BigEndian, .utf16LittleEndian:
            return try OptionsUTF16.buffer(data: data, offset: offset, isBigEndian: encoding == .utf16BigEndian,
                                           block: { (result) -> Any in
                let buffer = try result.get()
                switch version {
                case .plain:
                    return try NSKPlainParser<OptionsUTF16>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<OptionsUTF16>.parseObject(buffer: buffer)
                }
            })
        case .utf32BigEndian, .utf32LittleEndian:
            return try OptionsUTF32.buffer(data: data, offset: offset, isBigEndian: encoding == .utf32BigEndian,
                                           block: { (result) -> Any in
                let buffer = try result.get()
                switch version {
                case .plain:
                    return try NSKPlainParser<OptionsUTF32>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<OptionsUTF32>.parseObject(buffer: buffer)
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
                    return try NSKPlainParser<OptionsUTF8>.parseObject(buffer: buffer)
                case .json5:
                    return try NSKJSON5Parser<OptionsUTF8>.parseObject(buffer: buffer)
                }
            })
        }
    }
}
