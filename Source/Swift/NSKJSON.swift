//
//  NSKJSON.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 11.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

public let NSKNestingLevel = 100


open class NSKJSON {
    public enum Version: Int {
        case plain
        case json5
    }
    
    private init() {}
    
    open class func jsonObject(with data: Data, version: NSKJSON.Version) throws -> Any {
        let encoding: String.Encoding
        let offset: Int
        
        if let bom = data.parseBOM() {
            encoding = bom.encoding
            offset = bom.offset
            
        } else {
            encoding = data.parseASCIIEncoding
            offset = 0
        }
        
        if encoding == .utf8 {
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: offset)
            
            return try self.parser(encoding: encoding, version: version, transformer: { $0 }).parseObject(buffer: buffer)
            
        } else if encoding == .utf16BigEndian {
            let buffer: UnsafeBufferPointer<UInt16> = data.buffer(offset: offset)
            
            return try self.parser(encoding: encoding, version: version, transformer: { UInt16($0).bigEndian }).parseObject(buffer: buffer)
            
        } else if encoding == .utf16LittleEndian {
            let buffer: UnsafeBufferPointer<UInt16> = data.buffer(offset: offset)
            
            return try self.parser(encoding: encoding, version: version, transformer: { UInt16($0).littleEndian }).parseObject(buffer: buffer)
            
        } else if encoding == .utf32BigEndian {
            let buffer: UnsafeBufferPointer<UInt32> = data.buffer(offset: offset)
            
            return try self.parser(encoding: encoding, version: version, transformer: { UInt32($0).bigEndian }).parseObject(buffer: buffer)
            
        } else if encoding == .utf32LittleEndian {
            let buffer: UnsafeBufferPointer<UInt32> = data.buffer(offset: offset)
            
            return try self.parser(encoding: encoding, version: version, transformer: { UInt32($0).littleEndian }).parseObject(buffer: buffer)
            
        } else {
            throw NSKJSONError.error(description: "\(encoding) is not supported yet.")
        }
    }
    
    private static func parser<Byte: UnsignedInteger>(encoding: String.Encoding, version: Version, transformer: @escaping (UInt8) -> Byte) -> NSKPlainParser<UnsafeBufferPointer<Byte>> {
        
        let options = NSKOptions(encoding: encoding,
                                 trailingComma: version == .json5,
                                 transformer: transformer)
        
        switch version {
        case .plain:
            return NSKPlainParser<UnsafeBufferPointer<Byte>>(options: options)
        case .json5:
            return NSKJSON5Parser<UnsafeBufferPointer<Byte>>(options: options)
        }
    }
}




