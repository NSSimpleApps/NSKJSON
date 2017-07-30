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
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        
        for integer in correctPlainIntegerCases {
            
            let data = integer.0.data(using: .utf8)!
            
            do {
                
                let (number, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return json5Terminator.contains(buffer: data, at: index)
                })
                
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
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        
        for correctPlainDoubleCase in correctPlainDoubleCases {
            
            let data = correctPlainDoubleCase.data(using: .utf8)!
            
            do {
                
                let (number, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return json5Terminator.contains(buffer: data, at: index)
                })
                
                print("TESTING:", correctPlainDoubleCase)
                
                XCTAssertEqual(length, correctPlainDoubleCase.characters.count)
                XCTAssertTrue(number is Double)
                XCTAssertEqual(number as! Double, Double(correctPlainDoubleCase)!)
                
            } catch {
                
                print(error)
                
                XCTFail()
            }
        }
    }
    
    func testCorrectJSON5Integers() {
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        
        for correctJSON5IntegerCase in correctJSON5IntegerCases {
            
            do {
                
                print("TESTING:", correctJSON5IntegerCase.0)
                
                let data = correctJSON5IntegerCase.0.data(using: .utf8)!
                
                let (number, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return json5Terminator.contains(buffer: data, at: index)
                })
                
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
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        
        for correctJSON5DoubleCase in correctJSON5DoubleCases {
            
            do {
                
                print("TESTING:", correctJSON5DoubleCase)
                
                let data = correctJSON5DoubleCase.data(using: .utf8)!
                
                let (number, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return json5Terminator.contains(buffer: data, at: index)
                })
                
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
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        
        for incorrectJSON5Case in incorrectJSON5Cases {
            
            print("TESTING:", incorrectJSON5Case)
            
            let data = incorrectJSON5Case.data(using: .utf8)!
            
            XCTAssertThrowsError(try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                
                return json5Terminator.contains(buffer: data, at: index)
            }), "FAILED AT \(incorrectJSON5Case)", { (error) in
                
                //                let e = error as NSError
                //
                //                print(incorrectPlainCase, e.userInfo["NSDebugDescription"]!)
            })
        }
    }
    
    func testInfinity() {
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        let cases: [(String, Int)] = [("Infinity", 8), ("+Infinity", 9), ("-Infinity", 9)]
        
        for number in cases {
            
            do {
                
                print("TESTING:", number.0)
                
                let data = number.0.data(using: .utf8)!
                
                let (result, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return json5Terminator.contains(buffer: data, at: index)
                })
                
                XCTAssertEqual(length, number.1)
                XCTAssertTrue(result is Double)
                XCTAssertTrue((result as! Double).isInfinite)
                
            } catch {
                
                print("FAILED AT:", number.0, error)
                
                XCTFail()
            }
        }
    }
    
    func testNaN() {
        
        let options = NSKOptions<UInt8>(encoding: .utf8, transformer: { $0 })
        let plainTerminator =
            NSKPlainJSONTerminator(whiteSpaces: options.json5Whitespaces,
                                   endArray: options.endArray,
                                   endDictionary: options.endDictionary,
                                   comma: options.comma)
        let json5Terminator = NSKJSON5Terminator(terminator: plainTerminator, slash: options.slash, star: options.star)
        let parser = NSKJSON5NumberParser<Data>(options: options)
        let cases: [(String, Int)] = [("NaN", 3), ("+NaN", 4), ("-NaN", 4)]
        
        for number in cases {
            
            do {
                
                print("TESTING:", number.0)
                
                let data = number.0.data(using: .utf8)!
                
                let (result, length) = try parser.parseNumber(buffer: data, from: 0, terminator: { (data, index) -> Bool in
                    
                    return json5Terminator.contains(buffer: data, at: index)
                })
                
                XCTAssertEqual(length, number.1)
                XCTAssertTrue(result is Double)
                XCTAssertTrue((result as! Double).isNaN)
                
            } catch {
                
                print("FAILED AT:", number.0, error)
                
                XCTFail()
            }
        }
    }
    
    func testMisc() {
        
        //let str = "+0x1.91eb85P+1"
        //let str = "0x185P+1"
//        let strs = ["-.512e+10"]
//        for str in strs {
//            
//            do {
//                
//                print("TESTING:", str)
//                
//                let data = str.data(using: .utf8)!
//                let buffer: UnsafeBufferPointer<UInt8> = data.buffer(offset: 0)
//                
//                let (number, length) = try NSKJSON5NumberParser.parseNumber(buffer: buffer, from: 0, terminator: NSKJSON5Terminator.self)
//                
//                print(number, Double(str)!)
//                
//                XCTAssertEqual(length, str.characters.count)
//                XCTAssertTrue(number is Double)
//                XCTAssertEqual(number as! Double, Double(str)!)
//                
//            } catch {
//                
//                print("FAILED AT:", str, error)
//                
//                XCTFail()
//            }
//        }
    }
}
