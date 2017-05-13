//
//  NSKDataIterator.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 15.10.16.
//  Copyright © 2016 NSSimpleApps. All rights reserved.
//

import Foundation

internal extension UnsignedInteger {
    
    internal var isHex: Bool {
        
        return self.isDigit
            || (self >= 0x41 && self <= 0x46)
            || (self >= 0x61 && self <= 0x66)
    }
    
    internal var isZero: Bool {
        
        return self == 0x30
    }
    
    internal var isDigit: Bool {
        
        return self >= 0x30 && self <= 0x39
    }
    
    internal var isNonZeroDigit: Bool {
        
        return self >= 0x31 && self <= 0x39
    }
    
    internal var isControlCharacter: Bool {
        
        return self >= 0x00 && self <= 0x1F
    }
}


internal extension Data {
    
    internal var parseASCIIEncoding: String.Encoding {
        
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
                break
            }
            
        } else if count >= 2 {
            
            switch (self[0], self[1]) {
                
            case (0, asciiRange):
                return .utf16BigEndian
                
            case (asciiRange, 0):
                return .utf16LittleEndian
                
            default:
                break
            }
        }
        
        return .utf8
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
                return nil
            }
        }
        return nil
    }
    
    internal func buffer<T: UnsignedInteger>(offset: Int) -> UnsafeBufferPointer<T> {
        
        let stride = MemoryLayout<T>.stride
        
        return self.withUnsafeBytes { (bytes: UnsafePointer<T>) -> UnsafeBufferPointer<T> in
            
            return UnsafeBufferPointer(start: bytes.advanced(by: offset/stride), count: (self.count - offset)/stride)
        }
    }
}

internal extension UnsafePointer where Pointee: UnsignedInteger {
    
    internal func parseBOM(length: Int) -> (encoding: String.Encoding, skipLength: Int)? {
        
        if length >= 2 {
            
            switch (self[0], self[1]) {
            
            case (0xEF, 0xBB):
                
                if length >= 3 && self[2] == 0xBF {
                    
                    return (.utf8, 3)
                }
                
            case (0x00, 0x00):
                
                if length >= 4 && self[2] == 0xFE && self[3] == 0xFF {
                    
                    return (.utf32BigEndian, 4)
                }
                
            case (0xFF, 0xFE):
                
                if length >= 4 && self[2] == 0 && self[3] == 0 {
                    
                    return (.utf32LittleEndian, 4)
                    
                } else {
                    
                    return (.utf16LittleEndian, 2)
                }
                
            case (0xFE, 0xFF):
                
                return (.utf16BigEndian, 2)
                
            default:
                break
            }
        }
        return nil
    }
}
