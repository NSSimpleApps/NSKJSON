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
            
            do {
                
                let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
                let terminator =
                NSKPlainJSONTerminator(whiteSpaces: options.whitespaces,
                                       endArray: options.endArray,
                                       endDictionary: options.endDictionary,
                                       comma: options.comma)
                
                let parser = NSKPlainNumberParser<Data>(options: options)
                
                let (number, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return terminator.contains(buffer: data, at: index)
                })
                
                XCTAssertEqual(length, integer.2)
                XCTAssertTrue(number is Int)
                XCTAssertEqual(number as! Int, integer.1)
                
            } catch {
                
                print("FAILED AT:", integer.0, error)
                
                XCTFail()
            }
        }
    }
    
    func testDoubles() {
        
        for correctPlainDoubleCase in correctPlainDoubleCases {
            
            print("TESTING:", correctPlainDoubleCase)
            
            let data = correctPlainDoubleCase.data(using: .utf8)!
            let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
            let terminator =
                NSKPlainJSONTerminator(whiteSpaces: options.whitespaces,
                                       endArray: options.endArray,
                                       endDictionary: options.endDictionary,
                                       comma: options.comma)
            
            do {
                
                let (number, length) = try NSKPlainNumberParser(options: options).parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return terminator.contains(buffer: data, at: index)
                })
                
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
            let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
            let terminator =
                NSKPlainJSONTerminator(whiteSpaces: options.whitespaces,
                                       endArray: options.endArray,
                                       endDictionary: options.endDictionary,
                                       comma: options.comma)
            
            XCTAssertThrowsError(try NSKPlainNumberParser(options: options).parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                
                return terminator.contains(buffer: data, at: index)
            }),
                                 "FAILED AT \(incorrectPlainCase)", { (error) in
            })
        }
    }
}
