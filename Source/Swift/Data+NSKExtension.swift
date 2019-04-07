//
//  NSKDataIterator.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 15.10.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

extension Data {
    var parseASCIIEncoding: String.Encoding {
        let count = self.count
        let asciiRange: CountableClosedRange<UInt8> = 0x01...0x7F
        
        if count >= 4 {
            switch (self[0], self[1], self[2], self[3]) {
            case (0, 0, 0, asciiRange):
                return .utf32BigEndian
            case (asciiRange, 0, 0, 0):
                return .utf32LittleEndian
            case (0, asciiRange, 0, asciiRange):
                return .utf16BigEndian
            case (asciiRange, 0, asciiRange, 0):
                return .utf16LittleEndian
            default:
                return .utf8
            }
            
        } else if count >= 2 {
            switch (self[0], self[1]) {
            case (0, asciiRange):
                return .utf16BigEndian
            case (asciiRange, 0):
                return .utf16LittleEndian
            default:
                return .utf8
            }
        } else {
            return .utf8
        }
    }
    
    func parseBOM() -> (encoding: String.Encoding, offset: Int)? {
        let count = self.count
        
        if count >= 2 {
            switch (self[0], self[1]) {
            case (0xEF, 0xBB):
                if count >= 3 && self[2] == 0xBF {
                    return (.utf8, 3)
                }
            case (0x00, 0x00):
                if count >= 4 && self[2] == 0xFE && self[3] == 0xFF {
                    return (.utf32BigEndian, 4)
                }
            case (0xFF, 0xFE):
                if count >= 4 && self[2] == 0 && self[3] == 0 {
                    return (.utf32LittleEndian, 4)
                }
                return (.utf16LittleEndian, 2)
            case (0xFE, 0xFF):
                return (.utf16BigEndian, 2)
            default:
                break
            }
        }
        return nil
    }
}
