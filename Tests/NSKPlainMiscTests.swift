//
//  NSKMiscTests.swift
//  NSKJSON
//
//  Created by NSSimpleApps on 12.04.17.
//
//

import XCTest
@testable import NSKJSON

class NSKPlainMiscTests: XCTestCase {
    
    func testMisc() {
        let data = """
{
"a": "b"
}
""".data(using: .utf8)!
        
        do {
            let obj = try NSKJSON.jsonObject(with: data, version: .plain)
            print("####", obj)
        } catch {
            print(error)
        }
    }
}
