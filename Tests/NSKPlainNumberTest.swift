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
    
    func testMisc() {
        let str = "[-1x]"
        let data = str.data(using: .utf8)!
        
        print("TESTING:", str)
        do {
            if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 1, isBigEndian: isBigEndian,
                                                                     block: { (result) -> (number: Any, length: Int)? in
                switch result {
                case .success(let buffer):
                    return try NSKPlainNumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                case .failure(let error):
                    throw error
                }
            }) {
                XCTAssertEqual(length, 2)
                XCTAssertTrue(number is Int)
                XCTAssertEqual(number as! Int, -1)
            } else {
                XCTFail("NOT A NUMBER: " + str)
            }
        } catch {
            print("FAILED AT:", error)
            XCTFail()
        }
    }
    
    func testIntegers() {
        for integer in correctPlainIntegerCases {
            let str = integer.0
            let data = str.data(using: .utf8)!
            
            print("TESTING:", str)
            do {
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKPlainNumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                }) {
                    XCTAssertEqual(length, integer.2)
                    XCTAssertTrue(number is Int)
                    XCTAssertEqual(number as! Int, integer.1)
                } else {
                    XCTFail("NOT A NUMBER: " + str)
                }
            } catch {
                print("FAILED AT:", error)
                XCTFail()
            }
        }
    }
    
    func testDoubles() {
        for correctPlainDoubleCase in correctPlainDoubleCases {
            print("TESTING:", correctPlainDoubleCase)
            
            let data = correctPlainDoubleCase.data(using: .utf8)!
            
            do {
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKPlainNumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                }) {
                    XCTAssertEqual(length, correctPlainDoubleCase.count)
                    XCTAssertTrue(number is Double)
                    XCTAssertEqual(number as! Double, Double(correctPlainDoubleCase)!)
                } else {
                    XCTFail("NOT A NUMBER: " + correctPlainDoubleCase)
                }
            } catch {
                print("FAILED AT:", correctPlainDoubleCase, error)
                XCTFail()
            }
        }
    }
    
    func testNils() {
        for nilCase in nilCases {
            print("TESTING:", nilCase)
            let data = nilCase.data(using: .utf8)!
            
            do {
                let result = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                            block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKPlainNumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        print("FAILED AT:", error)
                        XCTFail()
                        return nil
                    }
                })
                XCTAssertNil(result)
            } catch {
                print("FAILED AT:", nilCase, error)
                XCTFail()
            }
        }
    }
    
    func testErrors() {
        for incorrectPlainCase in incorrectPlainCases {
            print("TESTING:", incorrectPlainCase)
            let data = incorrectPlainCase.data(using: .utf8)!
            
            XCTAssertThrowsError(try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                block: { (result) -> (number: Any, length: Int)? in
                switch result {
                case .success(let buffer):
                    return try NSKPlainNumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                case .failure(let error):
                    throw error
                }
            }), "FAILED AT \(incorrectPlainCase)") { (error) in
                
            }
        }
    }
}
