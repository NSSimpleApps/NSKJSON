//
//  NSKMiscTests.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 12.04.17.
//
//

import XCTest
@testable import NSKJSON

class NSKMiscTests: XCTestCase {
    
    func testMisc() {
        
        //let str = "{\"a\":\"b\"}/**//"
        let str = "{\"a\":\"b\",,\"c\":\"d\"}"
        print(str)
        
        let data = str.data(using: .utf8)!
        let options = NSKOptions(encoding: .utf8, trailingComma: false, transformer: { $0 })
        
        do {
            
            //let obj = try NSKJSON5Parser(options: options).skipWhiteSpaces(buffer: data, from: 0)
            //let obj = try NSKJSON5Parser(options: options).skipSingleLineComment(buffer: data, from: 0, whitespaces: options.json5Whitespaces)
            //let obj = try NSKJSON5Parser(options: options).skipMultiLineComment(buffer: data, from: 0, whitespaces: options.json5Whitespaces)
            let obj = try NSKPlainParser(options: options).parseObject(buffer: data)
            
            print("!!!!!!", obj)
            
        } catch {
            
            print(error)
            
            XCTFail()
        }
    }
}
