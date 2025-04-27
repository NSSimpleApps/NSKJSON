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
            let str = integer.0
            let data = str.data(using: .utf8)!
            print("TESTING: ", str)
            do {
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
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
                print(error)
                XCTFail("FAILED AT: \(str)")
            }
        }
    }
    
    func testCorrectPlainDoubles() {
        for correctPlainDoubleCase in correctPlainDoubleCases {
            let data = correctPlainDoubleCase.data(using: .utf8)!
            
            do {
                print("TESTING:", correctPlainDoubleCase)
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
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
                print(error)
                XCTFail()
            }
        }
    }
    
    func testCorrectJSON5Integers() {
        for integer in correctJSON5IntegerCases {
            let str = integer.0
            let data = str.data(using: .utf8)!
            
            do {
                print("TESTING:", integer.0)
                
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                }) {
                    XCTAssertEqual(length, integer.1)
                    XCTAssertTrue(number is Int)
                    XCTAssertEqual(number as! Int, integer.2)
                } else {
                    XCTFail("NOT A NUMBER: " + str)
                }
            } catch {
                print("FAILED AT:", str, error)
                XCTFail()
            }
        }
    }
    
    func testCorrectJSON5Doubles() {
        for correctJSON5DoubleCase in correctJSON5DoubleCases {
            let data = correctJSON5DoubleCase.data(using: .utf8)!
            
            do {
                print("TESTING:", correctJSON5DoubleCase)
                
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                }) {
                    XCTAssertEqual(length, correctJSON5DoubleCase.count)
                    XCTAssertTrue(number is Double)
                    XCTAssertEqual(number as! Double, Double(correctJSON5DoubleCase)!)
                } else {
                    XCTFail("NOT A NUMBER: " + correctJSON5DoubleCase)
                }
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
            XCTAssertThrowsError(try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                block: { (result) -> (number: Any, length: Int)? in
                switch result {
                case .success(let buffer):
                    return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                case .failure(let error):
                    throw error
                }
            }), "FAILED AT \(incorrectJSON5Case)", { (error) in
                //let e = error as NSError
                //print(incorrectPlainCase, e.userInfo["NSDebugDescription"]!)
            })
        }
    }
    
    func testInfinity() {
        let tests: [(String, Int)] = [("Infinity", 8), ("+Infinity", 9), ("-Infinity", 9)]
        
        for test in tests {
            do {
                print("TESTING:", test.0)
                let data = test.0.data(using: .utf8)!
                
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                }) {
                    XCTAssertEqual(length, test.1)
                    XCTAssertTrue(number is Double)
                    XCTAssertTrue((number as! Double).isInfinite)
                } else {
                    print("FAILED AT:", test.0)
                    XCTFail()
                }
            } catch {
                print("FAILED AT:", test.0, error)
                XCTFail()
            }
        }
    }
    
    func testNaN() {
        let tests: [(String, Int)] = [("NaN", 3), ("+NaN", 4), ("-NaN", 4)]
        
        for test in tests {
            do {
                print("TESTING:", test.0)
                let data = test.0.data(using: .utf8)!
                
                if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                         block: { (result) -> (number: Any, length: Int)? in
                    switch result {
                    case .success(let buffer):
                        return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                    case .failure(let error):
                        throw error
                    }
                }) {
                    XCTAssertEqual(length, test.1)
                    XCTAssertTrue(number is Double)
                    XCTAssertTrue((number as! Double).isNaN)
                } else {
                    print("FAILED AT:", test.0)
                    XCTFail()
                }
            } catch {
                print("FAILED AT:", test.0, error)
                XCTFail()
            }
        }
    }
    
    func testMisc() {
        let str = "1.23e+111"
        
        do {
            print("TESTING:", str)
            let data = str.data(using: .utf8)!
            
            if let (number, length) = try NSKJSON.OptionsUTF8.buffer(data: data, offset: 0, isBigEndian: isBigEndian,
                                                                     block: { (result) -> (number: Any, length: Int)? in
                switch result {
                case .success(let buffer):
                    return try NSKJSON5NumberParser<NSKJSON.OptionsUTF8>.parseNumber(buffer: buffer, from: 0)
                case .failure(let error):
                    throw error
                }
            }) {
                print(number, length)
                XCTAssertEqual(length, str.count)
                XCTAssertTrue(number is Double)
                XCTAssertEqual(number as! Double, Double(str)!)
            } else {
                print("NIL")
            }
        } catch {
            print("FAILED AT:", str, error)
            XCTFail()
        }
    }
}
