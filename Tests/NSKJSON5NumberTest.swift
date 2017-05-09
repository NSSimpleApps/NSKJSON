//
//  NSKJSON5NumberTest.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 16.04.17.
//
//

import XCTest
@testable import NSKJSON

class NSKJSON5NumberTest: XCTestCase {
    
    func testCorrectPlainIntegers() {
        
        for integer in correctPlainIntegerCases {
            
            let data = integer.0.data(using: .utf8)!
            
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            
            do {
                
                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKPlainJSONTerminator.self)
                
                XCTAssertEqual(length, integer.2)
                XCTAssertTrue(number is Int)
                XCTAssertEqual(number as! Int, integer.1)
                
            } catch {
                
                print(error)
                
                XCTFail()
            }
        }
    }
    
    func testCorrectPlainDoubles() {
        
        for correctPlainDoubleCase in correctPlainDoubleCases {
            
            let data = correctPlainDoubleCase.data(using: .utf8)!
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            
            do {
                
                print("TESTING:", correctPlainDoubleCase)
                
                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKJSON5Terminator.self)
                
                XCTAssertEqual(length, correctPlainDoubleCase.characters.count)
                XCTAssertTrue(number is Double)
                XCTAssertEqual(number as! Double, Double(correctPlainDoubleCase)!)
                
            } catch {
                
                print("FAILED AT:", correctPlainDoubleCase, error)
                
                XCTFail()
            }
        }
    }
    
    func testCorrectJSON5Integers() {
        
        for correctJSON5IntegerCase in correctJSON5IntegerCases {
            
            do {
                
                print("TESTING:", correctJSON5IntegerCase.0)
                
                let data = correctJSON5IntegerCase.0.data(using: .utf8)!
                let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
                
                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKJSON5Terminator.self)
                
                XCTAssertEqual(length, correctJSON5IntegerCase.1)
                XCTAssertTrue(number is Int)
                XCTAssertEqual(number as! Int, correctJSON5IntegerCase.2)
                
            } catch {
                
                print("FAILED AT:", correctJSON5IntegerCase.0, error)
                
                XCTFail()
            }
        }
    }
    
    func testCorrectJSON5Doubles() {
        
        for correctJSON5DoubleCase in correctJSON5DoubleCases {
            
            do {
                
                print("TESTING:", correctJSON5DoubleCase)
                
                let data = correctJSON5DoubleCase.data(using: .utf8)!
                let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
                
                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKJSON5Terminator.self)
                
                XCTAssertEqual(length, correctJSON5DoubleCase.characters.count)
                XCTAssertTrue(number is Double)
                XCTAssertEqual(number as! Double, Double(correctJSON5DoubleCase)!)
                
            } catch {
                
                print("FAILED AT:", correctJSON5DoubleCase, error)
                
                XCTFail()
            }
        }
    }
    
    func testIncorrectJSON5Doubles() {
        
        for incorrectJSON5Case in incorrectJSON5Cases {
            
            print("TESTING:", incorrectJSON5Case)
            
            let data = incorrectJSON5Case.data(using: .utf8)!
            let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
            
            XCTAssertThrowsError(try NSKPlainNumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKPlainJSONTerminator.self), "FAILED AT \(incorrectJSON5Case)", { (error) in
                
                //                let e = error as NSError
                //
                //                print(incorrectPlainCase, e.userInfo["NSDebugDescription"]!)
            })
        }
    }
    
    func testNan() {
        
        for nan in [("NaN", 3), ("+NaN", 4), ("-NaN", 4)] {
            
            do {
                
                print("TESTING:", nan.0)
                
                let data = nan.0.data(using: .utf8)!
                let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
                
                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKJSON5Terminator.self)
                
                XCTAssertEqual(length, nan.1)
                XCTAssertTrue(number is Double)
                XCTAssertTrue((number as! Double).isNaN)
                
            } catch {
                
                print("FAILED AT:", nan.0, error)
                
                XCTFail()
            }
        }
    }
    
    func testMisc() {
        
        //let str = "+0x1.91eb85P+1"
        //let str = "0x185P+1"
        let strs = ["-.512e+10"]
        for str in strs {
            
            do {
                
                print("TESTING:", str)
                
                let data = str.data(using: .utf8)!
                let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
                
                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKJSON5Terminator.self)
                
                print(number, Double(str)!)
                
                XCTAssertEqual(length, str.characters.count)
                XCTAssertTrue(number is Double)
                XCTAssertEqual(number as! Double, Double(str)!)
                
            } catch {
                
                print("FAILED AT:", str, error)
                
                XCTFail()
            }
        }
    }
}
