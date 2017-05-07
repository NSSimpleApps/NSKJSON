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
        
        //let str = "0.e1"
        //let str = "[1,]"
        //let data = Data(bytes: [123, 34, 185, 34, 58, 34, 48, 34, 44, 125])
        let data = Data(bytes: [NSKQuotationMark, NSKa, NSKBackSlash,
                                NSKQuotationMark])
        
        //let data = str.data(using: .utf8)!
        
        do {
            
            let obj = try NSKJSON.jsonObject(with: data, version: .json5)
            
            print("!!!!!!", obj)
            
        } catch {
            
            print(error)
            
            XCTFail()
            
        }
    }
}
