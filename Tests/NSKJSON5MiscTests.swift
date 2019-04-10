//
//  NSKJSON5MiscTests.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 07/04/2019.
//

import XCTest
@testable import NSKJSON

class NSKJSON5MiscTests: XCTestCase {
    
    func testMisc() {
        let data = "[[] ]".data(using: .utf8)!
        do {
            
            let obj = try NSKJSON.jsonObject(with: data, version: .json5)
            print(obj)
            //XCTAssertTrue(obj is String)
            //XCTAssertEqual(obj as! String, "a\na")
        } catch {
            XCTFail("FAILED \(error)")
        }
    }
}
