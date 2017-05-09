//
//  NSKPlainNumberTest.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 09.04.17.
//  Copyright © 2017 NSSimpleApps. All rights reserved.
//

import XCTest
@testable import NSKJSON

class NSKPlainNumberTest: XCTestCase {
    
    func testIntegers() {
        
        for integer in correctPlainIntegerCases {
            
            print("TESTING:", integer.0)
            
            let data = integer.0.data(using: .utf8)!
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            
            do {
                
                let (number, length) = try NSKPlainNumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKPlainJSONTerminator.self)
                
                XCTAssertEqual(length, integer.2)
                XCTAssertTrue(number is Int)
                XCTAssertEqual(number as! Int, integer.1)
                
            } catch {
                
                print("FAILED AT:", integer, error)
                
                XCTFail()
            }
        }
    }
    
    func testDoubles() {
        
        for correctPlainDoubleCase in correctPlainDoubleCases {
            
            print("TESTING:", correctPlainDoubleCase)
            
            let data = correctPlainDoubleCase.data(using: .utf8)!
            
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            
            do {
                
                let (number, length) = try NSKPlainNumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKPlainJSONTerminator.self)
                
                XCTAssertEqual(length, correctPlainDoubleCase.characters.count)
                XCTAssertTrue(number is Double)
                XCTAssertEqual(number as! Double, Double(correctPlainDoubleCase)!)
                
            } catch {
                
                print("FAILED AT:", correctPlainDoubleCase, error)
                
                XCTFail()
            }
        }
    }
    
    func testErrors() {
        
        for incorrectPlainCase in incorrectPlainCases {
            
            print("TESTING:", incorrectPlainCase)
            
            let data = incorrectPlainCase.data(using: .utf8)!
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            
            XCTAssertThrowsError(try NSKPlainNumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKPlainJSONTerminator.self), "FAILED AT \(incorrectPlainCase)", { (error) in
                
//                let e = error as NSError
//                
//                print(incorrectPlainCase, e.userInfo["NSDebugDescription"]!)
            })
        }
    }
    
    func testMisc() {
        
        let str = "123"
        let data = str.data(using: .utf8)!
        let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
        
        do {
            
            let (number, length) = try NSKPlainNumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKPlainJSONTerminator.self)
            
            XCTAssertTrue(number is Int)
            XCTAssertEqual(number as! Int, 123)
            XCTAssertEqual(length, 3)
            
        } catch {
            
            print(error)
            
            XCTFail()
        }
    }
}
