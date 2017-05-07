//
//  NSKJSON.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 11.12.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

public let NSKNestingLevel = 100

public enum NSKJSONVersion: Int {
    
    case plain
    case json5
}

open class NSKJSON {
    
    private init() {}
    
    open class func jsonObject(with data: Data, version: NSKJSONVersion) throws -> Any {
        
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
            let options = NSKOptions(encoding: encoding)
            
            switch version {
                
            case .plain:
                return try NSKPlainParser(options: options).parseObject(buffer: buffer)
                
            case .json5:
                return try NSKJSON5Parser(options: options).parseObject(buffer: buffer)
            }
            
        } else {
            
            throw NSKJSONError.error(description: "\(encoding) is not supported yet.")
        }
    }
}
